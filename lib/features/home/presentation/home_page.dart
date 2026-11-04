import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../app/locale_cubit.dart';
import '../../../l10n/l10n.dart';
import '../../auth/presentation/auth_cubit.dart';
import '../../family/domain/family.dart';
import '../../family/presentation/family_page.dart';
import '../../health_chat/domain/health_chat.dart';
import '../../health_chat/presentation/health_chat_page.dart';
import '../../litter_box/domain/litter_box.dart';
import '../../litter_box/presentation/litter_box_cubit.dart';
import '../../litter_box/presentation/litter_box_page.dart';
import '../../pet/domain/pet.dart';
import '../../shared_data/target_widgets.dart';
import '../../settings/data/platform_settings_repository.dart';
import '../../settings/presentation/settings_page.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../photo_analysis/presentation/analysis_page.dart';
import '../../records/presentation/records_page.dart';
import '../../records/domain/record.dart';
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
  }

  void _openPets(BuildContext context) {
    final cubit = context.read<PetCubit>();
    final water = context.read<WaterBowlCubit>().repository;
    final litter = context.read<LitterBoxCubit>().repository;
    final records = context.read<RecordsRepository>();
    final runtime = context.read<AnalysisRuntime>();
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: PetPage(
            waterRepository: water,
            litterRepository: litter,
            recordsRepository: records,
            runtime: runtime,
          ),
        ),
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
      ).showSnackBar(SnackBar(content: Text(context.l10n.homeTargetListError)));
      return;
    }
    final selected = await Navigator.of(context).push<Object>(
      MaterialPageRoute(
        builder: (pickerContext) => Scaffold(
          appBar: AppBar(
            title: Text(
              records
                  ? pickerContext.l10n.homePickRecordsTarget
                  : pickerContext.l10n.homePickCompareTarget,
            ),
          ),
          body: HareupContent(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: HareupSpacing.pageMargin,
                vertical: HareupSpacing.medium,
              ),
              children: [
                Text(
                  records
                      ? pickerContext.l10n.homePickRecordsHint
                      : pickerContext.l10n.homePickCompareHint,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: HareupSpacing.medium),
                if (waters.isEmpty && litters.isEmpty)
                  EmptyNotice(message: pickerContext.l10n.homeNoTargets),
                if (waters.isNotEmpty)
                  HareupSectionHeader(title: pickerContext.l10n.navWater),
                for (final bowl in waters)
                  HareupCard(
                    title: bowl.name,
                    leading: const CircleAvatar(
                      child: Icon(Icons.water_drop_outlined),
                    ),
                    onTap: () => Navigator.pop(pickerContext, bowl),
                  ),
                if (litters.isNotEmpty)
                  HareupSectionHeader(title: pickerContext.l10n.navLitter),
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
  }

  List<CatOption> _catOptions(List<Pet> pets) => [
    for (final pet in pets)
      if (pet.species == PetSpecies.cat) CatOption(id: pet.id, name: pet.name),
  ];
  void _petError(BuildContext context) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(context.l10n.homePetError)));

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.appTitle),
      actions: [
        IconButton(
          tooltip: context.l10n.chatAssistantLabel,
          icon: const Icon(Icons.chat_bubble_outline),
          onPressed: () {
            final pets = _pets(context);
            if (pets == null) {
              _petError(context);
              return;
            }
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => HealthChatPage(
                  repository: context.read<HealthChatRepository>(),
                  groupId: context.read<AnalysisRuntime>().groupId,
                  pets: pets,
                  photoSource: PhotoPicker(),
                ),
              ),
            );
          },
        ),
        IconButton(
          tooltip: context.l10n.settingsTitle,
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SettingsPage(
                repository: const PlatformSettingsRepository(),
                onSignOut: context.read<AuthCubit>().signOut,
                languageOverride: context.read<LocaleCubit>().state,
                onLanguageChanged: context.read<LocaleCubit>().setOverride,
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
            tooltip: context.l10n.homeSwitchFamily,
            icon: const Icon(Icons.switch_account_outlined),
            onPressed: onChangeFamily,
          ),
        IconButton(
          tooltip: context.l10n.homeManageFamily,
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
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: context.l10n.navHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.water_drop_outlined),
          label: context.l10n.navWater,
        ),
        NavigationDestination(
          icon: const Icon(Icons.cleaning_services_outlined),
          label: context.l10n.navLitter,
        ),
        NavigationDestination(
          icon: const Icon(Icons.compare_outlined),
          label: context.l10n.navCompare,
        ),
        NavigationDestination(
          icon: const Icon(Icons.history),
          label: context.l10n.navRecords,
        ),
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
            Text(
              context.l10n.homeHeadline,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: HareupSpacing.small),
            Text(
              context.l10n.homeSubheadline,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: HareupSpacing.small),
            if (context.read<AnalysisRuntime>().groupId == 'local-development')
              Text(context.l10n.homeLocalPreview),
            const SizedBox(height: HareupSpacing.large),
            BlocBuilder<PetCubit, LoadState<List<Pet>>>(
              builder: (context, state) => _DashboardSection<Pet>(
                title: context.l10n.homePetTitle,
                manageLabel: context.l10n.petManageTitle,
                state: state,
                empty: context.l10n.homePetEmpty,
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
                  subtitle: Text(
                    pet.species == PetSpecies.cat
                        ? context.l10n.petSpeciesCat
                        : context.l10n.petSpeciesDog,
                  ),
                  onTap: () => _openPets(context),
                ),
                count: (pets) => context.l10n.homePetCount(pets.length),
              ),
            ),
            BlocBuilder<WaterBowlCubit, LoadState<List<WaterBowl>>>(
              builder: (context, state) => _DashboardSection<WaterBowl>(
                title: context.l10n.navWater,
                manageLabel: context.l10n.homeWaterManage,
                state: state,
                empty: context.l10n.homeWaterEmpty,
                onManage: () => _openWater(context),
                onRetry: () => context.read<WaterBowlCubit>().load(),
                grid: true,
                item: (bowl) => TargetGridTile(
                  name: bowl.name,
                  icon: Icons.water_drop_outlined,
                  onTap: () async {
                    await showWaterBowlDetail(context, bowl, PhotoPicker());
                  },
                ),
              ),
            ),
            BlocBuilder<LitterBoxCubit, LoadState<List<LitterBox>>>(
              builder: (context, state) => _DashboardSection<LitterBox>(
                title: context.l10n.navLitter,
                manageLabel: context.l10n.homeLitterManage,
                state: state,
                empty: context.l10n.homeLitterEmpty,
                onManage: () => _openLitter(context),
                onRetry: () => context.read<LitterBoxCubit>().load(),
                grid: true,
                item: (box) => TargetGridTile(
                  name: box.name,
                  icon: Icons.cleaning_services_outlined,
                  onTap: () async {
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
                  },
                ),
              ),
            ),
            const SizedBox(height: HareupSpacing.medium),
            Card(
              color: HareupColors.surfaceContainer,
              child: Padding(
                padding: const EdgeInsets.all(HareupSpacing.medium),
                child: Text(
                  context.l10n.homeEstimateNotice,
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
    this.grid = false,
  });
  final String title;
  final String manageLabel;
  final LoadState<List<T>> state;
  final String empty;
  final VoidCallback onManage;
  final VoidCallback onRetry;
  final Widget Function(T) item;
  final String Function(List<T>)? count;
  final bool grid;
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
          Initial<List<T>>() || Loading<List<T>>() => const Padding(
            padding: EdgeInsets.all(HareupSpacing.large),
            child: HareupLoading(),
          ),
          Empty<List<T>>() => HareupCard(title: empty, onTap: onManage),
          Failed<List<T>>(:final failure) => ErrorNotice(
            message: failureDisplayMessage(context, failure),
            onRetry: onRetry,
          ),
          Loaded<List<T>>(:final data) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (count != null) Text(count!(data)),
              if (grid)
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 1.5,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [for (final value in data) item(value)],
                )
              else
                for (final value in data) Card(child: item(value)),
            ],
          ),
        },
      ],
    ),
  );
}
