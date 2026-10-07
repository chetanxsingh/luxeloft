import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_assets.dart';
import '../core/app_theme.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  static const _lorem =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Pharetra quam elementum massa, viverra. Ut turpis consectetur.';

  static const _pages = [
    _OnboardData('ONLINE PAYMENT', AppAssets.onboardPayment),
    _OnboardData('ONLINE SHOPPING', AppAssets.onboardShopping),
    _OnboardData('HOME DELIVER SERVICE', AppAssets.onboardDelivery),
  ];

  void _goLogin() => Navigator.of(context)
      .pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));

  void _next() {
    if (_index == _pages.length - 1) {
      _goLogin();
    } else {
      _controller.nextPage(
          duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light
          .copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.teal,
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => SafeArea(
                  bottom: false,
                  child: Center(
                    child: SvgPicture.asset(_pages[i].asset,
                        width: 300.w, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
            // cream bottom sheet
            Container(
              width: double.infinity,
              height: 0.40.sh,
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, bottomInset),
              decoration: BoxDecoration(
                color: AppColors.cream,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(40.r)),
              ),
              child: Column(
                children: [
                  const Spacer(flex: 3),
                  Text(_pages[_index].title,
                      style: AppText.poppins(15,
                          weight: FontWeight.w700, color: AppColors.amber)),
                  SizedBox(height: 20.h),
                  Text(_lorem,
                      textAlign: TextAlign.center,
                      style: AppText.poppins(9.5,
                          color: const Color(0xFF4A4540), height: 1.7)),
                  const Spacer(flex: 3),
                  SizedBox(
                    height: 56.r,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        TextButton(
                          onPressed: _goLogin,
                          child: Text('Skip>>',
                              style: AppText.poppins(11,
                                  weight: FontWeight.w700,
                                  color: AppColors.amber)),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: _ArrowButton(onTap: _next),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(flex: 2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardData {
  final String title;
  final String asset;
  const _OnboardData(this.title, this.asset);
}

class _ArrowButton extends StatelessWidget {
  final VoidCallback onTap;
  const _ArrowButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.orange.withAlpha(110), width: 1.2),
        ),
        child: Container(
          width: 38.r,
          height: 38.r,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.orange,
            boxShadow: [
              BoxShadow(
                  color: AppColors.orange.withAlpha(120),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Icon(Icons.arrow_forward_rounded,
              color: Colors.white, size: 18.r),
        ),
      ),
    );
  }
}
