import 'dart:io' as io;

// import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter_native_image/flutter_native_image.dart';

class AppFilePicker {
  //
  static Future<CroppedFile?> cropImage(io.File imageFile) async {
    return await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatioPresets: io.Platform.isAndroid
          ? [
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio16x9
            ]
          : [
              CropAspectRatioPreset.original,
              CropAspectRatioPreset.square,
              CropAspectRatioPreset.ratio3x2,
              CropAspectRatioPreset.ratio4x3,
              CropAspectRatioPreset.ratio5x3,
              CropAspectRatioPreset.ratio5x4,
              CropAspectRatioPreset.ratio7x5,
              CropAspectRatioPreset.ratio16x9
            ],
    );
  }

  static Future<io.File?> pickImage({
    required ImageSource source,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? result = await picker.pickMedia(
        imageQuality: 100,
        maxHeight: 1000,
        maxWidth: 1000,
      );

      if (result != null) {
        final selectedFile = result;

        final crop = await cropImage(io.File(selectedFile.path));

        io.File compressedFile = await FlutterNativeImage.compressImage(
          crop!.path,
          percentage: 100,
          quality: 100,
          targetHeight: 500,
          targetWidth: 500,
        );

        return io.File(compressedFile.path);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<io.File?> pickFromCamera({
    required ImageSource source,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? result = await picker.pickImage(
        source: source,
        imageQuality: 100,
        maxHeight: 1000,
        maxWidth: 1000,
        preferredCameraDevice: CameraDevice.front,
      );

      if (result != null) {
        final selectedFile = result;

        final crop = await cropImage(io.File(selectedFile.path));

        io.File compressedFile = await FlutterNativeImage.compressImage(
          crop!.path,
          percentage: 100,
          quality: 100,
          targetHeight: 150,
          targetWidth: 150,
        );

        return io.File(compressedFile.path);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  static Future<List<io.File>?> pickMultiImages() async {
    try {
      final ImagePicker picker = ImagePicker();

      final List<XFile> result = await picker.pickMultiImage(
        imageQuality: 100,
        maxHeight: 1000,
        maxWidth: 1000,
      );

      if (result.isNotEmpty) {
        List<io.File> selectedFiles = [];

        for (var file in result) {
          io.File compressedFile = await FlutterNativeImage.compressImage(
            file.path,
            percentage: 100,
            quality: 100,
            targetHeight: 150,
            targetWidth: 150,
          );

          selectedFiles.add(io.File(compressedFile.path));
        }

        return selectedFiles;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

/*
  static Future<io.File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        withData: true,
        allowedExtensions: ['jpg', 'pdf', 'doc', 'docx'],
      );

      if (result != null) {
        PlatformFile platFormFile = result.files.first;

        final Uint8List uint8list = platFormFile.bytes!;
        final Directory tempDir = Directory.systemTemp;
        final File file = File('${tempDir.path}/${platFormFile.name}')
          ..writeAsBytesSync(uint8list);
        //convert platform to file

        // print(file.name);
        // print(file.bytes);
        // print(file.size);
        // print(file.extension);
        // print(file.path);

        return file;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  */
}
