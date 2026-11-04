import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/family.dart';
import 'family_cubit.dart';

class FamilyPage extends StatelessWidget {
  const FamilyPage({
    super.key,
    required this.repository,
    required this.groupId,
  });
  final FamilyRepository repository;
  final String groupId;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => FamilyCubit(repository, groupId)..load(),
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeManageFamily)),
      body: HareupContent(
        child: BlocBuilder<FamilyCubit, LoadState<FamilyOverview>>(
          builder: (context, state) => LoadView<FamilyOverview>(
            state: state,
            emptyMessage: context.l10n.familyOverviewEmpty,
            onRetry: () => context.read<FamilyCubit>().load(),
            builder: (context, family) => ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HareupSpacing.pageMargin,
                vertical: HareupSpacing.medium,
              ),
              children: [
                HareupGuidance(
                  title: context.l10n.familyTogetherTitle,
                  message: context.l10n.familyManageMessage,
                  icon: Icons.people_outline,
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: family.groupName,
                  description: context.l10n.familyCurrentSelected,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(child: Icon(Icons.home_outlined)),
                        const SizedBox(width: HareupSpacing.small),
                        Text(
                          context.l10n.familyMemberCount(family.members.length),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.large),
                HareupSectionHeader(
                  title: context.l10n.familyMembersHeader(
                    family.members.length,
                  ),
                ),
                if (family.members.isEmpty) Text(context.l10n.familyNoMembers),
                for (final member in family.members)
                  Card(
                    child: ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person_outline),
                      ),
                      title: Text(member.displayName),
                      subtitle: member.roleLabel == null
                          ? null
                          : Text(member.roleLabel!),
                      trailing: family.removableMemberIds.contains(member.id)
                          ? IconButton(
                              tooltip: context.l10n.familyRemoveMemberTooltip(
                                member.displayName,
                              ),
                              icon: const Icon(Icons.person_remove_outlined),
                              onPressed: () => _remove(context, member),
                            )
                          : null,
                    ),
                  ),
                if (family.canApproveJoinRequests) ...[
                  const SizedBox(height: HareupSpacing.large),
                  HareupSectionHeader(
                    title: context.l10n.familyPendingHeader(
                      family.joinRequests.length,
                    ),
                  ),
                  if (family.joinRequests.isEmpty)
                    HareupPanel(
                      child: Text(context.l10n.familyNoPendingRequests),
                    ),
                  for (final request in family.joinRequests)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.hourglass_top),
                        ),
                        title: Text(request.displayName),
                        subtitle: Text(
                          context.l10n.familyInvitePendingSubtitle,
                        ),
                        trailing: TextButton(
                          onPressed: () => _approve(context, request),
                          child: Text(context.l10n.familyApproveAction),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: HareupSpacing.large),
                HareupSectionHeader(title: context.l10n.familyInviteTitle),
                if (family.canCreateInviteCode)
                  HareupCard(
                    title: context.l10n.familyCreateCodeAction,
                    subtitle: context.l10n.familyCreateCodeMessage,
                    leading: const CircleAvatar(
                      child: Icon(Icons.key_outlined),
                    ),
                    onTap: () => _createCode(context),
                  ),
                HareupCard(
                  title: context.l10n.familyEnterCodeAction,
                  subtitle: context.l10n.familyEnterCodeMessage,
                  leading: const CircleAvatar(
                    child: Icon(Icons.group_add_outlined),
                  ),
                  onTap: () => _enterCode(context),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _createCode(BuildContext context) async {
    final cubit = context.read<FamilyCubit>();
    if (!await cubit.createInviteCode() || !context.mounted) {
      final command = cubit.createCodeCommand.state;
      if (command case CommandFailure<String>(:final failure)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failureDisplayMessage(context, failure))),
        );
      }
      return;
    }
    final code =
        (cubit.createCodeCommand.state as CommandSuccess<String>).value;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (dialogContext) => HareupFormPage(
          title: Text(dialogContext.l10n.familyInviteCodeTitle),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HareupFormSection(
                  title: dialogContext.l10n.familyDedicatedCodeTitle,
                  description: dialogContext.l10n.familyShareCodeMessage,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(HareupSpacing.large),
                      decoration: BoxDecoration(
                        color: HareupColors.neutral100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: SelectableText(
                        code,
                        textAlign: TextAlign.center,
                        style: Theme.of(dialogContext).textTheme.displaySmall
                            ?.copyWith(color: HareupColors.primary700),
                      ),
                    ),
                    const SizedBox(height: HareupSpacing.medium),
                    FilledButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: code));
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                              content: Text(
                                dialogContext.l10n.familyCodeCopied,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.content_copy),
                      label: Text(dialogContext.l10n.familyCopyCodeAction),
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupGuidance(
                  title: dialogContext.l10n.familyJoinGuideTitle,
                  message: dialogContext.l10n.familyJoinGuideMessage,
                  icon: Icons.info_outline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(dialogContext.l10n.commonClose),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _enterCode(BuildContext context) async {
    final cubit = context.read<FamilyCubit>();
    final code = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(
        builder: (_) => HareupTextEntryPage(
          title: context.l10n.familyEnterCodeAction,
          label: context.l10n.familyInviteCodeLabel,
          submitLabel: context.l10n.familyJoinRequestAction,
          maxLength: 12,
          capitalization: TextCapitalization.characters,
          normalize: (value) => value.toUpperCase(),
          validate: (value) => FamilyCubit.isValidInviteCode(value)
              ? null
              : context.l10n.familyInviteCodeInvalid,
        ),
      ),
    );
    if (code == null || !context.mounted) return;
    final requestedGroupId = await cubit.requestToJoin(code);
    if (!context.mounted) return;
    final message = requestedGroupId != null
        ? context.l10n.familyJoinRequested
        : _stringCommandFailure(context, cubit.joinCommand.state);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _approve(BuildContext context, FamilyJoinRequest request) async {
    final cubit = context.read<FamilyCubit>();
    final approved = await cubit.approve(request.id);
    if (!context.mounted) return;
    final message = approved
        ? context.l10n.familyApproved
        : _commandFailure(context, cubit.approveCommand.state);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _remove(BuildContext context, FamilyMember member) async {
    final cubit = context.read<FamilyCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.familyRemoveMemberTooltip(member.displayName)),
        content: Text(context.l10n.familyRemoveConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.dsL10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.familyRemoveAction),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final removed = await cubit.remove(member.id);
    if (!context.mounted) return;
    final message = removed
        ? context.l10n.familyMemberRemoved
        : _commandFailure(context, cubit.removeCommand.state);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _commandFailure(
    BuildContext context,
    CommandState<void> state,
  ) => state is CommandFailure<void>
      ? failureDisplayMessage(context, state.failure)
      : context.l10n.failureUnexpected;

  static String _stringCommandFailure(
    BuildContext context,
    CommandState<String> state,
  ) => state is CommandFailure<String>
      ? failureDisplayMessage(context, state.failure)
      : context.l10n.failureUnexpected;
}
