import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_assets.dart';
import '../core/app_theme.dart';
import '../services/auth_flow.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';
import 'otp_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _phone.dispose();
    super.dispose();
  }

  String _normalize(String raw) {
    final digits = raw.replaceAll(RegExp(r'[\s\-()]'), '');
    return digits.startsWith('+') ? digits : '${AppConfig.defaultDialCode}$digits';
  }

  Future<void> _getOtp() async {
    final number = _normalize(_phone.text.trim());
    if (!RegExp(r'^\+\d{8,15}$').hasMatch(number)) {
      showAppSnack(context, 'Enter a valid phone number (e.g. +919876543210)',
          error: true);
      return;
    }
    setState(() => _loading = true);
    await AuthService.instance.sendOtp(
      phoneNumber: number,
      onCodeSent: (verificationId, token) {
        if (!mounted) return;
        setState(() => _loading = false);
        Navigator.of(context).push(MaterialPageRoute(
            builder: (_) => OtpScreen(
                phone: number, verificationId: verificationId, resendToken: token)));
      },
      onAutoVerified: (cred) async {
        if (!mounted) return;
        setState(() => _loading = false);
        await AuthFlow.complete(context, cred, phone: number);
      },
      onError: (msg) {
        if (!mounted) return;
        setState(() => _loading = false);
        showAppSnack(context, msg, error: true);
      },
    );
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      final cred = await AuthService.instance.signInWithGoogle();
      if (cred == null) return; // cancelled
      if (!mounted) return;
      await AuthFlow.complete(context, cred);
    } catch (e) {
      if (mounted) showAppSnack(context, AuthFlow.readable(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _comingSoon() =>
      showAppSnack(context, 'Facebook sign-in is not enabled in this demo.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Stack(
        children: [
          Positioned(top: -90.r, left: -90.r, child: CornerGlow(size: 230.r)),
          Positioned(bottom: -100.r, right: -100.r, child: CornerGlow(size: 260.r)),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                    minHeight: 1.sh -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(Icons.close, size: 22.r),
                        onPressed: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Image.asset(AppAssets.logo, width: 150.w),
                    SizedBox(height: 40.h),
                    Text('Welcome Back!',
                        style: AppText.poppins(18, weight: FontWeight.w700)),
                    SizedBox(height: 14.h),
                    Text('Login to continue', style: AppText.poppins(11)),
                    SizedBox(height: 32.h),
                    AuthField(
                      hint: 'Phone Number',
                      icon: Icons.smartphone_outlined,
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 22.h),
                    PrimaryButton(
                        label: 'GET OTP', loading: _loading, onPressed: _getOtp),
                    SizedBox(height: 70.h),
                    SocialRow(onGoogle: _google, onFacebook: _comingSoon),
                    SizedBox(height: 70.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("Don't have an account? ",
                            style: AppText.poppins(8.5)),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const SignUpScreen())),
                          child: Text('SIGN UP',
                              style: AppText.poppins(10,
                                      weight: FontWeight.w700,
                                      color: AppColors.teal)
                                  .copyWith(
                                      decoration: TextDecoration.underline,
                                      decorationColor: AppColors.teal)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
