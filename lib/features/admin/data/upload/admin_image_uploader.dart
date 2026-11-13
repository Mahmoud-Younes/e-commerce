import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';

/// Uploads admin product images (PRD §2: product image).
///
/// Uses the real Supabase project from [SupabaseConfig] (public
/// `product-images` bucket). This uploader does NOT initialize the Supabase
/// SDK itself — `Supabase.initialize` happens once in `lib/main.dart`, and
/// only when the config holds real values. When
/// [SupabaseAdminImageUploader.isConfigured] is false (placeholder config)
/// the admin product form falls back to the manual `imageUrl` text field.
///
/// get_it registration (merge agent applies it):
/// ```dart
/// getIt.registerLazySingleton<AdminImageUploader>(() => SupabaseAdminImageUploader());
/// ```
abstract class AdminImageUploader {
  /// Whether [SupabaseConfig] holds real values. When false the UI keeps the
  /// manual `imageUrl` field and never calls [upload].
  bool get isConfigured;

  /// Upload [bytes] as [fileName] to the Supabase `product-images` bucket
  /// and return its public URL (to be stored in `products/{id}.imageUrl`).
  Future<ApiResult<String>> upload({
    required Uint8List bytes,
    required String fileName,
  });
}

class SupabaseAdminImageUploader implements AdminImageUploader {
  SupabaseAdminImageUploader();

  static bool _isReal(String value) =>
      value.isNotEmpty && !value.startsWith('YOUR_');

  @override
  bool get isConfigured =>
      _isReal(SupabaseConfig.url) && _isReal(SupabaseConfig.publishableKey);

  @override
  Future<ApiResult<String>> upload({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!isConfigured) {
      // Placeholder config — never touch Supabase.instance (it is only
      // initialized in main.dart when the config is real).
      return const ApiResult.failure(
        ApiErrorModel(
          message: 'Image upload is not configured yet. Enter an image URL manually.',
        ),
      );
    }
    try {
      final bucket = Supabase.instance.client.storage.from(
        SupabaseConfig.productsBucket,
      );
      final path =
          'products/${DateTime.now().microsecondsSinceEpoch}_$fileName';
      await bucket.uploadBinary(
        path,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );
      return ApiResult.success(bucket.getPublicUrl(path));
    } catch (error) {
      return ApiResult.failure(ApiErrorHandler.handle(error));
    }
  }
}
