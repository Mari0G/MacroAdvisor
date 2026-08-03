import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meal_capture/infrastructure/gemini_nutrition_analysis_provider.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';

void main() {
  group('GeminiNutritionAnalysisProvider', () {
    test(
      'maps a structured response to the provider-neutral contract',
      () async {
        final transport = _FakeTransport(
          response: GeminiHttpResponse(
            statusCode: 200,
            body: _fixture('success.json'),
          ),
        );
        final provider = _provider(transport);

        final result = await provider.analyzeText(
          const NutritionAnalysisRequest(
            description: '80 g Haferflocken',
            localeTag: 'de-DE',
          ),
        );

        expect(result.provenance.providerId, 'gemini');
        expect(result.provenance.modelId, 'gemini-3.5-flash-lite');
        expect(result.provenance.detectedLocale, 'de-DE');
        expect(result.items.single.name, 'Haferflocken');
        expect(result.items.single.normalizedGramsMilli, 80000);
        expect(
          (result.items.single.nutrition[NutrientId.energy]
                  as KnownNutritionValue)
              .milliUnits,
          300000,
        );
        expect(result.assumptions.single.code, 'portion');
        expect(
          result.warnings.map((warning) => warning.code),
          contains('estimate'),
        );
        expect(transport.headers['x-goog-api-key'], 'test-secret');
        expect(transport.body, contains('80 g Haferflocken'));
        expect(transport.body, contains('de-DE'));
        expect(transport.body, contains('thinkingLevel'));
        expect(transport.timeout, const Duration(seconds: 60));

        final request = jsonDecode(transport.body) as Map<String, dynamic>;
        final schema =
            (request['generationConfig']
                    as Map<String, dynamic>)['responseSchema']
                as Map<String, dynamic>;
        final properties = schema['properties'] as Map<String, dynamic>;
        final items = properties['items'] as Map<String, dynamic>;
        final itemSchema = items['items'] as Map<String, dynamic>;
        final itemProperties = itemSchema['properties'] as Map<String, dynamic>;
        final itemNutrients =
            (itemProperties['nutrients'] as Map<String, dynamic>)['properties']
                as Map<String, dynamic>;
        final totals = properties['totals'] as Map<String, dynamic>;
        final totalsProperties = totals['properties'] as Map<String, dynamic>;
        for (final nutrient in <String>[
          'energy',
          'protein',
          'carbohydrates',
          'fat',
          'fibre',
          'sugars',
          'salt',
        ]) {
          expect(
            (itemNutrients[nutrient] as Map<String, dynamic>)['required'],
            contains('unit'),
            reason: 'item nutrient $nutrient must require a unit',
          );
          expect(
            (totalsProperties[nutrient] as Map<String, dynamic>)['required'],
            contains('unit'),
            reason: 'total nutrient $nutrient must require a unit',
          );
        }
        expect(
          (itemProperties['amount'] as Map<String, dynamic>)['required'],
          isNull,
          reason: 'meal amount units remain optional',
        );
        expect(
          (itemSchema['properties'] as Map<String, dynamic>)['assumptions'],
          isA<Map<String, dynamic>>(),
        );
        expect(
          (properties['warnings'] as Map<String, dynamic>)['items'],
          isA<Map<String, dynamic>>(),
        );
        expect(
          (properties['assumptions'] as Map<String, dynamic>)['items'],
          isA<Map<String, dynamic>>(),
        );
      },
    );

    test('sends a normalized image only as inline JPEG data', () async {
      final transport = _FakeTransport(
        response: GeminiHttpResponse(
          statusCode: 200,
          body: _fixture('success.json'),
        ),
      );
      final provider = _provider(transport);

      await provider.analyzeImage(
        NutritionImageAnalysisRequest(
          localeTag: 'en',
          photo: MealPhoto(
            jpegBytes: Uint8List.fromList([1, 2, 3]),
            width: 1,
            height: 1,
          ),
        ),
      );

      final request = jsonDecode(transport.body) as Map<String, dynamic>;
      final parts =
          ((request['contents'] as List).single
                  as Map<String, dynamic>)['parts']
              as List<dynamic>;
      final inlineData =
          (parts.single as Map<String, dynamic>)['inlineData']
              as Map<String, dynamic>;
      expect(inlineData['mimeType'], MealPhoto.mimeType);
      expect(inlineData['data'], base64Encode([1, 2, 3]));
      expect(transport.timeout, const Duration(seconds: 60));
      expect(transport.body, isNot(contains('filename')));
      expect(transport.body, isNot(contains('fileUri')));
    });

    test('maps missing nutrient units to invalid response', () async {
      final provider = _provider(
        _FakeTransport(
          response: GeminiHttpResponse(
            statusCode: 200,
            body: _fixture('missing_nutrient_unit.json'),
          ),
        ),
      );

      await expectLater(
        provider.analyzeText(
          const NutritionAnalysisRequest(
            description: 'oatmeal with banana and yogurt',
            localeTag: 'en',
          ),
        ),
        throwsA(isA<InvalidAnalysisResponse>()),
      );
    });

    test('preserves partial and unknown values as editable data', () async {
      final provider = _provider(
        _FakeTransport(
          response: GeminiHttpResponse(
            statusCode: 200,
            body: _fixture('partial_unknown.json'),
          ),
        ),
      );

      final result = await provider.analyzeText(
        const NutritionAnalysisRequest(
          description: 'unknown dish',
          localeTag: 'en',
        ),
      );

      final item = result.items.single;
      expect(item.nutrition[NutrientId.energy], isA<UnknownNutritionValue>());
      expect(
        (item.nutrition[NutrientId.protein] as KnownNutritionValue).milliUnits,
        4500,
      );
      expect(item.nutrition[NutrientId.fat], isA<UnknownNutritionValue>());
      expect(
        result.warnings.map((warning) => warning.code),
        contains('partial'),
      );
      expect(
        result.warnings.map((warning) => warning.code),
        contains('unknown-carbohydrates'),
      );
    });

    test(
      'maps malformed JSON, schema, and unsupported units to invalid response',
      () async {
        for (final fixture in <String>[
          'invalid_json.json',
          'invalid_schema.json',
          'unsupported_unit.json',
        ]) {
          final provider = _provider(
            _FakeTransport(
              response: GeminiHttpResponse(
                statusCode: 200,
                body: _fixture(fixture),
              ),
            ),
          );

          await expectLater(
            provider.analyzeText(
              const NutritionAnalysisRequest(
                description: 'meal',
                localeTag: 'en',
              ),
            ),
            throwsA(isA<InvalidAnalysisResponse>()),
            reason: fixture,
          );
        }
      },
    );

    test('maps provider HTTP failures to neutral categories', () async {
      final cases = <String, NutritionAnalysisFailure Function()>{
        'credential_error.json': InvalidAnalysisCredential.new,
        'rate_limited.json': AnalysisRateLimited.new,
        'content_rejected.json': AnalysisContentRejected.new,
      };

      for (final entry in cases.entries) {
        final provider = _provider(
          _FakeTransport(
            response: GeminiHttpResponse(
              statusCode: entry.key == 'rate_limited.json' ? 429 : 401,
              body: _fixture(entry.key),
            ),
          ),
        );

        await expectLater(
          provider.analyzeText(
            const NutritionAnalysisRequest(
              description: 'meal',
              localeTag: 'en',
            ),
          ),
          throwsA(
            isA<NutritionAnalysisFailure>().having(
              (failure) => failure.runtimeType,
              'type',
              entry.value().runtimeType,
            ),
          ),
          reason: entry.key,
        );
      }
    });

    test('maps an absent stored credential to a recoverable failure', () async {
      final provider = GeminiNutritionAnalysisProvider(
        credentialStore: _FakeCredentialStore(null),
        clock: _FixedClock(DateTime.utc(2026, 7, 18, 12)),
        idGenerator: _Ids(),
        transport: _FakeTransport(
          response: const GeminiHttpResponse(statusCode: 200, body: '{}'),
        ),
      );

      await expectLater(
        provider.analyzeText(
          const NutritionAnalysisRequest(description: 'meal', localeTag: 'en'),
        ),
        throwsA(isA<MissingAnalysisCredential>()),
      );
    });

    test('maps transport timeouts to an offline failure', () async {
      final provider = _provider(
        _FakeTransport(error: TimeoutException('secret meal')),
      );

      await expectLater(
        provider.analyzeText(
          const NutritionAnalysisRequest(
            description: 'private meal',
            localeTag: 'en',
          ),
        ),
        throwsA(isA<AnalysisOffline>()),
      );
    });

    test('uses the same credential boundary for connection checks', () async {
      final transport = _FakeTransport(
        response: const GeminiHttpResponse(statusCode: 200, body: '{}'),
      );
      final provider = _provider(transport);

      expect(
        await provider.check('test-secret'),
        ProviderConnectionResult.success,
      );
      expect(transport.headers['x-goog-api-key'], 'test-secret');
      expect(transport.body, contains('Reply with OK.'));
      expect(transport.body, isNot(contains('responseSchema')));
      expect(transport.body, contains('"maxOutputTokens":1'));
      expect(transport.timeout, const Duration(seconds: 45));
      expect(
        await provider.check('   '),
        ProviderConnectionResult.invalidCredential,
      );
    });

    test(
      'keeps connection checks independent of structured output support',
      () async {
        final provider = _provider(
          _FakeTransport(
            response: const GeminiHttpResponse(statusCode: 200, body: '{}'),
          ),
        );

        expect(
          await provider.check('test-secret'),
          ProviderConnectionResult.success,
        );
      },
    );

    test('maps connection failures to actionable categories', () async {
      final offlineProvider = _provider(
        _FakeTransport(error: TimeoutException('network timeout')),
      );
      expect(
        await offlineProvider.check('test-secret'),
        ProviderConnectionResult.offline,
      );

      final invalidCredentialProvider = _provider(
        _FakeTransport(
          response: const GeminiHttpResponse(
            statusCode: 400,
            body: '{"error":{}}',
          ),
        ),
      );
      expect(
        await invalidCredentialProvider.check('test-secret'),
        ProviderConnectionResult.invalidCredential,
      );
    });

    test(
      'does not expose credentials or descriptions in mapped failures',
      () async {
        const secret = 'super-secret-key';
        const description = 'private family recipe';
        final provider = _provider(
          _FakeTransport(
            response: const GeminiHttpResponse(
              statusCode: 401,
              body: '{"message":"super-secret-key private family recipe"}',
            ),
          ),
          credential: secret,
        );

        try {
          await provider.analyzeText(
            const NutritionAnalysisRequest(
              description: description,
              localeTag: 'en',
            ),
          );
          fail('expected InvalidAnalysisCredential');
        } catch (error) {
          expect(error, isA<InvalidAnalysisCredential>());
          expect(error.toString(), isNot(contains(secret)));
          expect(error.toString(), isNot(contains(description)));
        }
      },
    );
  });
}

