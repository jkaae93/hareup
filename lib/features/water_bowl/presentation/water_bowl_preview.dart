import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import '../../photo_analysis/data/unavailable_analysis_service.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/data/memory_records_repository.dart';
import 'package:hareup_media/media.dart';
import '../data/memory_water_bowl_repository.dart';
import '../domain/water_bowl.dart';
import 'water_bowl_cubit.dart';
import 'water_bowl_page.dart';

class _PreviewPhotoSource implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromCamera() async => const PhotoCancelled();
  @override
  Future<PhotoSelection> pickFromGallery() async => const PhotoCancelled();
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

@Preview(name: '물그릇 빈 목록', group: '물그릇')
Widget waterBowlPreview() => BlocProvider(
  create: (_) => WaterBowlCubit(MemoryWaterBowlRepository())..load(),
  child: MaterialApp(
    theme: HareupTheme.light,
    home: WaterBowlPage(
      pets: const [BowlPetOption(id: 'sample', name: '나비')],
      photoSource: _PreviewPhotoSource(),
      analysisRuntime: const AnalysisRuntime(
        service: UnavailableAnalysisService(),
        groupId: 'local-development',
      ),
      recordsRepository: MemoryRecordsRepository(),
    ),
  ),
);
