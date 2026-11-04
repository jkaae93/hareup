import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_media/media.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../domain/water_bowl.dart';
import '../domain/water_level.dart';

class WaterLevelPage extends StatefulWidget {
  const WaterLevelPage({
    super.key,
    required this.bowl,
    required this.photoSource,
    required this.runtime,
  });
  final WaterBowl bowl;
  final PhotoSource photoSource;
  final AnalysisRuntime runtime;
  @override
  State<WaterLevelPage> createState() => _WaterLevelPageState();
}

class _WaterLevelPageState extends State<WaterLevelPage> {
  late bool _setup;
  late Map<String, Uint8List> _photos;
  Uint8List? _photo;
  String? _requestId;
  String? _message;
  WaterLevelResult? _result;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _setup = widget.bowl.levelProfile == null;
    _photos = Map.of(widget.bowl.registrationPhotos);
  }

  Future<void> _pick(String angle, bool camera) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final selection = camera
          ? await widget.photoSource.pickFromCamera()
          : await widget.photoSource.pickFromGallery();
      if (selection is PhotoSelected) {
        if (await selection.file.length() > 3 * 1024 * 1024) {
          if (mounted) {
            setState(() => _message = context.l10n.waterPhotoTooLarge);
          }
          return;
        }
        final bytes = await selection.file.readAsBytes();
        if (!mounted) return;
        setState(() {
          if (_setup) {
            _photos[angle] = bytes;
          } else {
            _photo = bytes;
          }
          _requestId = null;
          _message = null;
          _result = null;
        });
      } else if (selection is PhotoSelectionFailed && mounted) {
        setState(() => _message = context.l10n.photoFetchFailed);
      }
    } catch (_) {
      if (mounted) setState(() => _message = context.l10n.photoReadFailed);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _analyze() async {
    final service = widget.runtime.service;
    if (service is! WaterLevelService) {
      setState(() => _message = context.l10n.waterServiceUnavailable);
      return;
    }
    if (_setup &&
        ![
          'front',
          'back',
          'top',
        ].every((angle) => _photos[angle]?.isNotEmpty == true)) {
      setState(() => _message = context.l10n.waterSetupPhotosRequired);
      return;
    }
    if (!_setup && _photo == null) {
      setState(() => _message = context.l10n.waterReadingPhotoRequired);
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    _requestId ??=
        '${_setup ? 'setup' : 'reading'}-${DateTime.now().microsecondsSinceEpoch}';
    final response = await (service as WaterLevelService).observeWaterLevel(
      groupId: widget.runtime.groupId,
      bowlId: widget.bowl.id,
      requestId: _requestId!,
      setup: _setup,
      photos: _setup ? _photos : const {},
      photo: _photo,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      switch (response) {
        case Failure<WaterLevelResult>(:final failure):
          _message = failureDisplayMessage(context, failure);
        case Success<WaterLevelResult>(:final value):
          if (value.status != 'ok') {
            _message = context.l10n.waterLevelUnknownWith(value.reason);
            _requestId = null;
          } else {
            _result = value;
            _requestId = null;
            if (_setup) {
              _setup = false;
              _photo = null;
            }
          }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final angles = {
      'front': context.l10n.waterAngleFront,
      'back': context.l10n.waterAngleBack,
      'top': context.l10n.waterAngleTop,
    };
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _setup
              ? context.l10n.waterSetupTitle
              : context.l10n.waterObserveTitle,
        ),
      ),
      body: HareupContent(
        child: ListView(
          padding: const EdgeInsets.all(HareupSpacing.pageMargin),
          children: [
            HareupGuidance(
              title: _setup
                  ? context.l10n.waterSetupGuideTitle
                  : context.l10n.waterObserveGuideTitle,
              message: _setup
                  ? context.l10n.waterSetupGuideMessage
                  : context.l10n.waterObserveGuideMessage,
            ),
            const SizedBox(height: HareupSpacing.medium),
            if (_setup) ...[
              for (final entry in angles.entries) ...[
                HareupFormSection(
                  title: context.l10n.waterAnglePhoto(entry.value),
                  children: [
                    HareupPhotoPreview(
                      bytes: _photos[entry.key],
                      label: context.l10n.waterAnglePhoto(entry.value),
                    ),
                    HareupPhotoActions(
                      prefix: context.l10n.waterAnglePhoto(entry.value),
                      onCamera: _busy ? null : () => _pick(entry.key, true),
                      onGallery: _busy ? null : () => _pick(entry.key, false),
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
              ],
            ] else ...[
              HareupFormSection(
                title: context.l10n.waterPurifierPhoto,
                children: [
                  HareupPhotoPreview(
                    bytes: _photo,
                    label: context.l10n.waterPurifierPhoto,
                  ),
                  HareupPhotoActions(
                    onCamera: _busy ? null : () => _pick('', true),
                    onGallery: _busy ? null : () => _pick('', false),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _busy ? null : _analyze,
              child: Text(
                _setup
                    ? context.l10n.waterSetupAnalyzeAction
                    : context.l10n.waterAnalyzeAction,
              ),
            ),
            if (_busy) const HareupLoading(),
            if (_message != null)
              HareupGuidance(
                title: context.l10n.commonNotice,
                message: _message!,
                warning: true,
              ),
            if (_result case final result?) ...[
              const SizedBox(height: 16),
              HareupFormSection(
                title: context.l10n.analysisResultTitle,
                children: [
                  if (widget.runtime.validation.waterPercent &&
                      result.current != null) ...[
                    Text(
                      context.l10n.waterCurrentLevelReading(
                        result.current!.toStringAsFixed(1),
                      ),
                    ),
                    if (result.previous != null) ...[
                      Text(
                        context.l10n.waterPreviousLevelReading(
                          result.previous!.toStringAsFixed(1),
                        ),
                      ),
                      Text(
                        result.previous! > result.current!
                            ? context.l10n.waterDecreasedSince(
                                (result.previous! - result.current!)
                                    .toStringAsFixed(1),
                              )
                            : result.previous! < result.current!
                            ? context.l10n.waterIncreasedSince(
                                (result.current! - result.previous!)
                                    .toStringAsFixed(1),
                              )
                            : context.l10n.waterNoChange,
                      ),
                    ],
                  ] else
                    Text(context.l10n.waterSavedPending),
                  if (result.reason.isNotEmpty) Text(result.reason),
                  Text(context.l10n.waterEstimateDisclaimer),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
