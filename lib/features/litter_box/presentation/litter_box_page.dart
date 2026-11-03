import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_media/media.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../photo_analysis/presentation/analysis_page.dart';
import '../../records/presentation/records_page.dart';
import '../../records/domain/record.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/litter_box.dart';
import 'litter_box_cubit.dart';

Future<void> showLitterBoxDetail(
  BuildContext context,
  LitterBox box,
  PhotoSource photoSource,
  List<CatOption> cats,
) {
  final cubit = context.read<LitterBoxCubit>();
  final runtime = context.read<AnalysisRuntime>();
  final records = context.read<RecordsRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AnalysisRuntime>.value(value: runtime),
          RepositoryProvider<RecordsRepository>.value(value: records),
        ],
        child: BlocProvider.value(
          value: cubit,
          child: _LitterBaselineDialog(
            box: box,
            source: photoSource,
            cats: cats.where((cat) => box.catIds.contains(cat.id)).toList(),
          ),
        ),
      ),
    ),
  );
}

class LitterBoxPage extends StatelessWidget {
  const LitterBoxPage({
    super.key,
    required this.cats,
    required this.photoSource,
  });
  final List<CatOption> cats;
  final PhotoSource photoSource;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('화장실 관리')),
    floatingActionButton: FloatingActionButton.extended(
      icon: const Icon(Icons.add),
      label: const Text('화장실 추가'),
      onPressed: () {
        final cubit = context.read<LitterBoxCubit>();
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: _LitterEditor(cats: cats, source: photoSource),
            ),
          ),
        );
      },
    ),
    body: HareupContent(
      child: BlocBuilder<LitterBoxCubit, LoadState<List<LitterBox>>>(
        builder: (context, state) => LoadView<List<LitterBox>>(
          state: state,
          emptyMessage: '등록된 화장실이 없습니다.',
          onRetry: () => context.read<LitterBoxCubit>().load(),
          builder: (context, boxes) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              HareupSpacing.pageMargin,
              HareupSpacing.small,
              HareupSpacing.pageMargin,
              HareupSpacing.floatingActionClearance,
            ),
            itemCount: boxes.length,
            itemBuilder: (context, index) {
              final box = boxes[index];
              return HareupCard(
                leading: const CircleAvatar(
                  child: Icon(Icons.cleaning_services_outlined),
                ),
                title: box.name,
                subtitle:
                    ('고양이 ${box.catIds.length}마리 · 기준 사진 ${box.currentBaseline.version}번째'),
                isThreeLine: true,
                onTap: () =>
                    showLitterBoxDetail(context, box, photoSource, cats),
              );
            },
          ),
        ),
      ),
    ),
  );
}

class _LitterEditor extends StatefulWidget {
  const _LitterEditor({required this.cats, required this.source});
  final List<CatOption> cats;
  final PhotoSource source;
  @override
  State<_LitterEditor> createState() => _LitterEditorState();
}

class _LitterEditorState extends State<_LitterEditor> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _width = TextEditingController();
  final _length = TextEditingController();
  final _height = TextEditingController();
  final _selected = <String>{};
  Uint8List? _photo;
  bool _automatic = false;
  bool _picking = false;
  @override
  void dispose() {
    _name.dispose();
    _width.dispose();
    _length.dispose();
    _height.dispose();
    super.dispose();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _pick(bool camera) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final selected = camera
          ? await widget.source.pickFromCamera()
          : await widget.source.pickFromGallery();
      if (!mounted) return;
      if (selected is PhotoSelectionFailed) {
        _message('사진 접근을 확인하고 다시 시도해 주세요.');
        return;
      }
      if (selected is! PhotoSelected) return;
      if (await selected.file.length() > 10 * 1024 * 1024) {
        if (mounted) _message('사진은 10MB 이하여야 합니다.');
        return;
      }
      final bytes = await selected.file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (_) {
      if (mounted) _message('사진을 읽지 못했습니다.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  String? _positive(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    return number == null || !number.isFinite || number <= 0
        ? '0보다 큰 숫자를 입력해 주세요.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LitterBoxCubit>();
    return HareupFormPage(
      title: const Text('화장실 등록'),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const HareupStatusBadge(label: '배변 건강 모니터링'),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  '화장실 등록',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: HareupSpacing.small),
                const Text('깨끗한 모래 사진과 화장실 정보를 등록해 주세요.'),
                const SizedBox(height: HareupSpacing.large),
                const HareupGuidance(
                  title: '사진 촬영 가이드',
                  message: '깨끗한 모래와 화장실 전체가 보이도록 촬영해 주세요.',
                  icon: Icons.center_focus_strong,
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: '자동화장실 기기 여부',
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('자동화장실'),
                      value: _automatic,
                      onChanged: (value) => setState(() => _automatic = value),
                    ),
                    if (_automatic)
                      const HareupGuidance(
                        title: '자동화장실 등록 제한 안내',
                        message: '자동화장실은 분석 대상으로 등록할 수 없습니다.',
                        icon: Icons.error_outline,
                        warning: true,
                      ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: '기준 사진 등록',
                  description: '청소 직후 깨끗한 모래 상태를 기준으로 등록하세요.',
                  children: [
                    HareupPhotoPreview(
                      bytes: _photo,
                      label: '화장실 기준 사진',
                      height: 220,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    HareupPhotoActions(
                      prefix: '기준 사진',
                      onCamera: _picking ? null : () => _pick(true),
                      onGallery: _picking ? null : () => _pick(false),
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: '화장실 프로필 및 치수',
                  children: [
                    TextFormField(
                      controller: _name,
                      maxLength: 30,
                      decoration: const InputDecoration(labelText: '화장실 이름'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? '이름을 입력해 주세요.'
                          : null,
                    ),
                    const SizedBox(height: HareupSpacing.medium),
                    Text(
                      '함께 사용하는 고양이',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (widget.cats.isEmpty) const Text('먼저 고양이를 등록해 주세요.'),
                    for (final cat in widget.cats)
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: HareupSpacing.small,
                        ),
                        tileColor: HareupColors.neutral100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(cat.name),
                        value: _selected.contains(cat.id),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selected.add(cat.id);
                          } else {
                            _selected.remove(cat.id);
                          }
                        }),
                      ),
                    const SizedBox(height: HareupSpacing.medium),
                    Text(
                      '상세 규격 치수 (선택)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _width,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: '내부 가로 (cm, 선택)',
                      ),
                      validator: _positive,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _length,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: '내부 세로 (cm, 선택)',
                      ),
                      validator: _positive,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _height,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: '모래 높이 (cm, 선택)',
                      ),
                      validator: _positive,
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                const HareupGuidance(
                  title: '관찰량 안내',
                  message: '관찰량 추정은 검증 전이며 치수를 입력해도 제공되지 않습니다.',
                  icon: Icons.lightbulb_outline,
                ),
                const SizedBox(height: HareupSpacing.large),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        BlocBuilder<Command1<void, LitterBox>, CommandState<void>>(
          bloc: cubit.createCommand,
          builder: (_, state) => FilledButton(
            onPressed: _picking || _automatic || state is CommandRunning<void>
                ? null
                : () async {
                    if (!_form.currentState!.validate()) return;
                    if (_selected.isEmpty ||
                        _photo == null ||
                        _photo!.isEmpty) {
                      _message('고양이와 기준 사진을 선택해 주세요.');
                      return;
                    }
                    final saved = await cubit.create(
                      name: _name.text,
                      catIds: _selected.toList(),
                      photo: _photo!,
                      isAutomatic: _automatic,
                      widthCm: double.tryParse(_width.text),
                      lengthCm: double.tryParse(_length.text),
                      litterHeightCm: double.tryParse(_height.text),
                    );
                    if (!context.mounted) return;
                    if (saved) {
                      Navigator.pop(context);
                    } else if (cubit.createCommand.state
                        case CommandFailure<void>(:final failure)) {
                      _message(failure.message);
                    }
                  },
            child: const Text('등록'),
          ),
        ),
      ],
    );
  }
}

