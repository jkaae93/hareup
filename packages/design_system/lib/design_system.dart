import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'l10n/design_localizations.dart';

export 'l10n/design_localizations.dart';

/// Short accessor for the design system localizations.
extension DesignLocalizationsX on BuildContext {
  DesignLocalizations get dsL10n => DesignLocalizations.of(this)!;
}

abstract final class HareupColors {
  static const primary100 = Color(0xffcce5ff);
  static const primary300 = Color(0xff93ccff);
  static const primary500 = Color(0xff007bb9);
  static const primary700 = Color(0xff006194);
  static const primary900 = Color(0xff001d31);
  static const secondary100 = Color(0xff6cf8bb);
  static const secondary300 = Color(0xff4edea3);
  static const secondary700 = Color(0xff006c49);
  static const secondary900 = Color(0xff005236);
  static const success100 = secondary100;
  static const success700 = secondary700;
  static const success900 = secondary900;
  static const warning100 = Color(0xffffddb8);
  static const warning700 = Color(0xff825100);
  static const warning900 = Color(0xff653e00);
  static const error100 = Color(0xffffdad6);
  static const error700 = Color(0xffba1a1a);
  static const error900 = Color(0xff93000a);
  static const neutral0 = Color(0xffffffff);
  static const neutral50 = Color(0xfff9f9ff);
  static const neutral100 = Color(0xfff0f3ff);
  static const neutral200 = Color(0xffe7eeff);
  static const neutral300 = Color(0xffdee8ff);
  static const neutral400 = Color(0xffbfc7d2);
  static const neutral700 = Color(0xff3f4850);
  static const neutral900 = Color(0xff111c2d);
  static const seed = primary700;
  static const background = neutral50;
  static const primaryContainer = primary100;
  static const secondary = secondary700;
  static const surfaceContainer = neutral200;
  static const onSurface = neutral900;
  static const onSurfaceVariant = neutral700;
  static const outline = neutral400;
}

