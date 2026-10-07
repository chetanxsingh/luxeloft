# LuxeLoft – Flutter Assignment (Figma UI + Firebase)

Screens: Splash → Onboarding (3) → Login (Phone OTP / Google) → OTP Verification → Sign-up → Home (all data from Firestore).

Responsive: every size is scaled from the Figma frame (375 × 812) with `flutter_screenutil`.
Assets: logo, banner and the 3 onboarding illustrations are the files exported from Figma (`assets/`).

---------------------------------------------------------------------------
## Step-by-step setup

### 1. Prerequisites
- Flutter SDK (3.22+), Android Studio / Xcode
- Node.js (for the Firebase CLI)
- A Google account

### 2. Generate the platform folders (android / ios)
This zip contains `lib/`, `assets/` and `pubspec.yaml`. Create the native projects in-place:
```bash
cd luxeloft
flutter create . --project-name luxeloft --org com.mxpertz --platforms=android,ios
flutter pub get
```
(The package name becomes `com.mxpertz.luxeloft` – you may change `--org`.)

### 3. Install Firebase CLI + FlutterFire CLI
```bash
npm install -g firebase-tools
firebase login
dart pub global activate flutterfire_cli
# make sure ~/.pub-cache/bin is on your PATH:
export PATH="$PATH":"$HOME/.pub-cache/bin"        # Windows: add %LOCALAPPDATA%\Pub\Cache\bin
```

### 4. Create the Firebase project and link it with FlutterFire
```bash
flutterfire configure
```
- pick **Create a new project** (or an existing one)
- select **android** and **ios**
This **overwrites `lib/firebase_options.dart`** and adds `google-services.json` / `GoogleService-Info.plist`.

### 5. Enable Authentication (Firebase Console → Build → Authentication → Get started)
| Provider | Used for | Notes |
|---|---|---|
| **Phone** | Login → GET OTP | Add *test phone numbers* (e.g. `+91 99999 99999` → `123456`) to avoid SMS billing / limits |
| **Google** | Google button | Set the project support e-mail |
| **Email/Password** | Sign-up screen | |

**Android SHA-1 / SHA-256 (required for Phone + Google):**
```bash
cd android && ./gradlew signingReport        # Windows: gradlew signingReport
# or: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```
Console → Project settings → your Android app → **Add fingerprint** (SHA-1 and SHA-256).
Then re-run `flutterfire configure` (or download the new `google-services.json` into `android/app/`).

**Android minSdk:** open `android/app/build.gradle(.kts)` and set `minSdk = 23` (Firebase requires ≥ 23).

**iOS (only if you run on iOS):** open `ios/Runner/Info.plist`, add `REVERSED_CLIENT_ID` from `GoogleService-Info.plist` as a URL scheme (Google sign-in), and for phone auth enable Push/Background modes or use reCAPTCHA fallback.

### 6. Create Cloud Firestore
Console → Build → Firestore Database → **Create database** → start in **test mode** (so you can add data), location nearest to you.

### 7. Add the home-screen data (backend-driven)
Either **type it in the console**, or quickest: run the app in debug, log in, and **long-press the logo on Home** – it writes the sample data below automatically.

| Collection / doc | Fields |
|---|---|
| `app_config/home` | `headline` (string) = "What are you looking for today?" |
| `banners/{id}` | `order` (number), `imageUrl` (string, optional URL), `asset` (string, optional: `assets/images/banner.png`) |
| `tabs/{id}` | `title` (string), `order` (number), `isDefault` (bool) – titles: Recommend, Cell Phone, Car Products, Department Store, Computer |
| `categories/{id}` | `title`, `order`, `icon` (beauty / offers / fashion / home / shirt / bag / dress / mobiles) and/or `iconUrl` (image URL) |
| `products/{id}` | `name`, `price` (number), `rating` (number), `reviews` (number), `tab` (must equal a tab title; "Recommend" tab shows all), `imageUrl` (URL), `order` |
| `users/{uid}` | written automatically on sign-up / login (uid, email, phone, name, provider, createdAt, lastLoginAt) |

Greeting ("Hi, Andrea") uses `users/{uid}.name`; if empty it falls back to Google display name / e-mail prefix.
You can edit a document in the console while the app is open – the UI updates live (Firestore streams).

### 8. Lock the database down (after data is added)
```bash
firebase init firestore        # choose your project, keep firestore.rules
firebase deploy --only firestore:rules
```
(`firestore.rules` is included: users read/write only their own doc; home content is read-only for signed-in users.)

### 9. Run
```bash
flutter run
```

---------------------------------------------------------------------------
## Flow summary
- **Login → GET OTP** → `FirebaseAuth.verifyPhoneNumber` → **OTP screen** → verify → user saved to `users/{uid}` → snackbar → Home
- **Sign-up → NEXT** → e-mail/password account → details (email, phone, provider) saved to Firestore → snackbar "Account created & details saved successfully!" → Home
- **Google button** (Login + Sign-up) → Google sign-in → saved to Firestore → snackbar → Home
- Apple / Facebook buttons are UI-only (show a snackbar) – the assignment asks for OTP **or** Google.

## Notes / deliberate choices
- Phone numbers on Login: type with country code (`+91…`); without `+` the app prefixes `AppConfig.defaultDialCode` (`lib/core/app_assets.dart`).
- OTP boxes: Firebase sends **6-digit** codes, so 6 boxes are drawn (Figma shows 4). Change `AppConfig.otpLength` if needed.
- Password hint "Special Characters" is kept exactly as written in Figma.
- `assets/images/*_reference.png` are the exported nav/category strips kept for reference; the live nav & categories are built in code so they are interactive and Firestore-driven.

## Project structure
```
lib/
  main.dart                  app + ScreenUtil (375x812)
  firebase_options.dart      generated by flutterfire configure
  core/                      theme, colors, text styles, asset paths
  models/                    Firestore models
  services/                  auth_service, firestore_service, auth_flow, seed_service
  screens/                   splash, onboarding, login, otp, signup, main_shell, home
  widgets/                   buttons, fields, social buttons
assets/images, assets/svg    exported from Figma
```