class _LitterBaselineDialog extends StatefulWidget {
  const _LitterBaselineDialog({
    required this.box,
    required this.source,
    required this.cats,
  });
  final LitterBox box;
  final PhotoSource source;
  final List<CatOption> cats;
  @override
  State<_LitterBaselineDialog> createState() => _LitterBaselineDialogState();
}

class _LitterBaselineDialogState extends State<_LitterBaselineDialog> {
  bool _busy = false;
  Future<void> _replace(bool camera) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final selected = camera
          ? await widget.source.pickFromCamera()
          : await widget.source.pickFromGallery();
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
      final bytes = await selected.file.readAsBytes();
      if (!mounted) return;
      final saved = await context.read<LitterBoxCubit>().changeBaseline(
        widget.box.id,
        bytes,
      );
      if (!mounted) return;
      if (saved) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('기준 사진을 변경하지 못했습니다.')));
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
  Widget build(BuildContext context) => HareupFormPage(
    title: Text(widget.box.name),
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('기준 사진 ${widget.box.currentBaseline.version}번째'),
          HareupPhotoPreview(
            bytes: widget.box.currentBaseline.photo,
            label: '화장실 기준 사진',
            height: 120,
            fit: BoxFit.cover,
          ),
          for (final baseline in widget.box.baselines.reversed)
            Text(
              '${baseline.version}번째 · ${baseline.createdAt.toLocal().toString().substring(0, 16)}',
            ),
          const Text('청소하거나 모래를 교체했다면 새 기준 사진을 등록하세요. 이전 기준은 유지됩니다.'),
          const Text('사진 분석 결과는 검증된 경우에만 제공됩니다.'),
          TextButton(
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          RepositoryProvider<RecordsRepository>.value(
                            value: context.read<RecordsRepository>(),
                            child: AnalysisPage(
                              targetId: widget.box.id,
                              targetName: widget.box.name,
                              kind: AnalysisKind.litter,
                              baseline: widget.box.currentBaseline,
                              photoSource: widget.source,
                              runtime: context.read<AnalysisRuntime>(),
                              cats: [
                                for (final cat in widget.cats)
                                  AnalysisCat(id: cat.id, name: cat.name),
                              ],
                              widthCm: widget.box.widthCm,
                              lengthCm: widget.box.lengthCm,
                              litterHeightCm: widget.box.litterHeightCm,
                            ),
                          ),
                    ),
                  ),
            child: const Text('사진 비교'),
          ),
          TextButton(
            onPressed: _busy
                ? null
                : () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          RepositoryProvider<RecordsRepository>.value(
                            value: context.read<RecordsRepository>(),
                            child: RecordsPage(
                              groupId: context.read<AnalysisRuntime>().groupId,
                              targetId: widget.box.id,
                              targetName: widget.box.name,
                            ),
                          ),
                    ),
                  ),
            child: const Text('기록 보기'),
          ),
          Wrap(
            children: [
              TextButton(
                onPressed: _busy ? null : () => _replace(true),
                child: const Text('새 기준 촬영'),
              ),
              TextButton(
                onPressed: _busy ? null : () => _replace(false),
                child: const Text('새 기준 선택'),
              ),
            ],
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: _busy ? null : () => Navigator.pop(context),
        child: const Text('닫기'),
      ),
    ],
  );
}
