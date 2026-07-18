import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:macro_advisor/src/core/domain/clock.dart';
import 'package:macro_advisor/src/core/domain/id_generator.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/nutrition_analysis.dart';
import 'package:macro_advisor/src/features/meals/domain/meal_entry.dart';
import 'package:macro_advisor/src/features/meals/domain/nutrition.dart';
import 'package:macro_advisor/src/features/settings/domain/credential_store.dart';
import 'package:macro_advisor/src/features/settings/domain/provider_connection_checker.dart';

const _geminiProviderId = 'gemini';
const _geminiModelId = 'gemini-2.5-flash';
const _geminiEndpoint =
    'https://generativelanguage.googleapis.com/v1beta/models/'
    '$_geminiModelId:generateContent';

/// The adapter's narrow, provider-specific HTTP seam.
///
/// It lives in infrastructure so neither application code nor the domain has
/// to know about Gemini's wire protocol. Tests use a fixture-backed fake here;
/// production uses [_IoGeminiHttpTransport].
abstract interface class GeminiHttpTransport {
  Future<GeminiHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  });

  void close();
}

/// A sanitized HTTP result used only at the infrastructure boundary.
final class GeminiHttpResponse {
  const GeminiHttpResponse({required this.statusCode, required this.body});

  final int statusCode;
  final String body;
}

