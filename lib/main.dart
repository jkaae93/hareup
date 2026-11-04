import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/locale_store.dart';
import 'firebase_options.dart';
import 'l10n/l10n.dart';
import 'features/auth/data/apple_auth_provider.dart';
import 'features/auth/data/firebase_auth_repository.dart';
import 'features/auth/data/google_auth_provider.dart';
import 'features/auth/data/kakao_auth_provider.dart';
import 'features/family/data/firebase_family_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final localeStore = SharedPreferencesLocaleStore(
    await SharedPreferences.getInstance(),
  );
  final initialLocale = await localeStore.load();
  if (kIsWeb && !DefaultFirebaseOptions.hasWebConfiguration) {
    runApp(_FirebaseWebSetupApp(initialLocale: initialLocale));
    return;
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  const kakaoNativeAppKey = String.fromEnvironment('KAKAO_NATIVE_APP_KEY');
  if (!kIsWeb && kakaoNativeAppKey.isNotEmpty) {
    KakaoSdk.init(nativeAppKey: kakaoNativeAppKey);
  }
  final functions = FirebaseFunctions.instanceFor(region: 'us-central1');
  runApp(
    HareupApp(
      authRepository: FirebaseAuthRepository(
        auth: FirebaseAuth.instance,
        providers: [
          GoogleAuthProviderAdapter(),
          if (!kIsWeb) const AppleFederatedAuthProvider(),
          if (!kIsWeb && kakaoNativeAppKey.isNotEmpty)
            const KakaoAuthProvider(),
        ],
      ),
      familyRepository: FirebaseFamilyRepository(functions: functions),
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
      functions: functions,
      localeStore: localeStore,
      initialLocale: initialLocale,
    ),
  );
}

class _FirebaseWebSetupApp extends StatelessWidget {
  const _FirebaseWebSetupApp({this.initialLocale});

  final Locale? initialLocale;

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => context.l10n.appTitle,
    theme: HareupTheme.light,
    locale: initialLocale,
    supportedLocales: appSupportedLocales,
    localizationsDelegates: [
      ...AppLocalizations.localizationsDelegates,
      DesignLocalizations.delegate,
    ],
    home: Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(HareupSpacing.medium),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: HareupSpacing.maxContentWidth,
              ),
              child: Text(
                context.l10n.mainWebSetupMessage,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
