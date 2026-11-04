import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';

import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/family.dart';
import 'family_access_cubit.dart';

/// Entry point after authentication. The app should only enter Home after the
/// user selects an approved group from this page.
class FamilyAccessPage extends StatelessWidget {
  const FamilyAccessPage({
    super.key,
    required this.repository,
    required this.onFamilySelected,
  });

  final FamilyRepository repository;
  final ValueChanged<String> onFamilySelected;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => FamilyAccessCubit(repository)..load(),
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.familySelectTitle)),
      body: HareupContent(
        child: BlocConsumer<FamilyAccessCubit, FamilyAccessState>(
          listener: (context, state) {
            final failure = state.failure;
            if (failure != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(failureDisplayMessage(context, failure)),
                ),
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<FamilyAccessCubit>();
            return ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HareupSpacing.pageMargin,
                vertical: HareupSpacing.medium,
              ),
              children: [
                HareupStatusBadge(label: context.l10n.familyNestBadge),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  context.l10n.familySelectQuestion,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  context.l10n.familySelectHint,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: HareupSpacing.medium),
                for (final family in state.families)
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.home_outlined),
                      ),
                      title: Text(family.name),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => onFamilySelected(family.id),
                    ),
                  ),
                if (state.families.isEmpty && !state.isLoading)
                  EmptyNotice(message: context.l10n.familyEmptyMessage),
                if (state.pendingGroupId case final pendingId?) ...[
                  const SizedBox(height: HareupSpacing.medium),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.hourglass_top),
                      title: Text(context.l10n.familyPendingTitle),
                      subtitle: Text(context.l10n.familyPendingMessage),
                      trailing: IconButton(
                        tooltip: context.l10n.familyRefreshStatus,
                        onPressed: state.isLoading
                            ? null
                            : () => cubit.refreshJoinStatus(pendingId),
                        icon: const Icon(Icons.refresh),
                      ),
                    ),
                  ),
                ],
                if (state.isLoading)
                  const Padding(
                    padding: EdgeInsets.all(HareupSpacing.large),
                    child: HareupLoading(),
                  ),
                const SizedBox(height: HareupSpacing.large),
                HareupGuidance(
                  title: context.l10n.familyTogetherTitle,
                  message: context.l10n.familyTogetherMessage,
                  icon: Icons.favorite_border,
                ),
                const SizedBox(height: HareupSpacing.large),
                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _createFamily(context),
                  icon: const Icon(Icons.add_home_outlined),
                  label: Text(context.l10n.familyCreateAction),
                ),
                const SizedBox(height: HareupSpacing.small),
                FilledButton.icon(
                  onPressed: state.isLoading ? null : () => _enterCode(context),
                  icon: const Icon(Icons.key_outlined),
                  label: Text(context.l10n.familyEnterCodeAction),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );

  Future<void> _createFamily(BuildContext context) async {
    final name = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => HareupTextEntryPage(
          title: context.l10n.familyCreateAction,
          label: context.l10n.familyNameLabel,
          submitLabel: context.l10n.familyCreateSubmit,
          maxLength: 60,
          validate: (value) =>
              value.isEmpty ? context.l10n.familyNameRequired : null,
        ),
      ),
    );
    if (name == null || !context.mounted) return;
    final groupId = await context.read<FamilyAccessCubit>().createFamily(name);
    if (groupId != null && context.mounted) onFamilySelected(groupId);
  }

  Future<void> _enterCode(BuildContext context) async {
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => HareupTextEntryPage(
          title: context.l10n.familyEnterCodeAction,
          label: context.l10n.familyInviteCodeLabel,
          submitLabel: context.l10n.familyJoinRequestAction,
          maxLength: 12,
          capitalization: TextCapitalization.characters,
          normalize: (value) => value.toUpperCase(),
          validate: (value) => RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(value)
              ? null
              : context.l10n.familyInviteCodeInvalid,
        ),
      ),
    );
    if (code == null || !context.mounted) return;
    await context.read<FamilyAccessCubit>().requestToJoin(code);
  }
}
