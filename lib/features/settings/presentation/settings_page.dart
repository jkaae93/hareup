import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/settings.dart';
import '../../pet/domain/pet.dart';
import 'settings_cubit.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    required this.repository,
    this.onSignOut,
    this.displayName,
    this.email,
    this.pets = const [],
    this.languageOverride,
    this.onLanguageChanged,
  });
  final SettingsRepository repository;
  final Future<void> Function()? onSignOut;
  final String? displayName;
  final String? email;
  final List<Pet> pets;

  /// Current language override. Null follows the device language.
  final Locale? languageOverride;

  /// Invoked when the user picks a language. The section is hidden when null.
  final ValueChanged<Locale?>? onLanguageChanged;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SettingsCubit(repository)..load(),
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.settingsTitle)),
      body: HareupContent(
        child: BlocBuilder<SettingsCubit, LoadState<SettingsInfo>>(
          builder: (context, state) => LoadView<SettingsInfo>(
            state: state,
            emptyMessage: context.l10n.settingsEmptyMessage,
            onRetry: () => context.read<SettingsCubit>().load(),
            builder: (context, info) => _SettingsBody(
              info: info,
              onSignOut: onSignOut,
              displayName: displayName,
              email: email,
              pets: pets,
              languageOverride: languageOverride,
              onLanguageChanged: onLanguageChanged,
            ),
          ),
        ),
      ),
    ),
  );
}

