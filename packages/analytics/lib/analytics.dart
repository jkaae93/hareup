abstract interface class AppAnalytics {
  Future<void> event(String name, {Map<String, Object> parameters = const {}});
  Future<void> recordError(Object error, StackTrace stackTrace);
}

class NoopAnalytics implements AppAnalytics {
  const NoopAnalytics();
  @override
  Future<void> event(
    String name, {
    Map<String, Object> parameters = const {},
  }) async {}
  @override
  Future<void> recordError(Object error, StackTrace stackTrace) async {}
}
