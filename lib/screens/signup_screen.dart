import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_theme.dart';
import '../services/auth_flow.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _Country {
  final String flag, dial;
  const _Country(this.flag, this.dial);
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _repeat = TextEditingController();
  final _mobile = TextEditingController();
  bool _loading = false;

  static const _countries = [
    _Country('🇦🇴', '+244'), // Figma default
    _Country('🇮🇳', '+91'),
    _Country('🇺🇸', '+1'),
    _Country('🇬🇧', '+44'),
    _Country('🇦🇪', '+971'),
  ];
  _Country _country = _countries.first;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _repeat.dispose();
    _mobile.dispose();
    super.dispose();
  }

  String? _validate() {
    final email = _email.text.trim();
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)) {
      return 'Enter a valid email address';
    }
    if (_password.text.length < 6) return 'Password must be at least 6 characters';
    if (_password.text != _repeat.text) return 'Passwords do not match';
    if (_mobile.text.trim().length < 6) return 'Enter a valid mobile number';
    return null;
  }

  Future<void> _next() async {
    final error = _validate();
    if (error != null) {
      showAppSnack(context, error, error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await AuthService.instance
          .signUpWithEmail(_email.text.trim(), _password.text);
      if (!mounted) return;
      // Save sign-up details in Firestore -> snackbar -> Home
      await AuthFlow.complete(context, cred,
          phone: '${_country.dial}${_mobile.text.trim()}');
    } catch (e) {
      if (mounted) showAppSnack(context, AuthFlow.readable(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() => _loading = true);
    try {
      final cred = await AuthService.instance.signInWithGoogle();
      if (cred == null || !mounted) return;
      await AuthFlow.complete(context, cred);
    } catch (e) {
      if (mounted) showAppSnack(context, AuthFlow.readable(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _soon(String name) =>
      showAppSnack(context, '$name sign-in is not enabled in this demo.');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        leading: Navigator.of(context).canPop() ? const BackButton() : null,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 18.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              Text('Create Account',
                  style: AppText.poppins(18, weight: FontWeight.w700)),
              SizedBox(height: 12.h),
              Text('Sign Up', style: AppText.poppins(11)),
              SizedBox(height: 50.h),
              AuthField(
                  hint: 'Email',
                  icon: Icons.mail_outline,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress),
              SizedBox(height: 14.h),
              // Hint text kept exactly as written in the Figma file.
              AuthField(
                  hint: 'Special Characters',
                  icon: Icons.lock_outline,
                  controller: _password,
                  password: true),
              SizedBox(height: 14.h),
              AuthField(
                  hint: 'Repeat Password',
                  icon: Icons.lock_outline,
                  controller: _repeat,
                  password: true),
              SizedBox(height: 14.h),
              AuthField(
                hint: 'Mobile Number',
                icon: Icons.phone,
                controller: _mobile,
                keyboardType: TextInputType.phone,
                prefix: _CountryPicker(
                  value: _country,
                  items: _countries,
                  onChanged: (c) => setState(() => _country = c),
                ),
              ),
              SizedBox(height: 56.h),
              PrimaryButton(label: 'NEXT', loading: _loading, onPressed: _next),
              SizedBox(height: 28.h),
              SocialRow(
                showApple: true,
                onApple: () => _soon('Apple'),
                onGoogle: _google,
                onFacebook: () => _soon('Facebook'),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _CountryPicker extends StatelessWidget {
  final _Country value;
  final List<_Country> items;
  final ValueChanged<_Country> onChanged;
  const _CountryPicker(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<_Country>(
      onSelected: onChanged,
      itemBuilder: (_) => items
          .map((c) => PopupMenuItem(
              value: c, child: Text('${c.flag}  ${c.dial}')))
          .toList(),
      child: Padding(
        padding: EdgeInsets.only(left: 12.w, right: 6.w),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value.flag, style: TextStyle(fontSize: 15.sp)),
            SizedBox(width: 6.w),
            Text(value.dial, style: AppText.poppins(10, color: AppColors.grey)),
            Icon(Icons.keyboard_arrow_down, size: 16.r, color: AppColors.amber),
            SizedBox(width: 4.w),
          ],
        ),
      ),
    );
  }
}
