import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../family/domain/family.dart';
import '../../family/presentation/family_page.dart';
import '../../litter_box/domain/litter_box.dart';
import '../../litter_box/presentation/litter_box_cubit.dart';
import '../../litter_box/presentation/litter_box_page.dart';
import '../../pet/domain/pet.dart';
import '../../settings/data/platform_settings_repository.dart';
import '../../settings/presentation/settings_page.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../photo_analysis/presentation/analysis_page.dart';
import '../../records/presentation/records_page.dart';
import '../../records/domain/record.dart';
import '../../records/presentation/recent_record_summary.dart';
import '../../pet/presentation/pet_cubit.dart';
import '../../pet/presentation/pet_page.dart';
import '../../water_bowl/domain/water_bowl.dart';
import '../../water_bowl/presentation/water_level_page.dart';
import '../../water_bowl/presentation/water_level_history_page.dart';
import '../../water_bowl/presentation/water_bowl_cubit.dart';
import '../../water_bowl/presentation/water_bowl_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onChangeFamily});
  final VoidCallback? onChangeFamily;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _recordsRevision = 0;

  List<Pet>? _pets(BuildContext context) =>
      switch (context.read<PetCubit>().state) {
        Loaded<List<Pet>>(:final data) => data,
        Empty<List<Pet>>() => const [],
        _ => null,
      };

  Future<void> _openWater(BuildContext context) async {
    final pets = _pets(context);
    if (pets == null) {
      _petError(context);
      return;
    }
    final waterBowlCubit = context.read<WaterBowlCubit>();
    final analysisRuntime = context.read<AnalysisRuntime>();
    final recordsRepository = context.read<RecordsRepository>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: waterBowlCubit,
          child: WaterBowlPage(
            pets: [
              for (final pet in pets) BowlPetOption(id: pet.id, name: pet.name),
            ],
            photoSource: PhotoPicker(),
            analysisRuntime: analysisRuntime,
            recordsRepository: recordsRepository,
          ),
        ),
      ),
    );
    if (mounted) setState(() => _recordsRevision++);
  }

  void _openPets(BuildContext context) {
    final cubit = context.read<PetCubit>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            BlocProvider.value(value: cubit, child: const PetPage()),
      ),
    );
  }

  Future<void> _openLitter(BuildContext context) async {
    final pets = _pets(context);
    if (pets == null) {
      _petError(context);
      return;
    }
    final cubit = context.read<LitterBoxCubit>();
    final runtime = context.read<AnalysisRuntime>();
    final records = context.read<RecordsRepository>();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MultiRepositoryProvider(
          providers: [
            RepositoryProvider<AnalysisRuntime>.value(value: runtime),
            RepositoryProvider<RecordsRepository>.value(value: records),
          ],
          child: BlocProvider.value(
            value: cubit,
            child: LitterBoxPage(
              cats: _catOptions(pets),
              photoSource: PhotoPicker(),
            ),
          ),
        ),
      ),
    );
    if (mounted) setState(() => _recordsRevision++);
  }

  Future<void> _openTargetPicker({required bool records}) async {
    final waters = switch (context.read<WaterBowlCubit>().state) {
      Loaded<List<WaterBowl>>(:final data) => data,
      Empty<List<WaterBowl>>() => <WaterBowl>[],
      _ => null,
    };
    final litters = switch (context.read<LitterBoxCubit>().state) {
      Loaded<List<LitterBox>>(:final data) => data,
      Empty<List<LitterBox>>() => <LitterBox>[],
      _ => null,
    };
    if (waters == null || litters == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('대상 목록을 확인한 뒤 다시 시도해 주세요.')));
      return;
    }
    final selected = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (pickerContext) => Scaffold(
          appBar: AppBar(title: Text(records ? '기록 대상 선택' : '사진 비교 대상 선택')),
          body: HareupContent(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HareupSpacing.pageMargin,
                vertical: HareupSpacing.medium,
              ),
              children: [
                Text(
                  records ? '기록을 확인할 대상을 선택해 주세요.' : '사진을 비교할 대상을 선택해 주세요.',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: HareupSpacing.medium),
                if (waters.isEmpty && litters.isEmpty)
                  const EmptyNotice(message: '먼저 물그릇이나 화장실을 등록해 주세요.'),
                if (waters.isNotEmpty) const HareupSectionHeader(title: '물그릇'),
                for (final bowl in waters)
                  HareupCard(
                    title: bowl.name,
                    leading: const CircleAvatar(
                      child: Icon(Icons.water_drop_outlined),
                    ),
                    onTap: () => Navigator.pop(pickerContext, bowl),
                  ),
                if (litters.isNotEmpty) const HareupSectionHeader(title: '화장실'),
                for (final box in litters)
                  HareupCard(
                    title: box.name,
                    leading: const CircleAvatar(
                      child: Icon(Icons.cleaning_services_outlined),
                    ),
                    onTap: () => Navigator.pop(pickerContext, box),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await _openTarget(selected, records: records);
  }

  Future<void> _openTarget(Object selected, {required bool records}) async {
    final runtime = context.read<AnalysisRuntime>();
    final repository = context.read<RecordsRepository>();
    final isWater = selected is WaterBowl;
    final id = isWater ? selected.id : (selected as LitterBox).id;
    final name = isWater ? selected.name : (selected as LitterBox).name;
    if (records) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => isWater
              ? WaterLevelHistoryPage(runtime: runtime, bowlId: id)
              : RepositoryProvider<RecordsRepository>.value(
                  value: repository,
                  child: RecordsPage(
                    groupId: runtime.groupId,
                    targetId: id,
                    targetName: name,
                  ),
                ),
        ),
      );
    } else {
      final pets = _pets(context);
      if (!isWater && pets == null) {
        _petError(context);
        return;
      }
      final page = switch (selected) {
        WaterBowl bowl => WaterLevelPage(
          bowl: bowl,
          photoSource: PhotoPicker(),
          runtime: runtime,
        ),
        LitterBox box => AnalysisPage(
          targetId: box.id,
          targetName: box.name,
          kind: AnalysisKind.litter,
          baseline: box.currentBaseline,
          photoSource: PhotoPicker(),
          runtime: runtime,
          cats: [
            for (final pet in pets!)
              if (box.catIds.contains(pet.id))
                AnalysisCat(id: pet.id, name: pet.name),
          ],
          widthCm: box.widthCm,
          lengthCm: box.lengthCm,
          litterHeightCm: box.litterHeightCm,
        ),
        _ => throw StateError('Unsupported target'),
      };
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => RepositoryProvider<RecordsRepository>.value(
            value: repository,
            child: page,
          ),
        ),
      );
    }
    if (mounted && isWater) await context.read<WaterBowlCubit>().load();
    if (mounted) setState(() => _recordsRevision++);
  }

  List<CatOption> _catOptions(List<Pet> pets) => [
    for (final pet in pets)
      if (pet.species == PetSpecies.cat) CatOption(id: pet.id, name: pet.name),
  ];
  void _petError(BuildContext context) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(const SnackBar(content: Text('반려동물 목록을 확인한 뒤 다시 시도해 주세요.')));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('하릅'),
      actions: [
        IconButton(
          tooltip: '설정',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SettingsPage(
                repository: const PlatformSettingsRepository(),
                onSignOut: context.read<AuthCubit>().signOut,
                displayName: context
                    .read<AuthCubit>()
                    .state
                    .session
                    ?.displayName,
                email: context.read<AuthCubit>().state.session?.email,
                pets: _pets(context) ?? const [],
              ),
            ),
          ),
        ),
        if (widget.onChangeFamily case final onChangeFamily?)
          IconButton(
            tooltip: '가족 바꾸기',
            icon: const Icon(Icons.switch_account_outlined),
            onPressed: onChangeFamily,
          ),
        IconButton(
          tooltip: '가족 관리',
          icon: const Icon(Icons.people_outline),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => FamilyPage(
                repository: context.read<FamilyRepository>(),
                groupId: context.read<AnalysisRuntime>().groupId,
              ),
            ),
          ),
        ),
      ],
    ),
    bottomNavigationBar: NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {
        switch (index) {
          case 1:
            _openWater(context);
          case 2:
            _openLitter(context);
          case 3:
            _openTargetPicker(records: false);
          case 4:
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => GroupRecordsPage(
                  repository: context.read<RecordsRepository>(),
                  groupId: context.read<AnalysisRuntime>().groupId,
                ),
              ),
            );
        }
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '홈',
        ),
        NavigationDestination(
          icon: Icon(Icons.water_drop_outlined),
          label: '물그릇',
        ),
        NavigationDestination(
          icon: Icon(Icons.cleaning_services_outlined),
          label: '화장실',
        ),
        NavigationDestination(
          icon: Icon(Icons.compare_outlined),
          label: '사진 비교',
        ),
        NavigationDestination(icon: Icon(Icons.history), label: '기록 목록'),
      ],
    ),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: HareupSpacing.maxContentWidth,
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: HareupSpacing.pageMargin,
            vertical: HareupSpacing.medium,
          ),
          children: [
            Text('함께 돌보는 하루', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: HareupSpacing.small),
            Text(
              '오늘도 반려동물의 일상을 살펴보세요.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: HareupSpacing.small),
            if (context.read<AnalysisRuntime>().groupId == 'local-development')
              const Text('개발 미리보기 · 데이터는 앱을 종료하면 사라집니다.'),
            const SizedBox(height: HareupSpacing.large),
            BlocBuilder<PetCubit, LoadState<List<Pet>>>(
              builder: (context, state) => _DashboardSection<Pet>(
                title: '반려동물',
                manageLabel: '반려동물 관리',
                state: state,
                empty: '반려동물을 등록해 주세요.',
                onManage: () => _openPets(context),
                onRetry: () => context.read<PetCubit>().load(),
                item: (pet) => ListTile(
                  leading: CircleAvatar(
                    foregroundImage: pet.profile.photoBytes == null
                        ? null
                        : MemoryImage(pet.profile.photoBytes!),
                    child: const Icon(Icons.pets),
                  ),
                  title: Text(pet.name),
                  subtitle: Text(pet.species == PetSpecies.cat ? '고양이' : '강아지'),
                  onTap: () => _openPets(context),
                ),
                count: (pets) => '반려동물 ${pets.length}마리',
              ),
            ),
            BlocBuilder<WaterBowlCubit, LoadState<List<WaterBowl>>>(
              builder: (context, state) => _DashboardSection<WaterBowl>(
                title: '물그릇',
                manageLabel: '물그릇 관리',
                state: state,
                empty: '물그릇을 등록해 주세요.',
                onManage: () => _openWater(context),
                onRetry: () => context.read<WaterBowlCubit>().load(),
                item: (bowl) => _TargetDashboardItem(
                  title: bowl.name,
                  photo: bowl.currentBaseline.photo,
                  icon: Icons.water_drop_outlined,
                  photoActionLabel: '사진 등록',
                  summary: Text(
                    bowl.levelProfile == null
                        ? '정수기 초기 설정이 필요합니다.'
                        : '수위 관찰을 시작할 수 있습니다.',
                  ),
                  onDetails: () async {
                    await showWaterBowlDetail(context, bowl, PhotoPicker());
                    if (mounted) setState(() => _recordsRevision++);
                  },
                  onRecords: () => _openTarget(bowl, records: true),
                  onCompare: () => _openTarget(bowl, records: false),
                ),
              ),
            ),
            BlocBuilder<LitterBoxCubit, LoadState<List<LitterBox>>>(
              builder: (context, state) => _DashboardSection<LitterBox>(
                title: '화장실',
                manageLabel: '화장실 관리',
                state: state,
                empty: '화장실을 등록해 주세요.',
                onManage: () => _openLitter(context),
                onRetry: () => context.read<LitterBoxCubit>().load(),
                item: (box) => _TargetDashboardItem(
                  title: box.name,
                  photo: box.currentBaseline.photo,
                  icon: Icons.cleaning_services_outlined,
                  photoActionLabel: '사진 비교',
                  summary: RecentRecordSummary(
                    key: ValueKey('litter-${box.id}-$_recordsRevision'),
                    repository: context.read<RecordsRepository>(),
                    groupId: context.read<AnalysisRuntime>().groupId,
                    targetId: box.id,
                    kind: AnalysisKind.litter,
                  ),
                  onDetails: () async {
                    final pets = _pets(context);
                    if (pets == null) {
                      _petError(context);
                      return;
                    }
                    await showLitterBoxDetail(
                      context,
                      box,
                      PhotoPicker(),
                      _catOptions(pets),
                    );
                    if (mounted) setState(() => _recordsRevision++);
                  },
                  onRecords: () => _openTarget(box, records: true),
                  onCompare: () => _openTarget(box, records: false),
                ),
              ),
            ),
            const SizedBox(height: HareupSpacing.medium),
            Card(
              color: HareupColors.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(HareupSpacing.medium),
                child: Text(
                  '사진 분석 결과는 추정 정보이며, 검증된 항목만 표시됩니다.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DashboardSection<T> extends StatelessWidget {
  const _DashboardSection({
    required this.title,
    required this.manageLabel,
    required this.state,
    required this.empty,
    required this.onManage,
    required this.onRetry,
    required this.item,
    this.count,
  });
  final String title;
  final String manageLabel;
  final LoadState<List<T>> state;
  final String empty;
  final VoidCallback onManage;
  final VoidCallback onRetry;
  final Widget Function(T) item;
  final String Function(List<T>)? count;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: HareupSpacing.large),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HareupSectionHeader(
          title: title,
          actionLabel: manageLabel,
          onAction: onManage,
        ),
        switch (state) {
          Initial<List<T>>() || Loading<List<T>>() => const Center(
            child: CircularProgressIndicator(),
          ),
          Empty<List<T>>() => Card(child: ListTile(title: Text(empty))),
          Failed<List<T>>(:final failure) => Row(
            children: [
              Expanded(child: Text(failure.message)),
              TextButton(onPressed: onRetry, child: const Text('다시 시도')),
            ],
          ),
          Loaded<List<T>>(:final data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (count != null) Text(count!(data)),
              for (final value in data) Card(child: item(value)),
            ],
          ),
        },
      ],
    ),
  );
}

