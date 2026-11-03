import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'analytics.dart';

/// Only explicitly reviewed metric names and dimensions may reach Firebase.
class FirebaseAnalyticsAdapter implements AppAnalytics {
  FirebaseAnalyticsAdapter({
    required FirebaseAnalytics analytics,
    required FirebaseCrashlytics crashlytics,
    required Map<String, Set<String>> allowedParameters,
  }) : _analytics = analytics,
       _crashlytics = crashlytics,
       _allowedParameters = Map.unmodifiable(
         allowedParameters.map(
           (name, keys) => MapEntry(name, Set<String>.unmodifiable(keys)),
         ),
       );

  final FirebaseAnalytics _analytics;
  final FirebaseCrashlytics _crashlytics;
  final Map<String, Set<String>> _allowedParameters;

  @override
  Future<void> event(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {
    final allowed = _allowedParameters[name];
    if (allowed == null ||
        parameters.keys.any((key) => !allowed.contains(key))) {
      throw ArgumentError('Analytics event or parameter is not approved.');
    }
    await _analytics.logEvent(name: name, parameters: parameters);
  }

  @override
  Future<void> recordError(Object error, StackTrace stackTrace) async {
    // Do not forward exception text, which can contain response data or paths.
    await _crashlytics.recordError('Application error', stackTrace);
  }
}
