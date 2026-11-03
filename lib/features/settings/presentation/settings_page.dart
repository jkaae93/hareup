import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
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
  });
  final SettingsRepository repository;
  final Future<void> Function()? onSignOut;
  final String? displayName;
  final String? email;
  final List<Pet> pets;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => SettingsCubit(repository)..load(),
    child: Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: HareupContent(
        child: BlocBuilder<SettingsCubit, LoadState<SettingsInfo>>(
          builder: (context, state) => LoadView<SettingsInfo>(
            state: state,
            emptyMessage: '설정 정보가 없습니다.',
            onRetry: () => context.read<SettingsCubit>().load(),
            builder: (context, info) => _SettingsBody(
              info: info,
              onSignOut: onSignOut,
              displayName: displayName,
              email: email,
              pets: pets,
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
  });
  final SettingsInfo info;
  final Future<void> Function()? onSignOut;
  final String? displayName;
  final String? email;
  final List<Pet> pets;
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
                        displayName?.isNotEmpty == true ? displayName! : '내 계정',
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
                        ? '등록된 반려동물: ${pets.first.name}'
                        : '등록된 반려동물 ${pets.length}마리',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                if (pets.length == 1)
                  Text(
                    pets.first.species == PetSpecies.cat ? '고양이' : '강아지',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: HareupColors.primary500,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: HareupSpacing.large),
        ],
        const HareupSectionHeader(title: '스마트 안심 알림 설정'),
        const SizedBox(height: HareupSpacing.small),
        HareupPanel(
          child: Column(
            children: const [
              _UnavailableNotificationRow(
                icon: Icons.water_drop_outlined,
                title: '물그릇 사진 분석 알림',
                subtitle: '물그릇 관찰 알림 기능은 준비 중입니다.',
              ),
              Divider(height: 1),
              _UnavailableNotificationRow(
                icon: Icons.favorite_border,
                title: '화장실 이상 징후 알림',
                subtitle: '화장실 관찰 알림 기능은 준비 중입니다.',
              ),
              Divider(height: 1),
              _UnavailableNotificationRow(
                icon: Icons.people_outline,
                title: '가족 돌봄 기록 실시간 동기화',
                subtitle: '가족 기록은 앱에서 확인할 수 있습니다.',
              ),
            ],
          ),
        ),
        const SizedBox(height: HareupSpacing.large),
        const HareupSectionHeader(title: '앱 정보 및 지원'),
        const SizedBox(height: HareupSpacing.small),
        Card(
          child: Column(
            children: [
              _externalRow(
                context,
                cubit,
                '공지사항 및 업데이트 소식',
                Icons.campaign_outlined,
                info.noticeUrl,
              ),
              const Divider(height: 1),
              _externalRow(
                context,
                cubit,
                '자주 묻는 질문 및 문의',
                Icons.help_outline,
                info.supportUrl,
              ),
              const Divider(height: 1),
              const ListTile(
                leading: Icon(Icons.description_outlined),
                title: Text('서비스 이용약관'),
                trailing: Text('준비 중'),
                enabled: false,
              ),
              const Divider(height: 1),
              _externalRow(
                context,
                cubit,
                '개인정보처리방침',
                Icons.verified_user_outlined,
                info.privacyUrl,
              ),
            ],
          ),
        ),
        const SizedBox(height: HareupSpacing.small),
        HareupCard(
          leading: const Icon(Icons.info_outline),
          title: '앱 버전 정보',
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
                        title: const Text('로그아웃'),
                        content: const Text('이 기기에서 로그아웃할까요?'),
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(dialogContext, false),
                            child: const Text('취소'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.pop(dialogContext, true),
                            child: const Text('로그아웃'),
                          ),
                        ],
                      ),
                    );
                    if (confirmed == true && context.mounted) {
                      await onSignOut!();
                    }
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('로그아웃'),
                ),
              ),
              const SizedBox(height: HareupSpacing.small),
              TextButton(onPressed: null, child: const Text('하릅 회원 탈퇴 · 준비 중')),
            ],
          ),
      ],
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
          ? const Text('준비 중')
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
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(failure.message)));
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
