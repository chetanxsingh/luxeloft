import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../core/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  const PrimaryButton(
      {super.key, required this.label, this.onPressed, this.loading = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          disabledBackgroundColor: AppColors.teal.withAlpha(180),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
        ),
        child: loading
            ? SizedBox(
                width: 20.r,
                height: 20.r,
                child: const CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white))
            : Text(label,
                style: AppText.poppins(13,
                    weight: FontWeight.w600, color: Colors.white)),
      ),
    );
  }
}

class AuthField extends StatefulWidget {
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final bool password;
  final TextInputType keyboardType;
  final Widget? prefix;

  const AuthField({
    super.key,
    required this.hint,
    required this.icon,
    required this.controller,
    this.password = false,
    this.keyboardType = TextInputType.text,
    this.prefix,
  });

  @override
  State<AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<AuthField> {
  bool _hidden = true;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(10.r),
      borderSide: const BorderSide(color: AppColors.fieldBorder),
    );
    return TextField(
      controller: widget.controller,
      obscureText: widget.password && _hidden,
      keyboardType: widget.keyboardType,
      style: AppText.poppins(11),
      decoration: InputDecoration(
        hintText: widget.hint,
        hintStyle: AppText.poppins(10, color: AppColors.grey),
        filled: true,
        fillColor: AppColors.fieldFill.withAlpha(110),
        contentPadding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 12.w),
        prefixIcon: widget.prefix ??
            Icon(widget.icon, size: 16.r, color: AppColors.grey),
        prefixIconConstraints: BoxConstraints(minWidth: 40.w),
        suffixIcon: widget.password
            ? IconButton(
                splashRadius: 16,
                icon: Icon(
                    _hidden
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 15.r,
                    color: AppColors.grey),
                onPressed: () => setState(() => _hidden = !_hidden),
              )
            : null,
        enabledBorder: border,
        border: border,
        focusedBorder: border.copyWith(
            borderSide: const BorderSide(color: AppColors.teal, width: 1.2)),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final Widget icon;
  final VoidCallback onTap;
  const SocialButton(
      {super.key, required this.label, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64.w,
        height: 50.h,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 3))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 16.r, height: 16.r, child: icon),
            SizedBox(height: 4.h),
            Text(label,
                style: AppText.poppins(8, weight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

const _googleSvg =
    '<svg viewBox="0 0 48 48"><path fill="#EA4335" d="M24 9.5c3.54 0 6.71 1.22 9.21 3.6l6.85-6.85C35.9 2.38 30.47 0 24 0 14.62 0 6.51 5.38 2.56 13.22l7.98 6.19C12.43 13.72 17.74 9.5 24 9.5z"/><path fill="#4285F4" d="M46.98 24.55c0-1.57-.15-3.09-.38-4.55H24v9.02h12.94c-.58 2.96-2.26 5.48-4.78 7.18l7.73 6c4.51-4.18 7.09-10.36 7.09-17.65z"/><path fill="#FBBC05" d="M10.53 28.59c-.48-1.45-.76-2.99-.76-4.59s.27-3.14.76-4.59l-7.98-6.19C.92 16.46 0 20.12 0 24c0 3.88.92 7.54 2.56 10.78l7.97-6.19z"/><path fill="#34A853" d="M24 48c6.48 0 11.93-2.13 15.89-5.81l-7.73-6c-2.15 1.45-4.92 2.3-8.16 2.3-6.26 0-11.57-4.22-13.47-9.91l-7.98 6.19C6.51 42.62 14.62 48 24 48z"/></svg>';

const _facebookSvg =
    '<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="12" fill="#1877F2"/><path fill="#fff" d="M16.67 15.47l.53-3.47h-3.33V9.75c0-.95.47-1.88 1.96-1.88h1.51V4.92s-1.37-.23-2.68-.23c-2.74 0-4.53 1.66-4.53 4.67V12H7.08v3.47h3.05V24h3.74v-8.53h2.8z"/></svg>';

class SocialIcons {
  static Widget google() => SvgPicture.string(_googleSvg);
  static Widget facebook() => SvgPicture.string(_facebookSvg);
  static Widget apple() => const Icon(Icons.apple, color: Colors.black, size: 18);
}

/// Row used on Login + Sign-up: "Or Continue With" + social buttons.
class SocialRow extends StatelessWidget {
  final bool showApple;
  final VoidCallback onGoogle;
  final VoidCallback onFacebook;
  final VoidCallback? onApple;
  const SocialRow({
    super.key,
    required this.onGoogle,
    required this.onFacebook,
    this.onApple,
    this.showApple = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Or Continue With', style: AppText.poppins(8, weight: FontWeight.w500)),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showApple) ...[
              SocialButton(label: 'Apple', icon: SocialIcons.apple(), onTap: onApple ?? () {}),
              SizedBox(width: 16.w),
            ],
            SocialButton(label: 'Google', icon: SocialIcons.google(), onTap: onGoogle),
            SizedBox(width: 16.w),
            SocialButton(label: 'Facebook', icon: SocialIcons.facebook(), onTap: onFacebook),
          ],
        ),
      ],
    );
  }
}

/// Soft orange glow used in the corners of the Login screen.
class CornerGlow extends StatelessWidget {
  final double size;
  const CornerGlow({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [Color(0x80FFA726), Color(0x00FFA726)],
        ),
      ),
    );
  }
}
