import 'dart:io';

/// Native targets: FCM initialization is gated to Android/iOS only
/// (PRD §6). Desktop stays healthy — the service no-ops there.
bool get isMobilePlatform => Platform.isAndroid || Platform.isIOS;
