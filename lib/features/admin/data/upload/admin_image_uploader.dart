import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/helpers/constants.dart';
import '../../../../core/networking/api_error_handler.dart';
import '../../../../core/networking/api_error_model.dart';
import '../../../../core/networking/api_result.dart';

/// Uploads admin product images (PRD §2: product image).
///
/// TODO(user/owner): [SupabaseConfig.url] and [SupabaseConfig.anonKey] are
/// still placeholders (see `lib/core/helpers/constants.dart`). Create the
/// Supabase project + `products` bucket and fill the config — until then
/// [SupabaseAdminImageUploader.isConfigured] is false and the admin product
/// form falls back to the manual `imageUrl` text field only.
///
/// get_it registration (merge agent applies it):
/// ```dart
/// getIt.registerLazySingleton<AdminImageUploader>(() => SupabaseAdminImageUploader());
/// ```
abstract class AdminImageUploader {
  /// Whether [SupabaseConfig] holds real values. When false the UI keeps the
  /// manual `imageUrl` field and never calls [upload].
  bool get isConfigured;

  /// Upload [bytes] as [fileName] to the Supabase `products` bucket and
  /// return its public URL (to be stored in `products/{id}.imageUrl`).
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
      _isReal(SupabaseConfig.url) && _isReal(SupabaseConfig.anonKey);

  @override
  Future<ApiResult<String>> upload({
    required Uint8List bytes,
    required String fileName,
  }) async {
    if (!isConfigured) {
      // Placeholder config — never touch Supabase.instance (it is not even
      // initialized in main.dart yet).
      return const ApiResult.failure(
        ApiErrorModel(
          message:
              'Image upload is not configured yet. Enter an image URL manually.',
        ),
      );
    }
    try {
      final bucket = Supabase.instance.client.storage
          .from(SupabaseConfig.productsBucket);
      final path = 'products/${DateTime.now().microsecondsSinceEpoch}_$fileName';
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
