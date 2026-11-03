import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Required emulator endpoints. Production never falls back to an emulator.
class FirebaseEmulatorConfig {
  const FirebaseEmulatorConfig({
    required this.host,
    this.authPort = 9099,
    this.firestorePort = 8080,
    this.functionsPort = 5001,
    this.storagePort = 9199,
  });
  final String host;
  final int authPort;
  final int firestorePort;
  final int functionsPort;
  final int storagePort;
}

/// Services are bound to one explicitly supplied Firebase app, never to an
/// implicitly selected default project. Configure emulators before any use.
class HareupFirebaseServices {
  HareupFirebaseServices._({
    required this.app,
    required this.auth,
    required this.firestore,
    required this.functions,
    required this.storage,
  });

  final FirebaseApp app;
  final FirebaseAuth auth;
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final FirebaseStorage storage;

  static Future<HareupFirebaseServices> initialize({
    required FirebaseOptions options,
    required String appName,
    required String functionsRegion,
    FirebaseEmulatorConfig? emulators,
  }) async {
    if (appName.trim().isEmpty || functionsRegion.trim().isEmpty) {
      throw ArgumentError(
        'Firebase app name and functions region are required.',
      );
    }
    if (emulators != null && emulators.host.trim().isEmpty) {
      throw ArgumentError('Firebase emulator host is required.');
    }
    final app = await Firebase.initializeApp(name: appName, options: options);
    try {
      final auth = FirebaseAuth.instanceFor(app: app);
      final firestore = FirebaseFirestore.instanceFor(app: app);
      final functions = FirebaseFunctions.instanceFor(
        app: app,
        region: functionsRegion,
      );
      final storage = FirebaseStorage.instanceFor(app: app);
      if (emulators != null) {
        await auth.useAuthEmulator(emulators.host, emulators.authPort);
        firestore.useFirestoreEmulator(emulators.host, emulators.firestorePort);
        functions.useFunctionsEmulator(emulators.host, emulators.functionsPort);
        await storage.useStorageEmulator(emulators.host, emulators.storagePort);
      }
      return HareupFirebaseServices._(
        app: app,
        auth: auth,
        firestore: firestore,
        functions: functions,
        storage: storage,
      );
    } catch (_) {
      // Avoid leaving a partially configured named app after emulator failure.
      try {
        await app.delete();
      } catch (_) {
        // Preserve the original initialization error.
      }
      rethrow;
    }
  }
}
