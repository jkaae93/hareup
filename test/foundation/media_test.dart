import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_media/media.dart';
import 'package:image_picker/image_picker.dart';

class FakeImagePicker extends ImagePicker {
  XFile? result;
  PlatformException? error;
  LostDataResponse? recovery;
  ImageSource? requestedSource;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    requestedSource = source;
    if (error case final value?) throw value;
    return result;
  }

  @override
  Future<LostDataResponse> retrieveLostData() async =>
      recovery ?? LostDataResponse.empty();
}

void main() {
  test('selection, cancellation and denied permission are distinct', () async {
    final fake = FakeImagePicker();
    final picker = PhotoPicker(picker: fake);
    expect(await picker.pickFromGallery(), isA<PhotoCancelled>());
    expect(fake.requestedSource, ImageSource.gallery);
    fake.result = XFile('example.jpg');
    expect(
      (await picker.pickFromCamera() as PhotoSelected).file.path,
      'example.jpg',
    );
    fake.error = PlatformException(code: 'camera_access_denied');
    final failure = await picker.pickFromCamera() as PhotoSelectionFailed;
    expect(failure.reason, PhotoFailureReason.permissionDenied);
  });

  test(
    'recovers interrupted Android picker and reports platform errors',
    () async {
      final fake = FakeImagePicker()
        ..recovery = LostDataResponse(files: [XFile('recovered.jpg')]);
      final picker = PhotoPicker(picker: fake);
      expect(
        (await picker.recoverInterruptedSelection() as PhotoSelected).file.path,
        'recovered.jpg',
      );
      fake.recovery = LostDataResponse(
        exception: PlatformException(code: 'unknown'),
      );
      expect(
        (await picker.recoverInterruptedSelection() as PhotoSelectionFailed)
            .reason,
        PhotoFailureReason.unavailable,
      );
    },
  );
}