abstract final class HareupTypography {
  static const family = 'Pretendard';
  static const display = TextStyle(
    fontSize: 30,
    height: 38 / 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.6,
  );
  static const heading = TextStyle(
    fontSize: 24,
    height: 32 / 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.24,
  );
  static const section = TextStyle(
    fontSize: 20,
    height: 28 / 20,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const titleLarge = TextStyle(
    fontSize: 18,
    height: 24 / 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const titleMedium = TextStyle(
    fontSize: 16,
    height: 22 / 16,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const bodyLarge = TextStyle(
    fontSize: 16,
    height: 24 / 16,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const bodyMedium = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const bodySmall = TextStyle(
    fontSize: 13,
    height: 18 / 13,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
  );
  static const labelLarge = TextStyle(
    fontSize: 14,
    height: 20 / 14,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const labelMedium = TextStyle(
    fontSize: 12,
    height: 16 / 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
  );
  static const labelSmall = TextStyle(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 0,
  );
}

abstract final class HareupSpacing {
  static const extraSmall = 4.0;
  static const small = 8.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const extraLarge = 32.0;

  /// Space for a floating action button and its clearance above the bottom.
  static const floatingActionClearance = 88.0;
  static const pageMargin = 20.0;
  static const maxContentWidth = 680.0;
}

/// Limits wide layouts without changing the child's scroll or state behavior.
class HareupContent extends StatelessWidget {
  const HareupContent({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        maxWidth: HareupSpacing.maxContentWidth,
      ),
      child: child,
    ),
  );
}

abstract final class HareupTheme {
  static ThemeData get light {
    const scheme = ColorScheme.light(
      primary: HareupColors.seed,
      onPrimary: HareupColors.neutral0,
      primaryContainer: HareupColors.primaryContainer,
      onPrimaryContainer: HareupColors.primary900,
      secondary: HareupColors.secondary,
      onSecondary: HareupColors.neutral0,
      secondaryContainer: HareupColors.secondary100,
      onSecondaryContainer: HareupColors.secondary900,
      tertiary: HareupColors.warning700,
      tertiaryContainer: HareupColors.warning100,
      onTertiaryContainer: HareupColors.warning900,
      error: HareupColors.error700,
      errorContainer: HareupColors.error100,
      onErrorContainer: HareupColors.error900,
      surface: HareupColors.background,
      onSurface: HareupColors.onSurface,
      onSurfaceVariant: HareupColors.onSurfaceVariant,
      outline: HareupColors.neutral700,
      outlineVariant: HareupColors.outline,
      surfaceContainerLowest: HareupColors.neutral0,
      surfaceContainerLow: HareupColors.neutral100,
      surfaceContainer: HareupColors.surfaceContainer,
      surfaceContainerHigh: HareupColors.neutral300,
    );
    const text = TextTheme(
      displaySmall: HareupTypography.display,
      headlineSmall: HareupTypography.heading,
      headlineMedium: HareupTypography.section,
      titleLarge: HareupTypography.titleLarge,
      titleMedium: HareupTypography.titleMedium,
      bodyLarge: HareupTypography.bodyLarge,
      bodyMedium: HareupTypography.bodyMedium,
      bodySmall: HareupTypography.bodySmall,
      labelLarge: HareupTypography.labelLarge,
      labelMedium: HareupTypography.labelMedium,
      labelSmall: HareupTypography.labelSmall,
    );
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    );
    WidgetStateProperty<Color?> overlay(Color color) =>
        WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return color.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.focused)) {
            return color.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered)) {
            return color.withValues(alpha: 0.08);
          }
          return null;
        });
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: HareupTypography.family,
      textTheme: text.apply(
        fontFamily: HareupTypography.family,
        bodyColor: scheme.onSurface,
        displayColor: scheme.onSurface,
      ),
      scaffoldBackgroundColor: HareupColors.background,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: HareupColors.background,
        foregroundColor: HareupColors.onSurface,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        color: HareupColors.neutral0,
        surfaceTintColor: Colors.transparent,
        elevation: 1,
        shadowColor: const Color(0x0a006194),
        margin: const EdgeInsets.symmetric(vertical: HareupSpacing.extraSmall),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: HareupColors.neutral200),
        ),
      ),
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(
          horizontal: HareupSpacing.medium,
          vertical: HareupSpacing.extraSmall,
        ),
        iconColor: HareupColors.seed,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style:
            FilledButton.styleFrom(
              minimumSize: const Size(48, 52),
              shape: shape,
              textStyle: HareupTypography.labelLarge,
            ).copyWith(
              backgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.disabled)) {
                  return HareupColors.neutral100;
                }
                if (states.contains(WidgetState.pressed)) {
                  return HareupColors.primary900;
                }
                if (states.contains(WidgetState.hovered)) {
                  return HareupColors.primary700;
                }
                return HareupColors.primary500;
              }),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? HareupColors.neutral400
                    : HareupColors.neutral0,
              ),
              side: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.focused)
                    ? const BorderSide(color: HareupColors.primary300, width: 2)
                    : BorderSide.none,
              ),
            ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style:
            OutlinedButton.styleFrom(
              minimumSize: const Size(48, 48),
              shape: shape,
              backgroundColor: HareupColors.neutral0,
              foregroundColor: HareupColors.primary500,
            ).copyWith(
              side: WidgetStateProperty.resolveWith(
                (states) => BorderSide(
                  color: states.contains(WidgetState.disabled)
                      ? HareupColors.neutral200
                      : states.contains(WidgetState.focused)
                      ? HareupColors.primary300
                      : HareupColors.primary500,
                  width: states.contains(WidgetState.focused) ? 2 : 1,
                ),
              ),
              foregroundColor: WidgetStateProperty.resolveWith(
                (states) => states.contains(WidgetState.disabled)
                    ? HareupColors.neutral400
                    : HareupColors.primary500,
              ),
              overlayColor: overlay(HareupColors.primary500),
            ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(48, 48),
          shape: shape,
        ).copyWith(overlayColor: overlay(HareupColors.primary700)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: HareupColors.neutral0,
        hintStyle: HareupTypography.bodyMedium.copyWith(
          color: HareupColors.neutral400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HareupColors.neutral300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HareupColors.neutral300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: HareupColors.primary500,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: HareupColors.error700,
            width: 1.5,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HareupColors.error700, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: HareupColors.neutral200),
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        overlayColor: overlay(HareupColors.primary500),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.disabled)) {
            return HareupColors.neutral100;
          }
          if (states.contains(WidgetState.selected)) {
            return HareupColors.primary500;
          }
          return HareupColors.neutral0;
        }),
        side: WidgetStateBorderSide.resolveWith(
          (states) => BorderSide(
            color: states.contains(WidgetState.disabled)
                ? HareupColors.neutral200
                : states.contains(WidgetState.selected)
                ? HareupColors.primary500
                : HareupColors.neutral400,
            width: 2,
          ),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? HareupColors.primary500
              : HareupColors.neutral400,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: HareupColors.background,
        indicatorColor: HareupColors.primary100,
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            color: states.contains(WidgetState.selected)
                ? HareupColors.primary700
                : HareupColors.neutral700,
            size: 24,
          ),
        ),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => HareupTypography.labelMedium.copyWith(
            color: states.contains(WidgetState.selected)
                ? HareupColors.primary700
                : HareupColors.neutral700,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: HareupColors.neutral0,
        selectedColor: HareupColors.primary100,
        disabledColor: HareupColors.neutral100,
        checkmarkColor: HareupColors.primary700,
        side: const BorderSide(color: HareupColors.neutral300),
        shape: const StadiumBorder(),
        labelStyle: HareupTypography.labelLarge.copyWith(
          color: HareupColors.neutral700,
        ),
        secondaryLabelStyle: HareupTypography.labelLarge.copyWith(
          color: HareupColors.primary700,
        ),
      ),
      iconTheme: const IconThemeData(
        color: HareupColors.onSurfaceVariant,
        size: 24,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: HareupColors.seed,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class HareupSectionHeader extends StatelessWidget {
  const HareupSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Wrap(
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: HareupSpacing.small,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      if (actionLabel != null && onAction != null)
        TextButton(onPressed: onAction, child: Text(actionLabel!)),
    ],
  );
}

