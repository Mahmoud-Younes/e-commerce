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
  /// map of `{token: true}` entries on the user doc (PRD: "device-token data if needed").
  static const String fcmTokens = 'fcmTokens';
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
/// TODO(user): create the Supabase project + 'products' bucket and fill these.
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_PROJECT_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
  static const String productsBucket = 'products';
}

/// Role values stored on the user doc (mirror of [UserRole] enum names).
class UserRoleValues {
  static const String customer = 'customer';
  static const String admin = 'admin';
}
