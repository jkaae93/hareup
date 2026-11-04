import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../litter_box/domain/litter_box.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/domain/record.dart';
import '../../water_bowl/domain/water_bowl.dart';
import '../domain/pet.dart';

class PetDetailPage extends StatefulWidget {
  const PetDetailPage({
    super.key,
    required this.pet,
    required this.waterRepository,
    required this.litterRepository,
    this.recordsRepository,
    this.runtime,
    required this.onEdit,
  });
  final Pet pet;
  final WaterBowlRepository waterRepository;
  final LitterBoxRepository litterRepository;
  final RecordsRepository? recordsRepository;
  final AnalysisRuntime? runtime;
  final VoidCallback onEdit;
  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetConnections {
  const _PetConnections(this.bowls, this.boxes);
  final List<WaterBowl> bowls;
  final List<LitterBox> boxes;
}

class _PetDetailPageState extends State<PetDetailPage> {
  late Future<_PetConnections> _data;
  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_PetConnections> _load() async {
    final results = await Future.wait<Object>([
      widget.waterRepository.list(),
      widget.litterRepository.list(),
    ]);
    final water = results[0] as Result<List<WaterBowl>>;
    final litter = results[1] as Result<List<LitterBox>>;
    if (water is! Success<List<WaterBowl>> ||
        litter is! Success<List<LitterBox>>) {
      throw StateError('Failed to load linked items');
    }
    return _PetConnections(
      water.value.where((bowl) => bowl.petIds.contains(widget.pet.id)).toList(),
      litter.value.where((box) => box.catIds.contains(widget.pet.id)).toList(),
    );
  }

  Widget _profile(BuildContext context, _PetConnections? connections) {
    final profile = widget.pet.profile;
    final species = widget.pet.species == PetSpecies.cat
        ? context.l10n.petSpeciesCat
        : context.l10n.petSpeciesDog;
    final sex = switch (profile.sex) {
      PetSex.female => context.l10n.petSexFemale,
      PetSex.male => context.l10n.petSexMale,
      PetSex.unknown => context.l10n.petSexUnknown,
      null => null,
    };
    return HareupPanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HareupPhotoPreview(
            bytes: profile.photoBytes,
            label: context.l10n.petPhotoLabel,
            height: 280,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: HareupSpacing.medium),
          HareupSectionHeader(
            title: widget.pet.name,
            actionLabel: context.l10n.petEditProfile,
            onAction: widget.onEdit,
            alignActionToEnd: true,
          ),
          const SizedBox(height: HareupSpacing.small),
          Wrap(
            spacing: HareupSpacing.small,
            runSpacing: HareupSpacing.small,
            children: [
              HareupStatusBadge(label: species),
              if (profile.ageMonths case final age?)
                HareupStatusBadge(label: context.l10n.petAgeMonths(age)),
              if (sex != null) HareupStatusBadge(label: sex),
              if (profile.weightKg case final weight?)
                HareupStatusBadge(label: context.l10n.petWeightLine(weight)),
              if (connections != null) ...[
                for (final bowl in connections.bowls)
                  HareupStatusBadge(
                    label: bowl.name,
                    icon: Icons.water_drop_outlined,
                  ),
                for (final box in connections.boxes)
                  HareupStatusBadge(
                    label: box.name,
                    icon: Icons.cleaning_services_outlined,
                  ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.pet.name)),
    body: HareupContent(
      child: ListView(
        padding: const EdgeInsets.all(HareupSpacing.pageMargin),
        children: [
          FutureBuilder<_PetConnections>(
            future: _data,
            builder: (context, snapshot) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _profile(context, snapshot.data),
                if (snapshot.hasError) ...[
                  const SizedBox(height: HareupSpacing.medium),
                  HareupFormSection(
                    title: context.l10n.petHealthLoadFailed,
                    children: [
                      HareupCard(
                        title: context.dsL10n.retryAction,
                        onTap: () => setState(() => _data = _load()),
                      ),
                    ],
                  ),
                ] else if (!snapshot.hasData) ...[
                  const SizedBox(height: HareupSpacing.medium),
                  const HareupLoading(),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