/// A consistent surface for related content, sized to its available width.
class HareupPanel extends StatelessWidget {
  const HareupPanel({super.key, required this.child, this.color});
  final Widget child;
  final Color? color;

  @override
  Widget build(BuildContext context) => Card(
    color: color,
    child: Padding(
      padding: const EdgeInsets.all(HareupSpacing.medium),
      child: child,
    ),
  );
}

/// Tinted guidance panel for instructions and warnings.
class HareupGuidance extends StatelessWidget {
  const HareupGuidance({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.info_outline,
    this.warning = false,
  });
  final String title;
  final String message;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) => HareupPanel(
    color: warning ? HareupColors.error100 : HareupColors.neutral100,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: warning ? HareupColors.error700 : HareupColors.primary700,
        ),
        const SizedBox(width: HareupSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: HareupSpacing.extraSmall),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    ),
  );
}

class HareupFormSection extends StatelessWidget {
  const HareupFormSection({
    super.key,
    required this.title,
    required this.children,
    this.description,
  });
  final String title;
  final String? description;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => HareupPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (description != null) ...[
          const SizedBox(height: HareupSpacing.extraSmall),
          Text(description!, style: Theme.of(context).textTheme.bodyMedium),
        ],
        const SizedBox(height: HareupSpacing.medium),
        ...children,
      ],
    ),
  );
}

