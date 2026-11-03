/// Firestore paths (PRD §7) — the single source of truth for every document
/// and collection path in the app. Never hardcode path strings in features;
/// use these builders so the structure stays consistent everywhere.
///
/// PRD §7 table mapping:
/// | Collection / Path      | Fields                                                    |
/// | users                  | name, email, phone, address, role, device-token data      |
/// | products               | name, description, price, imageUrl, category, stock, isAvailable |
/// | users/{uid}/cart       | productId, quantity (product ID is the document ID)       |
/// | users/{uid}/favorites  | productId per item (product ID is the document ID)        |
/// | orders                 | userId, items, totalPrice, shippingAddress, phone, status, createdAt |
/// | notifications          | userId, title, body, orderId, isRead, createdAt           |
class FirestorePaths {
  FirestorePaths._();

  // ============================= ROOT COLLECTIONS =============================

  /// `users/{uid}` — profile docs (see [UserModel] in features/auth).
  static const String users = 'users';

  /// `products` — catalog docs (see [ProductModel] in core/models).
  static const String products = 'products';

  /// `orders` — order docs (see [OrderModel] in core/models).
  static const String orders = 'orders';

  /// `notifications` — in-app notification center docs (PRD §6, optional).
  static const String notifications = 'notifications';

  // ============================ USERS SUB-COLLECTIONS =========================

  /// `users/{uid}/cart` — one doc per cart line; the product ID is used as
  /// the document ID (PRD §7), so add/remove are idempotent.
  static String cartCollection(String uid) => 'users/$uid/cart';

  /// `users/{uid}/cart/{productId}` — a single cart line.
  static String cartDoc(String uid, String productId) =>
      'users/$uid/cart/$productId';

  /// `users/{uid}/favorites` — one doc per favorite; the product ID is used
  /// as the document ID, so toggle = add/delete of that doc.
  static String favoritesCollection(String uid) => 'users/$uid/favorites';

  /// `users/{uid}/favorites/{productId}` — a single favorite reference.
  static String favoriteDoc(String uid, String productId) =>
      'users/$uid/favorites/$productId';

  // =============================== DOC BUILDERS ==============================

  /// `users/{uid}` — a single user profile doc.
  static String userDoc(String uid) => 'users/$uid';

  /// `products/{productId}` — a single catalog doc.
  static String productDoc(String productId) => 'products/$productId';

  /// `orders/{orderId}` — a single order doc.
  static String orderDoc(String orderId) => 'orders/$orderId';

  /// `notifications/{notificationId}` — a single notification doc.
  static String notificationDoc(String notificationId) =>
      'notifications/$notificationId';
}
