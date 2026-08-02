import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:macro_advisor/src/features/meal_capture/application/meal_photo_source.dart';
import 'package:macro_advisor/src/features/meal_capture/domain/meal_photo.dart';

/// System camera/library adapter. The source file is read and released here so
/// no platform path or picker object reaches the capture workflow.
class ImagePickerMealPhotoSource
    implements MealPhotoSource, MealPhotoSettingsOpener {
  ImagePickerMealPhotoSource({ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  @override
  Future<MealPhotoAcquisition> acquire(MealPhotoSourceType source) async {
    try {
      final file = await _picker.pickImage(
        source: source == MealPhotoSourceType.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        requestFullMetadata: false,
      );
      if (file == null) return const CancelledMealPhotoAcquisition();
      return _readAndRelease(
        file,
        deleteWhenRead: source == MealPhotoSourceType.camera,
      );
    } on PlatformException catch (error) {
      return FailedMealPhotoAcquisition(_mapPlatformFailure(error));
    } catch (_) {
      return const FailedMealPhotoAcquisition(PhotoSourceUnavailable());
    }
  }

  @override
  Future<MealPhotoAcquisition?> recoverLostData() async {
    try {
      final lost = await _picker.retrieveLostData();
      if (lost.isEmpty) {
        return null;
      }
      if (lost.exception != null) {
        return FailedMealPhotoAcquisition(_mapPlatformFailure(lost.exception!));
      }
      final file = lost.file;
      if (file == null) {
        return const FailedMealPhotoAcquisition(UnreadableMealPhoto());
      }
      return _readAndRelease(file, deleteWhenRead: true);
    } on PlatformException catch (error) {
      return FailedMealPhotoAcquisition(_mapPlatformFailure(error));
    } catch (_) {
      return const FailedMealPhotoAcquisition(PhotoSourceUnavailable());
    }
  }

  @override
  Future<void> openAppSettings() async {
    try {
      await const MethodChannel(
        'dev.mari0g.macroadvisor/photo_settings',
      ).invokeMethod<void>('openAppSettings');
    } catch (_) {
      // Settings recovery is best effort and must not expose platform details.
    }
  }

  Future<MealPhotoAcquisition> _readAndRelease(
    XFile file, {
    required bool deleteWhenRead,
  }) async {
    try {
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) {
        return const FailedMealPhotoAcquisition(UnreadableMealPhoto());
      }
      return AcquiredMealPhoto(bytes);
    } catch (_) {
      return const FailedMealPhotoAcquisition(UnreadableMealPhoto());
    } finally {
      if (deleteWhenRead) {
        await _deleteIfPresent(file.path);
      }
    }
  }

  Future<void> _deleteIfPresent(String path) async {
    if (path.isEmpty) {
      return;
    }
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {
      // Cache cleanup is best effort; this must not reveal the source path.
    }
  }

  MealPhotoFailure _mapPlatformFailure(PlatformException error) {
    final code = error.code.toLowerCase();
    if (code.contains('denied') || code.contains('permission')) {
      return PhotoPermissionDenied(
        permanentlyDenied: code.contains('permanent'),
      );
    }
    return const PhotoSourceUnavailable();
  }
}
