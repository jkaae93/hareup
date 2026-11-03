import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

/// The result of asking the platform for a photo. Cancellation is not an error.
sealed class PhotoSelection {
  const PhotoSelection();
}

final class PhotoSelected extends PhotoSelection {
  const PhotoSelected(this.file);
  final XFile file;
}

final class PhotoCancelled extends PhotoSelection {
  const PhotoCancelled();
}

final class PhotoSelectionFailed extends PhotoSelection {
  const PhotoSelectionFailed(this.reason);
  final PhotoFailureReason reason;
}

enum PhotoFailureReason { permissionDenied, unavailable }

/// Wraps the native picker so a feature can distinguish cancellation from
/// access errors and replace the implementation in tests or previews.
abstract interface class PhotoSource {
  Future<PhotoSelection> pickFromCamera();
  Future<PhotoSelection> pickFromGallery();
  Future<PhotoSelection> recoverInterruptedSelection();
}

class PhotoPicker implements PhotoSource {
  PhotoPicker({ImagePicker? picker}) : _picker = picker ?? ImagePicker();
  final ImagePicker _picker;

  Future<PhotoSelection> _select(ImageSource source) async {
    try {
      final file = await _picker.pickImage(source: source);
      return file == null ? const PhotoCancelled() : PhotoSelected(file);
    } on PlatformException catch (error) {
      return PhotoSelectionFailed(_failureReason(error.code));
    } catch (_) {
      return const PhotoSelectionFailed(PhotoFailureReason.unavailable);
    }
  }

  @override
  Future<PhotoSelection> pickFromCamera() => _select(ImageSource.camera);

  @override
  Future<PhotoSelection> pickFromGallery() => _select(ImageSource.gallery);

  @override
  Future<PhotoSelection> recoverInterruptedSelection() async {
    try {
      final response = await _picker.retrieveLostData();
      if (response.exception case final error?) {
        return PhotoSelectionFailed(_failureReason(error.code));
      }
      final files = response.files;
      if (files != null && files.isNotEmpty) return PhotoSelected(files.first);
      final file = response.file;
      return file == null ? const PhotoCancelled() : PhotoSelected(file);
    } on PlatformException catch (error) {
      return PhotoSelectionFailed(_failureReason(error.code));
    } catch (_) {
      return const PhotoSelectionFailed(PhotoFailureReason.unavailable);
    }
  }

  static PhotoFailureReason _failureReason(String code) {
    switch (code) {
      case 'camera_access_denied':
      case 'photo_access_denied':
      case 'photos_access_denied':
        return PhotoFailureReason.permissionDenied;
      default:
        return PhotoFailureReason.unavailable;
    }
  }
}
