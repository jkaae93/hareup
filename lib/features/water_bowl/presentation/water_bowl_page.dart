import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_core/core.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/domain/record.dart';
import '../../records/presentation/records_page.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/water_bowl.dart';
import '../domain/water_level.dart';
import 'water_level_page.dart';
import 'water_level_history_page.dart';
import 'water_bowl_cubit.dart';

Future<void> showWaterBowlDetail(
  BuildContext context,
  WaterBowl bowl,
  PhotoSource photoSource,
) {
  final cubit = context.read<WaterBowlCubit>();
  final analysisRuntime = context.read<AnalysisRuntime>();
  final recordsRepository = context.read<RecordsRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _WaterBowlDetailPage(
        bowl: bowl,
        cubit: cubit,
        photoSource: photoSource,
        analysisRuntime: analysisRuntime,
        recordsRepository: recordsRepository,
      ),
    ),
  );
}

class WaterBowlPage extends StatelessWidget {
  const WaterBowlPage({
    super.key,
    required this.pets,
    required this.photoSource,
    required this.analysisRuntime,
    required this.recordsRepository,
  });
  final List<BowlPetOption> pets;
  final PhotoSource photoSource;
  final AnalysisRuntime analysisRuntime;
  final RecordsRepository recordsRepository;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('물그릇 관리')),
    floatingActionButton: Builder(
      builder: (context) {
        final cubit = context.read<WaterBowlCubit>();
        return FloatingActionButton.extended(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: _BowlForm(
                  pets: pets,
                  photoSource: photoSource,
                  analysisRuntime: analysisRuntime,
                  recordsRepository: recordsRepository,
                ),
              ),
            ),
          ),
          label: const Text('물그릇 추가'),
          icon: const Icon(Icons.add),
        );
      },
    ),
    body: HareupContent(
      child: BlocBuilder<WaterBowlCubit, LoadState<List<WaterBowl>>>(
        builder: (context, state) => LoadView<List<WaterBowl>>(
          state: state,
          emptyMessage: '등록된 물그릇이 없습니다.',
          onRetry: () => context.read<WaterBowlCubit>().load(),
          builder: (context, bowls) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              HareupSpacing.pageMargin,
              HareupSpacing.small,
              HareupSpacing.pageMargin,
              HareupSpacing.floatingActionClearance,
            ),
            itemCount: bowls.length,
            itemBuilder: (context, index) {
              final bowl = bowls[index];
              return HareupCard(
                leading: const CircleAvatar(
                  child: Icon(Icons.water_drop_outlined),
                ),
                title: bowl.name,
                subtitle:
                    ('반려동물 ${bowl.petIds.length}마리 · 정수기 사진 ${bowl.currentBaseline.version}번째'),
                isThreeLine: true,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => _WaterBowlDetailPage(
                      bowl: bowl,
                      cubit: context.read<WaterBowlCubit>(),
                      photoSource: photoSource,
                      analysisRuntime: analysisRuntime,
                      recordsRepository: recordsRepository,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _BowlForm extends StatefulWidget {
  const _BowlForm({
    required this.pets,
    required this.photoSource,
    required this.analysisRuntime,
    required this.recordsRepository,
  });
  final List<BowlPetOption> pets;
  final PhotoSource photoSource;
  final AnalysisRuntime analysisRuntime;
  final RecordsRepository recordsRepository;
  @override
  State<_BowlForm> createState() => _BowlFormState();
}

class _BowlFormState extends State<_BowlForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _capacity = TextEditingController();
  final _notes = TextEditingController();
  final _selected = <String>{};
  final _photos = <String, Uint8List>{};
  static const _photoAngles = {'front': '앞', 'back': '뒤', 'top': '위'};
  bool _picking = false;
  bool _submitting = false;

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _capacity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick(String angle, bool camera) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final result = camera
          ? await widget.photoSource.pickFromCamera()
          : await widget.photoSource.pickFromGallery();
      if (!mounted) return;
      switch (result) {
        case PhotoSelected(:final file):
          if (await file.length() > 3 * 1024 * 1024) {
            if (mounted) _message('사진은 3MB 이하여야 합니다.');
            break;
          }
          final bytes = await file.readAsBytes();
          if (mounted) setState(() => _photos[angle] = bytes);
        case PhotoSelectionFailed(:final reason):
          _message(
            reason == PhotoFailureReason.permissionDenied
                ? '사진 접근 권한을 확인해 주세요.'
                : '사진을 가져오지 못했습니다.',
          );
        case PhotoCancelled():
          break;
      }
    } catch (_) {
      if (mounted) _message('사진을 읽지 못했습니다.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  String? _positive(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final value = double.tryParse(input);
    return value == null || !value.isFinite || value <= 0
        ? '0보다 큰 숫자를 입력해 주세요.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WaterBowlCubit>();
    return PopScope(
      canPop: !_submitting,
      child: HareupFormPage(
        title: const Text('물그릇 등록'),
        content: SizedBox(
          width: 380,
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HareupStatusBadge(label: '음수량 스마트 모니터링'),
                  const SizedBox(height: HareupSpacing.small),
                  Text(
                    '새 물그릇 등록',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  const Text('정수기 사진과 기본 정보를 입력해 주세요.'),
                  const SizedBox(height: HareupSpacing.large),
                  const HareupGuidance(
                    title: '사진 촬영 가이드',
                    message: '정수기 전체가 잘 보이도록 서로 다른 각도에서 사진 3장을 촬영해 주세요.',
                    icon: Icons.camera_alt_outlined,
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  HareupFormSection(
                    title: '정수기 사진',
                    description: '정수기의 앞, 뒤, 위에서 촬영한 사진을 각각 등록해 주세요.',
                    children: [
                      for (final angle in _photoAngles.entries) ...[
                        Text(
                          '${angle.value} 사진',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        HareupPhotoPreview(
                          bytes: _photos[angle.key],
                          label: '정수기 ${angle.value} 사진',
                          height: 160,
                        ),
                        if (_photos.containsKey(angle.key))
                          Text('${angle.value} 사진 선택됨'),
                        HareupPhotoActions(
                          prefix: '${angle.value} 사진',
                          onCamera: _picking
                              ? null
                              : () => _pick(angle.key, true),
                          onGallery: _picking
                              ? null
                              : () => _pick(angle.key, false),
                        ),
                        const SizedBox(height: HareupSpacing.medium),
                      ],
                    ],
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  HareupFormSection(
                    title: '물그릇 정보',
                    children: [
                      TextFormField(
                        controller: _name,
                        maxLength: 30,
                        decoration: const InputDecoration(labelText: '그릇 이름'),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? '이름을 입력해 주세요.'
                            : null,
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      Text(
                        '함께 사용하는 반려동물',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (widget.pets.isEmpty) const Text('먼저 반려동물을 등록해 주세요.'),
                      for (final pet in widget.pets)
                        CheckboxListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: HareupSpacing.small,
                          ),
                          tileColor: HareupColors.neutral100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(pet.name),
                          value: _selected.contains(pet.id),
                          onChanged: (value) => setState(() {
                            if (value == true) {
                              _selected.add(pet.id);
                            } else {
                              _selected.remove(pet.id);
                            }
                          }),
                        ),
                      const SizedBox(height: HareupSpacing.medium),
                      Text(
                        '선택 물리 사양',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      TextFormField(
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: '빈 그릇 무게 (g, 선택)',
                        ),
                        validator: _positive,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      TextFormField(
                        controller: _capacity,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: '가득 찬 물의 양 (mL, 선택)',
                          helperText: '그릇 무게를 제외한 물의 양',
                        ),
                        validator: _positive,
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      TextFormField(
                        controller: _notes,
                        maxLength: 500,
                        minLines: 2,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: '사진 특이사항 (선택)',
                          hintText: '예: 정수기에 물이 70% 차 있는 상태예요',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  const HareupGuidance(
                    title: '측정 유의사항',
                    message: '부피 추정 기능은 검증 전이며 입력값이 있어도 제공되지 않습니다.',
                    icon: Icons.warning_amber_outlined,
                  ),
                  const SizedBox(height: HareupSpacing.large),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          BlocBuilder<Command1<void, WaterBowl>, CommandState<void>>(
            bloc: cubit.createCommand,
            builder: (_, state) => FilledButton(
              onPressed:
                  _picking || _submitting || state is CommandRunning<void>
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      if (_selected.isEmpty ||
                          _photoAngles.keys.any(
                            (key) => _photos[key]?.isNotEmpty != true,
                          )) {
                        _message('반려동물과 정수기의 앞·뒤·위 사진을 모두 선택해 주세요.');
                        return;
                      }
                      setState(() => _submitting = true);
                      final saved = await cubit.create(
                        name: _name.text,
                        petIds: _selected.toList(),
                        photo: _photos['front']!,
                        registrationPhotos: _photos,
                        emptyWeightGrams: double.tryParse(_weight.text),
                        fullWaterMl: double.tryParse(_capacity.text),
                        notes: _notes.text,
                      );
                      if (!context.mounted) return;
                      if (saved) {
                        final service = widget.analysisRuntime.service;
                        String message;
                        if (service is WaterLevelService) {
                          final result = await (service as WaterLevelService)
                              .observeWaterLevel(
                                groupId: widget.analysisRuntime.groupId,
                                bowlId: cubit.lastCreated!.id,
                                requestId:
                                    'setup-${DateTime.now().microsecondsSinceEpoch}',
                                setup: true,
                                photos: _photos,
                              );
                          message = switch (result) {
                            Success<WaterLevelResult>(:final value)
                                when value.status == 'ok' =>
                              '정수기 초기 설정을 완료했습니다.',
                            Success<WaterLevelResult>() =>
                              '정수기는 등록됐지만 초기 수위를 확인하지 못했습니다. 다시 분석해 주세요.',
                            Failure<WaterLevelResult>(:final failure) =>
                              '정수기는 등록됐지만 초기 설정에 실패했습니다: ${failure.message}',
                          };
                        } else {
                          message = '정수기는 등록됐습니다. 초기 분석을 다시 시도해 주세요.';
                        }
                        if (!context.mounted) return;
                        await cubit.load();
                        if (!context.mounted) return;
                        _message(message);
                        setState(() => _submitting = false);
                        Navigator.pop(context);
                      } else {
                        setState(() => _submitting = false);
                        if (cubit.createCommand.state case CommandFailure<void>(
                          :final failure,
                        )) {
                          _message(failure.message);
                        }
                      }
                    },
              child: const Text('등록'),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterBowlDetailPage extends StatefulWidget {
  const _WaterBowlDetailPage({
    required this.bowl,
    required this.cubit,
    required this.photoSource,
    required this.analysisRuntime,
    required this.recordsRepository,
  });
  final WaterBowl bowl;
  final WaterBowlCubit cubit;
  final PhotoSource photoSource;
  final AnalysisRuntime analysisRuntime;
  final RecordsRepository recordsRepository;
  @override
  State<_WaterBowlDetailPage> createState() => _WaterBowlDetailPageState();
}

class _WaterBowlDetailPageState extends State<_WaterBowlDetailPage> {
  bool _busy = false;

  Future<void> _reanalyze() async {
    if (_busy) return;
    final service = widget.analysisRuntime.service;
    if (service is! WaterLevelService ||
        ![
          'front',
          'back',
          'top',
        ].every((key) => widget.bowl.registrationPhotos.containsKey(key))) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('초기 설정을 위해 정수기 앞·뒤·위 사진을 다시 등록해 주세요.')),
      );
      return;
    }
    setState(() => _busy = true);
    final result = await (service as WaterLevelService).observeWaterLevel(
      groupId: widget.analysisRuntime.groupId,
      bowlId: widget.bowl.id,
      requestId: 'setup-${DateTime.now().microsecondsSinceEpoch}',
      setup: true,
      photos: widget.bowl.registrationPhotos,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final message = switch (result) {
      Success<WaterLevelResult>(:final value) when value.status == 'ok' =>
        '정수기 초기 설정을 완료했습니다.',
      Success<WaterLevelResult>(:final value) =>
        '초기 수위를 확인하지 못했습니다. ${value.reason}',
      Failure<WaterLevelResult>(:final failure) => failure.message,
    };
    await widget.cubit.load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _replace(bool camera) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final selected = camera
          ? await widget.photoSource.pickFromCamera()
          : await widget.photoSource.pickFromGallery();
      if (!mounted) return;
      if (selected is PhotoSelectionFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('사진 접근을 확인하고 다시 시도해 주세요.')),
        );
        return;
      }
      if (selected is! PhotoSelected) return;
      if (await selected.file.length() > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('사진은 10MB 이하여야 합니다.')));
        }
        return;
      }
      final photo = await selected.file.readAsBytes();
      if (!mounted) return;
      final notes = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => const HareupTextEntryPage(
            title: '새 정수기 사진 특이사항',
            label: '사진 특이사항 (선택)',
            hint: '예: 물이 70% 차 있는 상태예요',
            maxLength: 500,
            minLines: 2,
            maxLines: 4,
            submitLabel: '정수기 사진 저장',
          ),
        ),
      );
      if (!mounted || notes == null) return;
      final saved = await widget.cubit.changeBaseline(
        widget.bowl.id,
        photo,
        notes: notes,
      );
      if (!mounted) return;
      if (saved) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('정수기 사진을 변경하지 못했습니다.')));
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('사진을 읽지 못했습니다.')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bowl = widget.bowl;
    final baseline = bowl.currentBaseline;
    return Scaffold(
      appBar: AppBar(title: const Text('정수기 상세 정보')),
      body: HareupContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            HareupSpacing.pageMargin,
            HareupSpacing.medium,
            HareupSpacing.pageMargin,
            HareupSpacing.floatingActionClearance,
          ),
          children: [
            HareupFormSection(
              title: bowl.name,
              description: '물그릇 · 반려동물 ${bowl.petIds.length}마리와 함께 사용',
              children: [
                HareupStatusBadge(label: '정수기 사진 ${baseline.version}번째'),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  '최근 등록 ${baseline.createdAt.toLocal().toString().substring(0, 16)}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: '정수기 사진',
              description: '물을 보충하거나 교체했다면 새 사진을 등록하세요.',
              children: [
                HareupPhotoPreview(
                  bytes: baseline.photo,
                  label: '${bowl.name} 정수기 사진',
                  height: 220,
                  fit: BoxFit.contain,
                ),
                if (baseline.notes.isNotEmpty) ...[
                  const SizedBox(height: HareupSpacing.small),
                  HareupGuidance(title: '사진 특이사항', message: baseline.notes),
                ],
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            if (bowl.registrationPhotos.isNotEmpty) ...[
              HareupFormSection(
                title: '처음 등록한 정수기 사진',
                children: [
                  for (final angle in const {
                    'front': '앞',
                    'back': '뒤',
                    'top': '위',
                  }.entries)
                    if (bowl.registrationPhotos[angle.key]
                        case final photo?) ...[
                      Text('${angle.value} 사진'),
                      HareupPhotoPreview(
                        bytes: photo,
                        label: '정수기 ${angle.value} 사진',
                        height: 160,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                    ],
                ],
              ),
              const SizedBox(height: HareupSpacing.medium),
            ],
            HareupFormSection(
              title: '기기 정보',
              children: [
                HareupMetric(
                  label: '가득 찬 물의 양',
                  value: bowl.fullWaterMl == null
                      ? '미입력'
                      : '${_formatNumber(bowl.fullWaterMl!)} mL',
                ),
                const SizedBox(height: HareupSpacing.small),
                HareupMetric(
                  label: '빈 기기 무게',
                  value: bowl.emptyWeightGrams == null
                      ? '미입력'
                      : '${_formatNumber(bowl.emptyWeightGrams!)} g',
                ),
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: '정수기 사진 변경 이력',
              description: '이전 정수기 사진은 기록과 함께 보관됩니다.',
              children: [
                for (final item in bowl.baselines.reversed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: HareupColors.primaryContainer,
                      child: Text('${item.version}'),
                    ),
                    title: Text('정수기 사진 ${item.version}번째'),
                    subtitle: Text(
                      item.createdAt.toLocal().toString().substring(0, 16),
                    ),
                    trailing: item.version == baseline.version
                        ? const HareupStatusBadge(label: '현재 기준')
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            const HareupGuidance(
              title: '관찰 결과 안내',
              message:
                  '사진 분석은 기준 대비 변화를 추정하며, 실제 반려동물의 음수량이나 건강 상태를 진단하지 않습니다.',
            ),
            const SizedBox(height: HareupSpacing.medium),
            if (bowl.levelProfile == null) ...[
              OutlinedButton.icon(
                onPressed: _busy ? null : _reanalyze,
                icon: const Icon(Icons.refresh),
                label: const Text('등록 사진 다시 분석하기'),
              ),
              const SizedBox(height: HareupSpacing.small),
            ],
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => WaterLevelPage(
                            bowl: bowl,
                            photoSource: widget.photoSource,
                            runtime: widget.analysisRuntime,
                          ),
                        ),
                      );
                      await widget.cubit.load();
                      if (context.mounted) Navigator.pop(context);
                    },
              icon: const Icon(Icons.water_drop_outlined),
              label: const Text('수위 관찰'),
            ),
            const SizedBox(height: HareupSpacing.small),
            OutlinedButton.icon(
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => WaterLevelHistoryPage(
                          runtime: widget.analysisRuntime,
                          bowlId: bowl.id,
                        ),
                      ),
                    ),
              icon: const Icon(Icons.history),
              label: const Text('수위 기록 보기'),
            ),
            const SizedBox(height: HareupSpacing.small),
            TextButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RepositoryProvider<RecordsRepository>.value(
                              value: widget.recordsRepository,
                              child: RecordsPage(
                                groupId: widget.analysisRuntime.groupId,
                                targetId: bowl.id,
                                targetName: bowl.name,
                              ),
                            ),
                      ),
                    ),
              child: const Text('이전 분석 기록 보기'),
            ),
            const SizedBox(height: HareupSpacing.large),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            HareupSpacing.pageMargin,
            HareupSpacing.small,
            HareupSpacing.pageMargin,
            HareupSpacing.small,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _replace(true),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('새 사진 촬영'),
                ),
              ),
              const SizedBox(width: HareupSpacing.small),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : () => _replace(false),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('새 사진 선택'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';
}
