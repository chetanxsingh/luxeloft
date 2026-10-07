class AppAssets {
  // PNG exported from Figma
  static const logo = 'assets/images/logo.png';
  static const banner = 'assets/images/banner.png';
  // SVG exported from Figma
  static const onboardPayment = 'assets/svg/onboarding_payment.svg';
  static const onboardShopping = 'assets/svg/onboarding_shopping.svg';
  static const onboardDelivery = 'assets/svg/onboarding_delivery.svg';
}

class AppConfig {
  /// Used on the Login screen when the user types a number without "+".
  static const defaultDialCode = '+91';

  /// Firebase phone auth always sends a 6-digit code.
  /// (The Figma frame shows 4 boxes - change to 4 only if you use your own OTP backend.)
  static const otpLength = 6;
}