/// Highlights a measured or estimated value with its explanatory label.
class HareupMetric extends StatelessWidget {
  const HareupMetric({super.key, required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(HareupSpacing.medium),
    decoration: BoxDecoration(
      color: HareupColors.neutral100,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: HareupSpacing.extraSmall),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(color: HareupColors.primary700),
        ),
      ],
    ),
  );
}

/// Read-only content displayed as a full page.
class HareupTextDisplayPage extends StatelessWidget {
  const HareupTextDisplayPage({
    super.key,
    required this.title,
    required this.text,
  });
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: HareupContent(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(HareupSpacing.pageMargin),
        child: SelectableText(text),
      ),
    ),
  );
}

/// Editable nonnegative count with accessible increment and decrement controls.
class HareupCountField extends StatelessWidget {
  const HareupCountField({
    super.key,
    required this.controller,
    required this.label,
    required this.enabled,
  });
  final TextEditingController controller;
  final String label;
  final bool enabled;

  void _change(int delta) {
    final current = int.tryParse(controller.text) ?? 0;
    final next = (current + delta).clamp(0, 999999);
    controller.text = '$next';
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
  }

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: TextField(
          controller: controller,
          enabled: enabled,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: label),
        ),
      ),
      IconButton(
        tooltip: context.dsL10n.decreaseCount(label),
        onPressed: enabled ? () => _change(-1) : null,
        icon: const Icon(Icons.remove_circle_outline),
      ),
      IconButton(
        tooltip: context.dsL10n.increaseCount(label),
        onPressed: enabled ? () => _change(1) : null,
        icon: const Icon(Icons.add_circle_outline),
      ),
    ],
  );
}

/// Full-screen form with a scrollable body and persistent actions.
class HareupFormPage extends StatelessWidget {
  const HareupFormPage({
    super.key,
    required this.title,
    required this.content,
    required this.actions,
  });
  final Widget title;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: title),
    body: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: HareupSpacing.maxContentWidth,
        ),
        child: SizedBox.expand(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: HareupSpacing.pageMargin,
              vertical: HareupSpacing.medium,
            ),
            child: content,
          ),
        ),
      ),
    ),
    bottomNavigationBar: SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          HareupSpacing.pageMargin,
          HareupSpacing.small,
          HareupSpacing.pageMargin,
          HareupSpacing.medium,
        ),
        child: Align(
          alignment: Alignment.center,
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: HareupSpacing.maxContentWidth,
            ),
            child: SizedBox(
              width: double.infinity,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (actions.length == 2 &&
                      constraints.maxWidth >= 300 &&
                      MediaQuery.textScalerOf(context).scale(1) <= 1.2) {
                    return Row(
                      children: [
                        Expanded(child: actions.first),
                        const SizedBox(width: HareupSpacing.small),
                        Expanded(flex: 2, child: actions.last),
                      ],
                    );
                  }
                  return Wrap(
                    alignment: WrapAlignment.end,
                    spacing: HareupSpacing.small,
                    runSpacing: HareupSpacing.small,
                    children: actions,
                  );
                },
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

/// A route that returns entered text when the user submits, or null on back.
class HareupTextEntryPage extends StatefulWidget {
  const HareupTextEntryPage({
    super.key,
    required this.title,
    required this.label,
    required this.submitLabel,
    this.hint,
    this.maxLength,
    this.minLines = 1,
    this.maxLines = 1,
    this.capitalization = TextCapitalization.none,
    this.normalize,
    this.validate,
    this.initialValue = '',
  });
  final String title;
  final String label;
  final String submitLabel;
  final String? hint;
  final int? maxLength;
  final int minLines;
  final int maxLines;
  final TextCapitalization capitalization;
  final String Function(String)? normalize;
  final String? Function(String)? validate;
  final String initialValue;

  @override
  State<HareupTextEntryPage> createState() => _HareupTextEntryPageState();
}