GeminiNutritionAnalysisProvider _provider(
  _FakeTransport transport, {
  String credential = 'test-secret',
}) {
  return GeminiNutritionAnalysisProvider(
    credentialStore: _FakeCredentialStore(credential),
    clock: _FixedClock(DateTime.utc(2026, 7, 18, 12)),
    idGenerator: _Ids(),
    transport: transport,
  );
}

String _fixture(String name) => File(
  'test/src/features/meal_capture/infrastructure/fixtures/$name',
).readAsStringSync();

final class _FakeTransport implements GeminiHttpTransport {
  _FakeTransport({this.response, this.error});

  final GeminiHttpResponse? response;
  final Object? error;
  Uri? uri;
  Map<String, String> headers = const {};
  String body = '';
  Duration? timeout;

  @override
  Future<GeminiHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    this.uri = uri;
    this.headers = headers;
    this.body = body;
    this.timeout = timeout;
    if (error != null) {
      throw error!;
    }
    return response!;
  }

  @override
  void close() {}
}

final class _FakeCredentialStore implements CredentialStore {
  _FakeCredentialStore(this.credential);

  final String? credential;

  @override
  Future<void> delete(String providerId) async {}

  @override
  Future<String?> read(String providerId) async => credential;

  @override
  Future<void> write({
    required String providerId,
    required String credential,
  }) async {}
}

final class _FixedClock implements Clock {
  const _FixedClock(this.value);

  final DateTime value;

  @override
  DateTime now() => value;
}

final class _Ids implements IdGenerator {
  int _next = 0;

  @override
  String newId() => 'item-${++_next}';
}
