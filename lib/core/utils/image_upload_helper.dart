import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/repositories/bhandar_repository.dart';

class ImageUploadHelper {
  static final ImagePicker _picker = ImagePicker();

  /// Opens a cross-platform file picker to select an image, uploads it to the Google Cloud Storage bucket,
  /// and returns the uploaded Google Bucket public URL.
  static Future<String?> pickAndUploadImage({
    required BuildContext context,
    String folder = 'categories',
    void Function(bool isUploading)? onLoadingStateChanged,
  }) async {
    final repository = context.read<BhandarRepository>();
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return null;

      onLoadingStateChanged?.call(true);

      final bytes = await image.readAsBytes();
      final uploadedUrl = await repository.uploadImage(
        bytes: bytes,
        filename: image.name,
        folder: folder,
      );

      onLoadingStateChanged?.call(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image uploaded to Google Bucket: ${image.name}'),
            backgroundColor: const Color(0xFF10B981),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      return uploadedUrl;
    } catch (err) {
      onLoadingStateChanged?.call(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: $err'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
      return null;
    }
  }
}
