import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../core/app_assets.dart';
import '../core/app_theme.dart';
import '../services/auth_flow.dart';
import '../services/auth_service.dart';
import '../widgets/common_widgets.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  final String verificationId;
  final int? resendToken;
  const OtpScreen({
    super.key,
    required this.phone,
    required this.verificationId,
    this.resendToken,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _code = TextEditingController();
  final _focus = FocusNode();
  bool _loading = false;

  @override
  void dispose() {
    _code.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length != AppConfig.otpLength) {
      showAppSnack(context, 'Enter the ${AppConfig.otpLength}-digit code',
          error: true);
      return;
    }
    setState(() => _loading = true);
    try {
      final cred = await AuthService.instance.verifyOtp(widget.verificationId, code);
      if (!mounted) return;
      await AuthFlow.complete(context, cred, phone: widget.phone);
    } catch (e) {
      if (mounted) showAppSnack(context, AuthFlow.readable(e), error: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final box = ((1.sw - 48.w - (AppConfig.otpLength - 1) * 10.w) / AppConfig.otpLength)
        .clamp(34.0, 48.0).toDouble();
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              InkWell(
                onTap: () => Navigator.of(context).pop(),
                customBorder: const CircleBorder(),
                child: Container(
                  width: 36.r,
                  height: 36.r,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle, color: Color(0xFFDDE6DD)),
                  child: Icon(Icons.chevron_left, color: AppColors.teal, size: 22.r),
                ),
              ),
              SizedBox(height: 28.h),
              Center(
                child: Column(
                  children: [
                    Text('OTP Verification',
                        style: AppText.poppins(15, weight: FontWeight.w700)),
                    SizedBox(height: 10.h),
                    Text(
                      'Enter the verification code we just sent on your\nphone ${widget.phone}.',
                      textAlign: TextAlign.center,
                      style: AppText.poppins(9, color: const Color(0xFF5E5A55), height: 1.6),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 28.h),
              // One hidden TextField drives N visual boxes (supports paste + backspace).
              Center(
                child: GestureDetector(
                  onTap: () => _focus.requestFocus(),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: Listenable.merge([_code, _focus]),
                        builder: (_, __) => Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(AppConfig.otpLength, (i) {
                            final text = _code.text;
                            final filled = i < text.length;
                            final active = _focus.hasFocus &&
                                i == text.length.clamp(0, AppConfig.otpLength - 1);
                            return Container(
                              width: box,
                              height: box,
                              margin: EdgeInsets.only(
                                  right: i == AppConfig.otpLength - 1 ? 0 : 10.w),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: filled
                                    ? Colors.white
                                    : AppColors.fieldFill.withAlpha(110),
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                    color: active
                                        ? AppColors.teal
                                        : AppColors.fieldBorder,
                                    width: active ? 1.4 : 1),
                              ),
                              child: Text(filled ? text[i] : '',
                                  style: AppText.poppins(13, weight: FontWeight.w700)),
                            );
                          }),
                        ),
                      ),
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0,
                          child: TextField(
                            controller: _code,
                            focusNode: _focus,
                            autofocus: true,
                            keyboardType: TextInputType.number,
                            maxLength: AppConfig.otpLength,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            enableInteractiveSelection: false,
                            showCursor: false,
                            decoration: const InputDecoration(counterText: ''),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 24.h),
              PrimaryButton(label: 'VERIFY', loading: _loading, onPressed: _verify),
            ],
          ),
        ),
      ),
    );
  }
}