/// Gemini implementation of the provider-neutral analysis port and settings
/// connection-check port.
///
/// Credentials are read only at request time and are never included in a URI,
/// exception, or returned value. Call [close] when the owning composition scope
/// is disposed.
final class GeminiNutritionAnalysisProvider
    implements NutritionAnalysisProvider, ProviderConnectionChecker {
  GeminiNutritionAnalysisProvider({
    required this._credentialStore,
    required this._clock,
    required this._idGenerator,
    GeminiHttpTransport? transport,
    this.timeout = const Duration(seconds: 20),
  }) : _transport = transport ?? _IoGeminiHttpTransport(HttpClient());

  final CredentialStore _credentialStore;
  final Clock _clock;
  final IdGenerator _idGenerator;
  final GeminiHttpTransport _transport;
  final Duration timeout;

  @override
  Future<NutritionAnalysis> analyzeText(
    NutritionAnalysisRequest request,
  ) async {
    final credential = await _readCredential();
    final response = await _send(
      credential: credential,
      body: _requestBody(
        localeTag: request.localeTag,
        description: request.description,
        connectionCheck: false,
      ),
    );
    _throwForHttpResponse(response);

    try {
      final wireResult = _GeminiWireResponse.fromJson(
        _decodeJson(response.body),
      );
      return _toDomain(wireResult, request);
    } on _InvalidGeminiPayload {
      throw const InvalidAnalysisResponse();
    } on NutritionAnalysisFailure {
      rethrow;
    } catch (_) {
      throw const UnknownAnalysisFailure();
    }
  }

  @override
  Future<ProviderConnectionResult> check(String credential) async {
    final normalizedCredential = credential.trim();
    if (normalizedCredential.isEmpty) {
      return ProviderConnectionResult.invalidCredential;
    }

    try {
      final response = await _send(
        credential: normalizedCredential,
        body: _requestBody(
          localeTag: 'en-US',
          description: 'Reply with a valid empty nutrition estimate.',
          connectionCheck: true,
        ),
      );
      return _connectionResult(response);
    } on SocketException {
      return ProviderConnectionResult.offline;
    } on TimeoutException {
      return ProviderConnectionResult.offline;
    } on HandshakeException {
      return ProviderConnectionResult.offline;
    } catch (_) {
      return ProviderConnectionResult.unavailable;
    }
  }

  void close() => _transport.close();

  Future<String> _readCredential() async {
    try {
      final credential = await _credentialStore.read(_geminiProviderId);
      if (credential == null || credential.trim().isEmpty) {
        throw const MissingAnalysisCredential();
      }
      return credential.trim();
    } on NutritionAnalysisFailure {
      rethrow;
    } catch (_) {
      throw const UnknownAnalysisFailure();
    }
  }

  Future<GeminiHttpResponse> _send({
    required String credential,
    required String body,
  }) async {
    try {
      return await _transport.post(
        uri: Uri.parse(_geminiEndpoint),
        headers: <String, String>{
          HttpHeaders.contentTypeHeader: 'application/json',
          'x-goog-api-key': credential,
        },
        body: body,
        timeout: timeout,
      );
    } on SocketException {
      throw const AnalysisOffline();
    } on TimeoutException {
      throw const AnalysisOffline();
    } on HandshakeException {
      throw const AnalysisOffline();
    } on NutritionAnalysisFailure {
      rethrow;
    } catch (_) {
      throw const UnknownAnalysisFailure();
    }
  }

  static Object _decodeJson(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded == null) {
        throw const _InvalidGeminiPayload();
      }
      return decoded as Object;
    } catch (_) {
      throw const _InvalidGeminiPayload();
    }
  }

  static String _requestBody({
    required String localeTag,
    required String description,
    required bool connectionCheck,
  }) {
    final instruction = StringBuffer()
      ..write('Analyze the meal description for locale $localeTag. ')
      ..write(
        'Return only JSON matching the supplied response schema. '
        'Use unknown nutrient values when the description does not support '
        'a defensible estimate; do not invent precision. '
        'Nutrient units must be kcal for energy and g for all other nutrients. ',
      );
    if (connectionCheck) {
      instruction.write(
        'This is a connection check; return an empty items list.',
      );
    }

    return jsonEncode(<String, Object?>{
      'system_instruction': <String, Object?>{
        'parts': <Object?>[
          <String, String>{'text': instruction.toString()},
        ],
      },
      'contents': <Object?>[
        <String, Object?>{
          'role': 'user',
          'parts': <Object?>[
            <String, String>{'text': description},
          ],
        },
      ],
      'generationConfig': <String, Object?>{
        'responseMimeType': 'application/json',
        'responseSchema': _responseSchema,
        'temperature': 0,
      },
    });
  }

  static final _responseSchema = <String, Object?>{
    'type': 'OBJECT',
    'properties': <String, Object?>{
      'detectedLocale': <String, Object?>{'type': 'STRING'},
      'confidence': <String, Object?>{
        'type': 'STRING',
        'enum': <String>['low', 'medium', 'high'],
      },
      'items': <String, Object?>{
        'type': 'ARRAY',
        'items': <String, Object?>{
          'type': 'OBJECT',
          'properties': <String, Object?>{
            'name': <String, Object?>{'type': 'STRING'},
            'amount': <String, Object?>{
              'type': 'OBJECT',
              'properties': <String, Object?>{
                'value': <String, Object?>{'type': 'NUMBER'},
                'unit': <String, Object?>{'type': 'STRING'},
              },
            },
            'nutrients': <String, Object?>{
              'type': 'OBJECT',
              'properties': <String, Object?>{
                for (final nutrient in <String>[
                  'energy',
                  'protein',
                  'carbohydrates',
                  'fat',
                  'fibre',
                  'sugars',
                  'salt',
                ])
                  nutrient: <String, Object?>{
                    'type': 'OBJECT',
                    'properties': <String, Object?>{
                      'value': <String, Object?>{'type': 'NUMBER'},
                      'unit': <String, Object?>{'type': 'STRING'},
                    },
                  },
              },
            },
          },
          'required': <String>['name', 'nutrients'],
        },
      },
      'totals': <String, Object?>{
        'type': 'OBJECT',
        'description': 'Optional totals used for consistency validation.',
      },
      'assumptions': <String, Object?>{'type': 'ARRAY'},
      'warnings': <String, Object?>{'type': 'ARRAY'},
    },
    'required': <String>['items', 'confidence'],
  };

  NutritionAnalysis _toDomain(
    _GeminiWireResponse response,
    NutritionAnalysisRequest request,
  ) {
    final warnings = <AnalysisWarning>[
      ...response.warnings,
      const AnalysisWarning(
        code: 'estimate',
        description: 'Nutrition values are estimates and can be edited.',
      ),
    ];
    final items = <MealItem>[];
    for (final item in response.items) {
      final parsed = _parseItem(item, response.confidence, warnings);
      items.add(parsed);
    }
    _validateTotals(response.totals, items, warnings);

    return NutritionAnalysis(
      provenance: MealProvenance(
        providerId: _geminiProviderId,
        modelId: _geminiModelId,
        analyzedAtUtc: _utc(_clock.now()),
        detectedLocale: response.detectedLocale ?? request.localeTag,
      ),
      items: items,
      confidence: response.confidence,
      assumptions: response.assumptions,
      warnings: warnings,
    );
  }

  MealItem _parseItem(
    Map<String, Object?> raw,
    MealConfidence fallbackConfidence,
    List<AnalysisWarning> warnings,
  ) {
    final name = _requiredString(raw, 'name');
    final nutrientsRaw = raw['nutrients'];
    if (nutrientsRaw is! Map) {
      throw const _InvalidGeminiPayload();
    }

    final values = <NutrientId, NutritionValue>{};
    for (final nutrient in NutrientId.core) {
      final rawValue = nutrientsRaw[nutrient.value];
      final value = _parseNutrient(rawValue, nutrient);
      values[nutrient] = value;
      if (value is UnknownNutritionValue) {
        warnings.add(
          AnalysisWarning(
            code: 'unknown-${nutrient.value}',
            description:
                '${nutrient.value} was not available from the provider.',
          ),
        );
      }
    }

    final amount = _parseAmount(raw['amount'], warnings);
    final confidence = _confidence(raw['confidence']) ?? fallbackConfidence;
    return MealItem(
      id: _idGenerator.newId(),
      name: name,
      amountDescription:
          amount.description ?? _optionalString(raw, 'amountDescription'),
      normalizedGramsMilli: amount.normalizedGramsMilli,
      confidence: confidence,
      assumptions: _assumptions(raw['assumptions']),
      nutrition: NutritionFacts(values),
    );
  }

  NutritionValue _parseNutrient(Object? raw, NutrientId nutrient) {
    if (raw == null || raw is String && raw.toLowerCase() == 'unknown') {
      return UnknownNutritionValue(
        unit: nutrient.canonicalUnit,
        source: NutritionValueSource.providerEstimate,
      );
    }
    if (raw is! Map) {
      throw const _InvalidGeminiPayload();
    }
    final unit = _unit(raw['unit'], nutrient);
    final rawValue = raw['value'];
    if (raw['unknown'] == true || rawValue == null) {
      return UnknownNutritionValue(
        unit: unit,
        source: NutritionValueSource.providerEstimate,
      );
    }
    if (rawValue is! num || !rawValue.isFinite || rawValue < 0) {
      throw const _InvalidGeminiPayload();
    }
    final milliUnits = _milliUnits(rawValue, nutrient);
    return KnownNutritionValue(
      milliUnits: milliUnits,
      unit: unit,
      source: NutritionValueSource.providerEstimate,
    );
  }

  NutritionUnit _unit(Object? raw, NutrientId nutrient) {
    if (raw is! String) {
      throw const _InvalidGeminiPayload();
    }
    final normalized = raw.trim().toLowerCase();
    final expected = nutrient == NutrientId.energy
        ? const <String>{'kcal', 'kilocalorie', 'kilocalories'}
        : const <String>{'g', 'gram', 'grams'};
    if (!expected.contains(normalized)) {
      throw const _InvalidGeminiPayload();
    }
    return nutrient.canonicalUnit;
  }

  int _milliUnits(num value, NutrientId nutrient) {
    final milliUnits = (value * 1000).round();
    final maximum = nutrient == NutrientId.energy ? 1000000000 : 10000000;
    if (milliUnits < 0 || milliUnits > maximum) {
      throw const _InvalidGeminiPayload();
    }
    return milliUnits;
  }

  _ParsedAmount _parseAmount(Object? raw, List<AnalysisWarning> warnings) {
    if (raw == null) {
      warnings.add(
        const AnalysisWarning(
          code: 'unknown-amount',
          description: 'The item amount was not available from the provider.',
        ),
      );
      return const _ParsedAmount();
    }
    if (raw is! Map) {
      throw const _InvalidGeminiPayload();
    }
    final rawValue = raw['value'];
    final unit = raw['unit'];
    const supported = <String>{
      'g',
      'gram',
      'grams',
      'kg',
      'kilogram',
      'kilograms',
      'ml',
      'millilitre',
      'millilitres',
      'milliliter',
      'milliliters',
      'l',
      'litre',
      'litres',
      'liter',
      'liters',
      'piece',
      'pieces',
      'serving',
      'servings',
    };
    if (rawValue == null || raw['unknown'] == true) {
      if (unit != null &&
          (unit is! String || !supported.contains(unit.toLowerCase()))) {
        throw const _InvalidGeminiPayload();
      }
      warnings.add(
        const AnalysisWarning(
          code: 'unknown-amount',
          description: 'The item amount was not available from the provider.',
        ),
      );
      return _ParsedAmount(description: _optionalString(raw, 'description'));
    }
    if (rawValue is! num ||
        !rawValue.isFinite ||
        rawValue < 0 ||
        unit is! String) {
      throw const _InvalidGeminiPayload();
    }
    final normalizedUnit = unit.toLowerCase();
    if (!supported.contains(normalizedUnit) || rawValue > 1000000) {
      throw const _InvalidGeminiPayload();
    }
    final normalizedGramsMilli = switch (normalizedUnit) {
      'g' || 'gram' || 'grams' => (rawValue * 1000).round(),
      'kg' || 'kilogram' || 'kilograms' => (rawValue * 1000000).round(),
      _ => null,
    };
    return _ParsedAmount(
      description: raw['description'] is String
          ? raw['description'] as String
          : '${rawValue.toString()} $unit',
      normalizedGramsMilli: normalizedGramsMilli,
    );
  }

  void _validateTotals(
    Map<String, Object?>? totals,
    List<MealItem> items,
    List<AnalysisWarning> warnings,
  ) {
    if (totals == null) {
      return;
    }
    for (final nutrient in NutrientId.core) {
      final rawTotal = totals[nutrient.value];
      if (rawTotal == null) {
        continue;
      }
      final total = _parseNutrient(rawTotal, nutrient);
      if (total is UnknownNutritionValue) {
        continue;
      }
      final itemValues = items
          .map((item) => item.nutrition[nutrient])
          .toList(growable: false);
      if (itemValues.any((value) => value is UnknownNutritionValue)) {
        warnings.add(
          AnalysisWarning(
            code: 'total-not-verifiable-${nutrient.value}',
            description: '${nutrient.value} total could not be verified.',
          ),
        );
        continue;
      }
      final sum = itemValues.cast<KnownNutritionValue>().fold<int>(
        0,
        (result, value) => result + value.milliUnits,
      );
      final knownTotal = total as KnownNutritionValue;
      if ((sum - knownTotal.milliUnits).abs() > 2) {
        throw const _InvalidGeminiPayload();
      }
    }
  }

  static String _requiredString(Map<String, Object?> raw, String key) {
    final value = raw[key];
    if (value is! String || value.trim().isEmpty) {
      throw const _InvalidGeminiPayload();
    }
    return value.trim();
  }

  static String? _optionalString(Map<Object?, Object?> raw, String key) {
    final value = raw[key];
    return value is String && value.trim().isNotEmpty ? value.trim() : null;
  }

  static List<MealAssumption> _assumptions(Object? raw) {
    if (raw == null) {
      return const [];
    }
    if (raw is! List) {
      throw const _InvalidGeminiPayload();
    }
    final assumptions = <MealAssumption>[];
    for (final value in raw) {
      if (value is! Map ||
          value['code'] is! String ||
          value['description'] is! String ||
          (value['code'] as String).trim().isEmpty ||
          (value['description'] as String).trim().isEmpty) {
        throw const _InvalidGeminiPayload();
      }
      assumptions.add(
        MealAssumption(
          code: (value['code'] as String).trim(),
          description: (value['description'] as String).trim(),
        ),
      );
    }
    return assumptions;
  }

  static MealConfidence? _confidence(Object? raw) {
    if (raw is! String) {
      return null;
    }
    return switch (raw.toLowerCase()) {
      'low' => MealConfidence.low,
      'medium' => MealConfidence.medium,
      'high' => MealConfidence.high,
      _ => throw const _InvalidGeminiPayload(),
    };
  }

  static DateTime _utc(DateTime value) => value.isUtc ? value : value.toUtc();

  static ProviderConnectionResult _connectionResult(
    GeminiHttpResponse response,
  ) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return ProviderConnectionResult.success;
    }
    final body = response.body.toLowerCase();
    if (response.statusCode == 401 ||
        response.statusCode == 403 && !body.contains('safety')) {
      return ProviderConnectionResult.invalidCredential;
    }
    if (body.contains('safety') || body.contains('blocked')) {
      return ProviderConnectionResult.unavailable;
    }
    if (response.statusCode == 429) {
      return ProviderConnectionResult.rateLimited;
    }
    if ({408, 502, 503, 504}.contains(response.statusCode)) {
      return ProviderConnectionResult.offline;
    }
    return ProviderConnectionResult.unavailable;
  }

  static void _throwForHttpResponse(GeminiHttpResponse response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }
    final body = response.body.toLowerCase();
    if (body.contains('safety') || body.contains('blocked')) {
      throw const AnalysisContentRejected();
    }
    if (response.statusCode == 401 ||
        response.statusCode == 403 ||
        response.statusCode == 400 &&
            (body.contains('api key') ||
                body.contains('api_key') ||
                body.contains('credential'))) {
      throw const InvalidAnalysisCredential();
    }
    if (response.statusCode == 429) {
      throw const AnalysisRateLimited();
    }
    if ({408, 502, 503, 504}.contains(response.statusCode)) {
      throw const AnalysisOffline();
    }
    throw const UnknownAnalysisFailure();
  }
}

