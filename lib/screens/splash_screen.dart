import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_assets.dart';
import '../core/app_theme.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';
import 'onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted) return;
      final loggedIn = AuthService.instance.currentUser != null;
      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) =>
              loggedIn ? const MainShell() : const OnboardingScreen()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: Center(
        child: Image.asset(AppAssets.logo, width: 150.w),
      ),
    );
  }
}
