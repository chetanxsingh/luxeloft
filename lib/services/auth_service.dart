import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _google = GoogleSignIn();

  User? get currentUser => _auth.currentUser;

  // ---------- Phone / OTP ----------
  Future<void> sendOtp({
    required String phoneNumber, // E.164, e.g. +919876543210
    int? resendToken,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(UserCredential cred) onAutoVerified,
    required void Function(String message) onError,
  }) {
    return _auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      forceResendingToken: resendToken,
      timeout: const Duration(seconds: 60),
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Android may auto-retrieve the SMS.
        try {
          onAutoVerified(await _auth.signInWithCredential(credential));
        } on FirebaseAuthException catch (e) {
          onError(e.message ?? e.code);
        }
      },
      verificationFailed: (FirebaseAuthException e) =>
          onError(e.message ?? e.code),
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: (_) {},
    );
  }

  Future<UserCredential> verifyOtp(String verificationId, String smsCode) {
    final credential = PhoneAuthProvider.credential(
        verificationId: verificationId, smsCode: smsCode);
    return _auth.signInWithCredential(credential);
  }

  // ---------- Google ----------
  /// Returns null when the user cancels the picker.
  Future<UserCredential?> signInWithGoogle() async {
    final account = await _google.signIn();
    if (account == null) return null;
    final auth = await account.authentication;
    final credential = GoogleAuthProvider.credential(
        accessToken: auth.accessToken, idToken: auth.idToken);
    return _auth.signInWithCredential(credential);
  }

  // ---------- Email / password (Sign-up screen) ----------
  Future<UserCredential> signUpWithEmail(String email, String password) =>
      _auth.createUserWithEmailAndPassword(email: email, password: password);

  Future<void> signOut() async {
    await _google.signOut();
    await _auth.signOut();
  }
}
