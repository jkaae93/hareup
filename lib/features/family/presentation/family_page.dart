import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
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
      appBar: AppBar(title: const Text('가족 관리')),
      body: HareupContent(
        child: BlocBuilder<FamilyCubit, LoadState<FamilyOverview>>(
          builder: (context, state) => LoadView<FamilyOverview>(
            state: state,
            emptyMessage: '가족 정보를 찾을 수 없습니다.',
            onRetry: () => context.read<FamilyCubit>().load(),
            builder: (context, family) => ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HareupSpacing.pageMargin,
                vertical: HareupSpacing.medium,
              ),
              children: [
                const HareupGuidance(
                  title: '함께 돌보는 가족',
                  message: '가족 구성원과 반려동물의 사진 및 기록을 함께 확인할 수 있습니다.',
                  icon: Icons.people_outline,
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: family.groupName,
                  description: '현재 선택한 가족',
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(child: Icon(Icons.home_outlined)),
                        const SizedBox(width: HareupSpacing.small),
                        Text(
                          '가족 구성원 ${family.members.length}명',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.large),
                HareupSectionHeader(title: '가족 구성원 ${family.members.length}'),
                if (family.members.isEmpty) const Text('구성원이 없습니다.'),
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
                              tooltip: '${member.displayName} 제거',
                              icon: const Icon(Icons.person_remove_outlined),
                              onPressed: () => _remove(context, member),
                            )
                          : null,
                    ),
                  ),
                if (family.canApproveJoinRequests) ...[
                  const SizedBox(height: HareupSpacing.large),
                  HareupSectionHeader(
                    title: '가입 승인 대기 ${family.joinRequests.length}',
                  ),
                  if (family.joinRequests.isEmpty)
                    const HareupPanel(child: Text('승인 대기 중인 가입 요청이 없습니다.')),
                  for (final request in family.joinRequests)
                    Card(
                      child: ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.hourglass_top),
                        ),
                        title: Text(request.displayName),
                        subtitle: const Text('초대 코드 입력 후 승인 대기 중'),
                        trailing: TextButton(
                          onPressed: () => _approve(context, request),
                          child: const Text('승인'),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: HareupSpacing.large),
                const HareupSectionHeader(title: '가족 초대'),
                if (family.canCreateInviteCode)
                  HareupCard(
                    title: '초대 코드 만들기',
                    subtitle: '가족에게 전달할 코드를 발급합니다.',
                    leading: const CircleAvatar(
                      child: Icon(Icons.key_outlined),
                    ),
                    onTap: () => _createCode(context),
                  ),
                HareupCard(
                  title: '초대 코드 입력',
                  subtitle: '다른 가족에게 받은 코드로 가입을 요청합니다.',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
      }
      return;
    }
    final code =
        (cubit.createCodeCommand.state as CommandSuccess<String>).value;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (dialogContext) => HareupFormPage(
          title: const Text('가족 초대 코드'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                HareupFormSection(
                  title: '초대 전용 가족 코드',
                  description: '함께 돌볼 가족에게 이 코드를 전달해 주세요.',
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
                            const SnackBar(content: Text('초대 코드를 복사했습니다.')),
                          );
                        }
                      },
                      icon: const Icon(Icons.content_copy),
                      label: const Text('초대 코드 복사하기'),
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                const HareupGuidance(
                  title: '가족 합류 방법 안내',
                  message:
                      '가족이 로그인한 뒤 초대 코드를 입력하면 가입을 요청할 수 있습니다. 관리자가 승인하면 함께 이용할 수 있습니다.',
                  icon: Icons.info_outline,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('닫기'),
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
          title: '초대 코드 입력',
          label: '초대 코드',
          submitLabel: '가입 요청',
          maxLength: 12,
          capitalization: TextCapitalization.characters,
          normalize: (value) => value.toUpperCase(),
          validate: (value) => FamilyCubit.isValidInviteCode(value)
              ? null
              : '6~12자의 영문 또는 숫자를 입력해 주세요.',
        ),
      ),
    );
    if (code == null || !context.mounted) return;
    final requestedGroupId = await cubit.requestToJoin(code);
    if (!context.mounted) return;
    final message = requestedGroupId != null
        ? '가입 요청을 보냈습니다. 관리자의 승인을 기다려 주세요.'
        : _stringCommandFailure(cubit.joinCommand.state);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _approve(BuildContext context, FamilyJoinRequest request) async {
    final cubit = context.read<FamilyCubit>();
    final approved = await cubit.approve(request.id);
    if (!context.mounted) return;
    final message = approved
        ? '가입을 승인했습니다.'
        : _commandFailure(cubit.approveCommand.state);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _remove(BuildContext context, FamilyMember member) async {
    final cubit = context.read<FamilyCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${member.displayName} 제거'),
        content: const Text('이 구성원의 가족 정보 접근이 중단됩니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('제거'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final removed = await cubit.remove(member.id);
    if (!context.mounted) return;
    final message = removed
        ? '구성원을 제거했습니다.'
        : _commandFailure(cubit.removeCommand.state);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _commandFailure(CommandState<void> state) =>
      state is CommandFailure<void> ? state.failure.message : '요청을 처리하지 못했습니다.';

  static String _stringCommandFailure(CommandState<String> state) =>
      state is CommandFailure<String>
      ? state.failure.message
      : '요청을 처리하지 못했습니다.';
}