class _HareupTextEntryPageState extends State<HareupTextEntryPage> {
  late final TextEditingController _controller;
  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    final value = _controller.text.trim();
    Navigator.pop(context, widget.normalize?.call(value) ?? value);
  }

  @override
  Widget build(BuildContext context) => HareupFormPage(
    title: Text(widget.title),
    content: Form(
      key: _form,
      child: SingleChildScrollView(
        child: TextFormField(
          controller: _controller,
          maxLength: widget.maxLength,
          minLines: widget.minLines,
          maxLines: widget.maxLines,
          textCapitalization: widget.capitalization,
          decoration: InputDecoration(
            labelText: widget.label,
            hintText: widget.hint,
          ),
          validator: (value) => widget.validate?.call(
            widget.normalize?.call(value?.trim() ?? '') ??
                (value?.trim() ?? ''),
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.dsL10n.cancelAction),
      ),
      FilledButton(onPressed: _submit, child: Text(widget.submitLabel)),
    ],
  );
}

enum HareupStatus { neutral, success, warning, error }

class HareupStatusBadge extends StatelessWidget {
  const HareupStatusBadge({
    super.key,
    required this.label,
    this.status = HareupStatus.neutral,
  });
  final String label;
  final HareupStatus status;

  @override
  Widget build(BuildContext context) {
    final (background, foreground, icon) = switch (status) {
      HareupStatus.neutral => (
        HareupColors.neutral200,
        HareupColors.primary700,
        Icons.info_outline,
      ),
      HareupStatus.success => (
        HareupColors.success100,
        HareupColors.success900,
        Icons.check_circle_outline,
      ),
      HareupStatus.warning => (
        HareupColors.warning100,
        HareupColors.warning900,
        Icons.warning_amber_outlined,
      ),
      HareupStatus.error => (
        HareupColors.error100,
        HareupColors.error900,
        Icons.error_outline,
      ),
    };
    return Align(
      alignment: Alignment.centerLeft,
      widthFactor: 1,
      child: Semantics(
        label: label,
        child: ExcludeSemantics(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: HareupSpacing.small,
              vertical: HareupSpacing.extraSmall,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: HareupSpacing.extraSmall),
                Flexible(
                  child: Text(
                    label,
                    style: Theme.of(
                      context,
                    ).textTheme.labelMedium?.copyWith(color: foreground),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows an optional photo with a labelled, accessible empty and error state.
class HareupPhotoPreview extends StatelessWidget {
  const HareupPhotoPreview({
    super.key,
    required this.bytes,
    required this.label,
    this.height = 140,
    this.fit = BoxFit.contain,
    this.emptyMessage,
    this.errorMessage,
  });
  final Uint8List? bytes;
  final String label;
  final double height;
  final BoxFit fit;
  final String? emptyMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) => Semantics(
    label: label,
    image: bytes != null,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        height: height,
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        child: bytes == null
            ? Center(
                child: Text(
                  emptyMessage ?? context.dsL10n.photoEmpty,
                  textAlign: TextAlign.center,
                ),
              )
            : Image.memory(
                bytes!,
                fit: fit,
                errorBuilder: (_, _, _) => Center(
                  child: Text(
                    errorMessage ?? context.dsL10n.photoError,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
      ),
    ),
  );
}

/// Displays two labelled photos with an adaptive layout for large text.
class HareupPhotoComparison extends StatelessWidget {
  const HareupPhotoComparison({
    super.key,
    required this.before,
    required this.after,
    this.beforeLabel,
    this.afterLabel,
  });
  final Uint8List? before;
  final Uint8List? after;
  final String? beforeLabel;
  final String? afterLabel;

  @override
  Widget build(BuildContext context) => HareupPanel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.dsL10n.photoCompareTitle,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: HareupSpacing.small),
        LayoutBuilder(
          builder: (context, constraints) {
            final resolvedBefore =
                beforeLabel ?? context.dsL10n.photoBeforeDefault;
            final resolvedAfter =
                afterLabel ?? context.dsL10n.photoAfterDefault;
            final stack =
                constraints.maxWidth < 260 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.5;
            Widget photo(String label, Uint8List? bytes) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: HareupSpacing.small),
                HareupPhotoPreview(bytes: bytes, label: label, height: 140),
              ],
            );
            if (stack) {
              return Column(
                children: [
                  photo(resolvedBefore, before),
                  const SizedBox(height: HareupSpacing.medium),
                  photo(resolvedAfter, after),
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: photo(resolvedBefore, before)),
                const SizedBox(width: HareupSpacing.small),
                Expanded(child: photo(resolvedAfter, after)),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class HareupPhotoActions extends StatelessWidget {
  const HareupPhotoActions({
    super.key,
    required this.onCamera,
    required this.onGallery,
    this.onRemove,
    this.prefix,
  });
  final VoidCallback? onCamera;
  final VoidCallback? onGallery;
  final VoidCallback? onRemove;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    final style = TextButton.styleFrom(
      backgroundColor: HareupColors.neutral200,
      foregroundColor: HareupColors.primary700,
      minimumSize: const Size(48, 48),
    );
    final resolvedPrefix = prefix ?? context.dsL10n.photoDefaultWord;
    final camera = TextButton.icon(
      style: style,
      onPressed: onCamera,
      icon: const Icon(Icons.photo_camera_outlined),
      label: Text(context.dsL10n.takePhoto(resolvedPrefix)),
    );
    final gallery = TextButton.icon(
      style: style,
      onPressed: onGallery,
      icon: const Icon(Icons.photo_library_outlined),
      label: Text(context.dsL10n.choosePhoto(resolvedPrefix)),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final sideBySide =
            constraints.maxWidth >= 300 &&
            MediaQuery.textScalerOf(context).scale(1) <= 1.2;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (sideBySide)
              Row(
                children: [
                  Expanded(child: camera),
                  const SizedBox(width: HareupSpacing.small),
                  Expanded(child: gallery),
                ],
              )
            else ...[
              camera,
              const SizedBox(height: HareupSpacing.small),
              gallery,
            ],
            if (onRemove != null)
              TextButton(
                onPressed: onRemove,
                child: Text(context.dsL10n.removePhoto),
              ),
          ],
        );
      },
    );
  }
}

class EmptyNotice extends StatelessWidget {
  const EmptyNotice({super.key, required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(HareupSpacing.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            color: Theme.of(context).colorScheme.primary,
            size: 32,
          ),
          const SizedBox(height: HareupSpacing.small),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}

class ErrorNotice extends StatelessWidget {
  const ErrorNotice({super.key, required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(HareupSpacing.large),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            color: Theme.of(context).colorScheme.error,
            size: 32,
          ),
          const SizedBox(height: HareupSpacing.small),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: HareupSpacing.small),
          TextButton(
            onPressed: onRetry,
            child: Text(context.dsL10n.retryAction),
          ),
        ],
      ),
    ),
  );
}

class HareupCard extends StatelessWidget {
  const HareupCard({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.onTap,
    this.trailing,
    this.isThreeLine = false,
  });
  final String title;
  final String? subtitle;
  final Widget? leading;
  final VoidCallback? onTap;
  final Widget? trailing;
  final bool isThreeLine;
  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: leading,
      title: Text(title),
      subtitle: subtitle == null ? null : Text(subtitle!),
      isThreeLine: isThreeLine,
      trailing:
          trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right)),
      onTap: onTap,
    ),
  );
}

class HareupLoading extends StatelessWidget {
  const HareupLoading({super.key});
  @override
  Widget build(BuildContext context) => Center(
    child: Semantics(
      label: context.dsL10n.loadingLabel,
      child: const CircularProgressIndicator(),
    ),
  );
}
