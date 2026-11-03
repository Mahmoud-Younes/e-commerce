import 'package:firebase_auth/firebase_auth.dart';

/// Resolves the signed-in user's uid for the favorites/cart buttons.
///
/// Read lazily (on tap) so widgets can be pumped in tests without a
/// initialized Firebase app; returns `null` when Firebase is unavailable or
/// nobody is signed in.
String? currentUserId({FirebaseAuth? auth}) {
  try {
    return (auth ?? FirebaseAuth.instance).currentUser?.uid;
  } catch (_) {
    return null;
  }
}