class _TargetDashboardItem extends StatelessWidget {
  const _TargetDashboardItem({
    required this.title,
    required this.photo,
    required this.icon,
    required this.photoActionLabel,
    required this.summary,
    required this.onDetails,
    required this.onRecords,
    required this.onCompare,
  });
  final String title;
  final Uint8List photo;
  final IconData icon;
  final String photoActionLabel;
  final Widget summary;
  final VoidCallback onDetails;
  final VoidCallback onRecords;
  final VoidCallback onCompare;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(HareupSpacing.medium),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: CircleAvatar(child: Icon(icon)),
          title: Text(title, style: Theme.of(context).textTheme.titleMedium),
          trailing: const Icon(Icons.chevron_right),
          onTap: onDetails,
        ),
        Container(
          padding: const EdgeInsets.all(HareupSpacing.small),
          decoration: BoxDecoration(
            color: HareupColors.neutral100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 84,
                child: HareupPhotoPreview(
                  bytes: photo,
                  label: '$title 기준 사진',
                  height: 84,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: HareupSpacing.medium),
              Expanded(child: summary),
            ],
          ),
        ),
        const SizedBox(height: HareupSpacing.small),
        Wrap(
          spacing: HareupSpacing.small,
          runSpacing: HareupSpacing.extraSmall,
          alignment: WrapAlignment.end,
          children: [
            OutlinedButton.icon(
              onPressed: onRecords,
              icon: const Icon(Icons.history),
              label: const Text('기록 보기'),
            ),
            FilledButton.icon(
              onPressed: onCompare,
              icon: const Icon(Icons.photo_camera_outlined),
              label: Text(photoActionLabel),
            ),
          ],
        ),
      ],
    ),
  );
}
