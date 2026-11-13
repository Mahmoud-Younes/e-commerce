/// Firestore collection paths (PRD §7) — the single source of truth.
/// Never hardcode collection strings in features; use these.
class Collections {
  static const String users = 'users';
  static const String categories = 'categories';
  static const String products = 'products';
  static const String orders = 'orders';
  static const String notifications = 'notifications';
}

/// Field names shared across features (keep in sync with PRD §7).
class UserFields {
  static const String name = 'name';
  static const String email = 'email';
  static const String phone = 'phone';
  static const String address = 'address';
  static const String role = 'role';

  /// SCALAR FCM registration token on `users/{uid}` — the source of truth
  /// for push delivery in this demo. Written by [FcmService] (see
  /// `_saveToken`), read by the server-side Admin SDK watcher that sends
  /// pushes. Multi-device token maps are out of scope.
  static const String fcmToken = 'fcmToken';

  /// Server timestamp of the last [fcmToken] write.
  static const String fcmTokenUpdatedAt = 'fcmTokenUpdatedAt';
}

class OrderFields {
  static const String userId = 'userId';
  static const String items = 'items';
  static const String totalPrice = 'totalPrice';
  static const String shippingAddress = 'shippingAddress';
  static const String phone = 'phone';
  static const String status = 'status';
  static const String createdAt = 'createdAt';
}

/// Supabase Storage config (product images; Firebase Storage requires Blaze).
/// Real project credentials — [url]/[publishableKey] are consumed by
/// `Supabase.initialize` in `lib/main.dart` (only when they are not
/// `YOUR_` placeholders, so the app boots without Supabase too).
class SupabaseConfig {
  static const String url = 'https://qshiwfcssobenpjijjxo.supabase.co';
  // Publishable key (supabase_flutter 2.18.3 named parameter; `anonKey` is
  // deprecated in this SDK version).
  static const String publishableKey =
      'sb_publishable_cdo7buZrUWExB_gqWmejCA_RnVyRc0Z';
  static const String productsBucket = 'product-images';
}

/// Role values stored on the user doc (mirror of [UserRole] enum names).
class UserRoleValues {
  static const String customer = 'customer';
  static const String admin = 'admin';
}