class _SettingsBody extends StatelessWidget {
  const _SettingsBody({
    required this.info,
    this.onSignOut,
    this.displayName,
    this.email,
    required this.pets,
    this.languageOverride,
    this.onLanguageChanged,
  });
  final SettingsInfo info;
  final Future<void> Function()? onSignOut;
  final String? displayName;
  final String? email;
  final List<Pet> pets;
  final Locale? languageOverride;
  final ValueChanged<Locale?>? onLanguageChanged;
  @override
  Widget build(BuildContext context) {
    final cubit = context.read<SettingsCubit>();
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: HareupSpacing.pageMargin,
        vertical: HareupSpacing.medium,
      ),
      children: [
        if (displayName != null || email != null) ...[
          HareupPanel(
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 28,
                  child: Icon(Icons.person_outline),
                ),
                const SizedBox(width: HareupSpacing.medium),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName?.isNotEmpty == true
                            ? displayName!
                            : context.l10n.settingsMyAccount,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (email != null && email!.isNotEmpty)
                        Text(
                          email!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: HareupSpacing.large),
        ],
        if (pets.isNotEmpty) ...[
          HareupPanel(
            child: Row(
              children: [
                CircleAvatar(
                  foregroundImage: pets.first.profile.photoBytes == null
                      ? null
                      : MemoryImage(pets.first.profile.photoBytes!),
                  child: const Icon(Icons.pets_outlined),
                ),
                const SizedBox(width: HareupSpacing.medium),
                Expanded(
                  child: Text(
                    pets.length == 1
                        ? context.l10n.settingsPetSingle(pets.first.name)
                        : context.l10n.settingsPetCount(pets.length),
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (pets.length == 1)
                  Text(
                    pets.first.species == PetSpecies.cat
                        ? context.l10n.petSpeciesCat
                        : context.l10n.petSpeciesDog,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: HareupColors.primary500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: HareupSpacing.large),
        ],
        if (onLanguageChanged != null) ...[
          HareupSectionHeader(title: context.l10n.settingsLanguageTitle),
          const SizedBox(height: HareupSpacing.small),
          Card(
            child: Column(
              children: [
                _languageRow(
                  context,
                  null,
                  context.l10n.settingsLanguageSystem,
                ),
                const Divider(height: 1),
                _languageRow(context, const Locale('ko'), '한국어'),
                const Divider(height: 1),
                _languageRow(context, const Locale('en'), 'English'),
              ],
            ),
          ),
          const SizedBox(height: HareupSpacing.large),
        ],
        HareupSectionHeader(title: context.l10n.settingsNotificationTitle),
        const SizedBox(height: HareupSpacing.small),
        HareupPanel(
          child: Column(
            children: [
              _UnavailableNotificationRow(
                icon: Icons.water_drop_outlined,
                title: context.l10n.settingsWaterAlertTitle,
                subtitle: context.l10n.settingsWaterAlertMessage,
              ),
              const Divider(height: 1),
              _UnavailableNotificationRow(
                icon: Icons.favorite_border,
                title: context.l10n.settingsLitterAlertTitle,
                subtitle: context.l10n.settingsLitterAlertMessage,
              ),
              const Divider(height: 1),
              _UnavailableNotificationRow(
                icon: Icons.people_outline,
                title: context.l10n.settingsFamilySyncTitle,
                subtitle: context.l10n.settingsFamilySyncMessage,
              ),
            ],
          ),
        ),
        const SizedBox(height: HareupSpacing.large),
        HareupSectionHeader(title: context.l10n.settingsSupportTitle),
        const SizedBox(height: HareupSpacing.small),
        Card(
          child: Column(
            children: [
              _externalRow(
                context,
                cubit,
                context.l10n.settingsNoticeTitle,
                Icons.campaign_outlined,
                info.noticeUrl,
              ),
              const Divider(height: 1),
              _externalRow(
                context,
                cubit,
                context.l10n.settingsFaqTitle,
                Icons.help_outline,
                info.supportUrl,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.description_outlined),
                title: Text(context.l10n.settingsTermsTitle),
                trailing: Text(context.l10n.settingsComingSoon),
                enabled: false,
              ),
              const Divider(height: 1),
              _externalRow(
                context,
                cubit,
                context.l10n.settingsPrivacyTitle,
                Icons.verified_user_outlined,
                info.privacyUrl,
              ),
            ],
          ),
        ),
        const SizedBox(height: HareupSpacing.small),
        HareupCard(
          leading: const Icon(Icons.info_outline),
          title: context.l10n.settingsVersionTitle,
          subtitle: 'v${info.version} (${info.buildNumber})',
        ),
        const SizedBox(height: HareupSpacing.large),
        if (onSignOut != null)
          Column(
            children: [
              SizedBox(
                width: double.infinity,
                child: FilledButton.tonalIcon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Text(context.l10n.settingsSignOutAction),
                        content: Text(context.l10n.settingsSignOutConfirm),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: Text(dialogContext.dsL10n.cancelAction),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: Text(context.l10n.settingsSignOutAction),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await onSignOut!();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(context.l10n.settingsSignOutAction),
                ),
              ),
              const SizedBox(height: HareupSpacing.small),
              TextButton(
                onPressed: null,
                child: Text(context.l10n.settingsWithdrawHint),
              ),
            ],
          ),
      ],
    );
  }

  Widget _languageRow(BuildContext context, Locale? value, String label) {
    final selected = languageOverride == value;
    return ListTile(
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: () => onLanguageChanged!(value),
    );
  }

  Widget _externalRow(
    BuildContext context,
    SettingsCubit cubit,
    String title,
    IconData icon,
    Uri? uri,
  ) => BlocBuilder<Command1<void, Uri>, CommandState<void>>(
    bloc: cubit.openCommand,
    builder: (context, state) => ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: uri == null
          ? Text(context.l10n.settingsComingSoon)
          : const Icon(Icons.chevron_right),
      enabled: uri != null && state is! CommandRunning<void>,
      onTap: uri == null
          ? null
          : () async {
              if (cubit.openCommand.state is CommandRunning<void>) return;
              await cubit.openCommand.execute(uri);
              if (!context.mounted) return;
              if (cubit.openCommand.state case CommandFailure<void>(
                :final failure,
              )) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(failureDisplayMessage(context, failure)),
                  ),
                );
              }
            },
    ),
  );
}

class _UnavailableNotificationRow extends StatelessWidget {
  const _UnavailableNotificationRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: HareupSpacing.medium,
      vertical: HareupSpacing.small,
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: HareupColors.primaryContainer,
          foregroundColor: HareupColors.primary500,
          child: Icon(icon),
        ),
        const SizedBox(width: HareupSpacing.medium),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: HareupColors.neutral700),
              ),
            ],
          ),
        ),
        const Switch(value: false, onChanged: null),
      ],
    ),
  );
}
