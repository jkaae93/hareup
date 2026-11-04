import 'package:flutter/widgets.dart';

import 'app_localizations.dart';

export 'app_localizations.dart';

/// Short accessor for the application localizations.
extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}

/// Korean first so unsupported device languages fall back to Korean.
const appSupportedLocales = [Locale('ko'), Locale('en')];