final class _IoGeminiHttpTransport implements GeminiHttpTransport {
  _IoGeminiHttpTransport(this._client);

  final HttpClient _client;

  @override
  Future<GeminiHttpResponse> post({
    required Uri uri,
    required Map<String, String> headers,
    required String body,
    required Duration timeout,
  }) async {
    final request = await _client.postUrl(uri).timeout(timeout);
    headers.forEach(request.headers.set);
    request.headers.contentType = ContentType.json;
    request.add(utf8.encode(body));
    final response = await request.close().timeout(timeout);
    final responseBody = await response
        .transform(utf8.decoder)
        .join()
        .timeout(timeout);
    return GeminiHttpResponse(
      statusCode: response.statusCode,
      body: responseBody,
    );
  }

  @override
  void close() => _client.close(force: true);
}

final class _GeminiWireResponse {
  const _GeminiWireResponse({
    required this.items,
    required this.confidence,
    required this.assumptions,
    required this.warnings,
    this.detectedLocale,
    this.totals,
  });

  final List<Map<String, Object?>> items;
  final MealConfidence confidence;
  final List<MealAssumption> assumptions;
  final List<AnalysisWarning> warnings;
  final String? detectedLocale;
  final Map<String, Object?>? totals;

  factory _GeminiWireResponse.fromJson(Object? json) {
    if (json is! Map) {
      throw const _InvalidGeminiPayload();
    }
    final candidates = json['candidates'];
    if (candidates is! List || candidates.isEmpty || candidates.first is! Map) {
      final feedback = json['promptFeedback'];
      if (feedback is Map && feedback['blockReason'] != null) {
        throw const AnalysisContentRejected();
      }
      throw const _InvalidGeminiPayload();
    }
    final candidate = candidates.first as Map;
    final finishReason = candidate['finishReason'];
    if (finishReason is String &&
        {'SAFETY', 'BLOCKLIST', 'PROHIBITED_CONTENT'}.contains(finishReason)) {
      throw const AnalysisContentRejected();
    }
    final content = candidate['content'];
    if (content is! Map || content['parts'] is! List) {
      throw const _InvalidGeminiPayload();
    }
    final parts = content['parts'] as List;
    final text = parts
        .whereType<Map<Object?, Object?>>()
        .map((part) => part['text'])
        .whereType<String>()
        .join();
    if (text.trim().isEmpty) {
      throw const _InvalidGeminiPayload();
    }
    final decoded = _decodeModelJson(text);
    if (decoded is! Map || decoded['items'] is! List) {
      throw const _InvalidGeminiPayload();
    }
    final rawItems = decoded['items'] as List;
    if (rawItems.isEmpty || rawItems.any((item) => item is! Map)) {
      throw const _InvalidGeminiPayload();
    }
    final confidence = GeminiNutritionAnalysisProvider._confidence(
      decoded['confidence'],
    );
    if (confidence == null) {
      throw const _InvalidGeminiPayload();
    }
    final assumptions = GeminiNutritionAnalysisProvider._assumptions(
      decoded['assumptions'],
    );
    final warnings = _warnings(decoded['warnings']);
    final detectedLocale = decoded['detectedLocale'];
    if (detectedLocale != null && detectedLocale is! String) {
      throw const _InvalidGeminiPayload();
    }
    final totals = decoded['totals'];
    if (totals != null && totals is! Map) {
      throw const _InvalidGeminiPayload();
    }
    return _GeminiWireResponse(
      items: [
        for (final item in rawItems) Map<String, Object?>.from(item as Map),
      ],
      confidence: confidence,
      assumptions: assumptions,
      warnings: warnings,
      detectedLocale: detectedLocale as String?,
      totals: totals == null ? null : Map<String, Object?>.from(totals as Map),
    );
  }

