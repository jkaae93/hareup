import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';

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
      appBar: AppBar(title: const Text('가족 선택')),
      body: HareupContent(
        child: BlocConsumer<FamilyAccessCubit, FamilyAccessState>(
          listener: (context, state) {
            final message = state.failureMessage;
            if (message != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(message)));
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
                const HareupStatusBadge(label: '우리 가족 보금자리'),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  '어떤 가족과 함께 돌볼까요?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  '승인된 가족을 선택해 계속하세요.',
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
                  const EmptyNotice(
                    message: '참여 중인 가족이 없습니다. 가족을 만들거나 초대 코드를 입력하세요.',
                  ),
                if (state.pendingGroupId case final pendingId?) ...[
                  const SizedBox(height: HareupSpacing.medium),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.hourglass_top),
                      title: const Text('관리자 승인 대기 중'),
                      subtitle: const Text('승인 후 새로고침하면 가족을 선택할 수 있습니다.'),
                      trailing: IconButton(
                        tooltip: '승인 상태 새로고침',
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
                const HareupGuidance(
                  title: '함께 돌보는 가족',
                  message: '가족 구성원이 같은 반려동물의 기록을 함께 확인할 수 있어요.',
                  icon: Icons.favorite_border,
                ),
                const SizedBox(height: HareupSpacing.large),
                OutlinedButton.icon(
                  onPressed: state.isLoading
                      ? null
                      : () => _createFamily(context),
                  icon: const Icon(Icons.add_home_outlined),
                  label: const Text('가족 만들기'),
                ),
                const SizedBox(height: HareupSpacing.small),
                FilledButton.icon(
                  onPressed: state.isLoading ? null : () => _enterCode(context),
                  icon: const Icon(Icons.key_outlined),
                  label: const Text('초대 코드 입력'),
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
          title: '가족 만들기',
          label: '가족 이름',
          submitLabel: '만들기',
          maxLength: 60,
          validate: (value) => value.isEmpty ? '가족 이름을 입력해 주세요.' : null,
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
          title: '초대 코드 입력',
          label: '초대 코드',
          submitLabel: '가입 요청',
          maxLength: 12,
          capitalization: TextCapitalization.characters,
          normalize: (value) => value.toUpperCase(),
          validate: (value) => RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(value)
              ? null
              : '6~12자의 영문 또는 숫자를 입력해 주세요.',
        ),
      ),
    );
    if (code == null || !context.mounted) return;
    await context.read<FamilyAccessCubit>().requestToJoin(code);
  }
}
