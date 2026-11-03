import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_media/media.dart';
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
          if (mounted) setState(() => _message = '사진은 3MB 이하여야 합니다.');
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
        setState(() => _message = '사진을 가져오지 못했습니다.');
      }
    } catch (_) {
      if (mounted) setState(() => _message = '사진을 읽지 못했습니다.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _analyze() async {
    final service = widget.runtime.service;
    if (service is! WaterLevelService) {
      setState(() => _message = '사진 분석 서비스를 사용할 수 없습니다.');
      return;
    }
    if (_setup &&
        ![
          'front',
          'back',
          'top',
        ].every((angle) => _photos[angle]?.isNotEmpty == true)) {
      setState(() => _message = '정수기의 앞·뒤·위 사진을 모두 선택해 주세요.');
      return;
    }
    if (!_setup && _photo == null) {
      setState(() => _message = '정수기 사진을 선택해 주세요.');
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
          _message = failure.message;
        case Success<WaterLevelResult>(:final value):
          if (value.status != 'ok') {
            _message = '수위를 확인할 수 없습니다. ${value.reason}';
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(_setup ? '정수기 초기 설정' : '수위 관찰')),
    body: HareupContent(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            _setup
                ? '정수기의 앞·뒤·위 사진으로 초기 수위를 추정합니다.'
                : '정수기 사진 한 장을 올려 직전 수위와 비교합니다.',
          ),
          if (_setup) ...[
            for (final entry in const {
              'front': '앞',
              'back': '뒤',
              'top': '위',
            }.entries) ...[
              Text('${entry.value} 사진'),
              HareupPhotoPreview(
                bytes: _photos[entry.key],
                label: '${entry.value} 사진',
              ),
              HareupPhotoActions(
                prefix: '${entry.value} 사진',
                onCamera: _busy ? null : () => _pick(entry.key, true),
                onGallery: _busy ? null : () => _pick(entry.key, false),
              ),
            ],
          ] else ...[
            HareupPhotoPreview(bytes: _photo, label: '정수기 사진'),
            HareupPhotoActions(
              onCamera: _busy ? null : () => _pick('', true),
              onGallery: _busy ? null : () => _pick('', false),
            ),
          ],
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _analyze,
            child: Text(_setup ? '초기 설정 분석' : '수위 분석'),
          ),
          if (_busy) const Center(child: CircularProgressIndicator()),
          if (_message != null) Text(_message!),
          if (_result case final result?) ...[
            const SizedBox(height: 16),
            if (widget.runtime.validation.waterPercent) ...[
              Text('현재 수위: ${result.current!.toStringAsFixed(1)}% (추정)'),
              if (result.previous != null) ...[
                Text('직전 수위: ${result.previous!.toStringAsFixed(1)}% (추정)'),
                Text(
                  result.previous! > result.current!
                      ? '이전보다 ${(result.previous! - result.current!).toStringAsFixed(1)}%p 감소'
                      : result.previous! < result.current!
                      ? '이전보다 ${(result.current! - result.previous!).toStringAsFixed(1)}%p 증가 (물 보충 가능)'
                      : '이전과 변화 없음',
                ),
              ],
            ] else
              const Text('분석을 저장했습니다. 수위 추정치는 정확도 검증 후 표시됩니다.'),
            if (result.reason.isNotEmpty) Text(result.reason),
            const Text('사진 분석 결과는 추정치이며 실제 음수량을 의미하지 않습니다.'),
          ],
        ],
      ),
    ),
  );
}