  static Object? _decodeModelJson(String text) {
    var normalized = text.trim();
    if (normalized.startsWith('```') && normalized.endsWith('```')) {
      normalized = normalized
          .replaceFirst(RegExp(r'^```(?:json)?\s*'), '')
          .replaceFirst(RegExp(r'\s*```$'), '')
          .trim();
    }
    try {
      return jsonDecode(normalized);
    } catch (_) {
      throw const _InvalidGeminiPayload();
    }
  }

  static List<AnalysisWarning> _warnings(Object? raw) {
    if (raw == null) {
      return const [];
    }
    if (raw is! List) {
      throw const _InvalidGeminiPayload();
    }
    final warnings = <AnalysisWarning>[];
    for (final value in raw) {
      if (value is! Map ||
          value['code'] is! String ||
          value['description'] is! String ||
          (value['code'] as String).trim().isEmpty ||
          (value['description'] as String).trim().isEmpty) {
        throw const _InvalidGeminiPayload();
      }
      warnings.add(
        AnalysisWarning(
          code: (value['code'] as String).trim(),
          description: (value['description'] as String).trim(),
        ),
      );
    }
    return warnings;
  }
}

final class _ParsedAmount {
  const _ParsedAmount({this.description, this.normalizedGramsMilli});

  final String? description;
  final int? normalizedGramsMilli;
}

final class _InvalidGeminiPayload implements Exception {
  const _InvalidGeminiPayload();
}
