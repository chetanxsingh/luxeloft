import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/app_theme.dart';
import '../screens/main_shell.dart';
import 'firestore_service.dart';

/// Shared "after Firebase auth succeeded" step:
/// save the user in Firestore -> show snackbar -> go to Home.
class AuthFlow {
  static Future<void> complete(
    BuildContext context,
    UserCredential cred, {
    String? phone,
    String? name,
  }) async {
    final user = cred.user;
    if (user == null) throw Exception('No user returned from Firebase.');

    final isNew =
        await FirestoreService.instance.saveUser(user, phone: phone, name: name);

    if (!context.mounted) return;
    showAppSnack(
        context,
        isNew
            ? 'Account created & details saved successfully!'
            : 'Welcome back! Logged in successfully.');
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainShell()),
      (_) => false,
    );
  }

  static String readable(Object e) {
    if (e is FirebaseAuthException) return e.message ?? e.code;
    return e.toString().replaceFirst('Exception: ', '');
  }
}
