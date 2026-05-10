import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ─── Auth State Provider ───────────────────────────────────────────────────
/// Single source of truth for Firebase authentication state.
/// Emits the current [User] (or null) whenever the auth state changes.

final firebaseAuthStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// ─── GoRouter Refresh Stream ───────────────────────────────────────────────
/// Converts the Firebase auth stream into a [ChangeNotifier] so GoRouter
/// can re-evaluate its `redirect` callback whenever the user signs in/out.

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // trigger initial evaluation
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
