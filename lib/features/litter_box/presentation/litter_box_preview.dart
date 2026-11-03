import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_media/media.dart';
import '../data/memory_litter_box_repository.dart';
import '../domain/litter_box.dart';
import 'litter_box_cubit.dart';
import 'litter_box_page.dart';

class _PreviewPhotoSource implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromCamera() async => const PhotoCancelled();
  @override
  Future<PhotoSelection> pickFromGallery() async => const PhotoCancelled();
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

@Preview(name: '화장실 빈 목록', group: '화장실')
Widget litterBoxPreview() => BlocProvider(
  create: (_) => LitterBoxCubit(MemoryLitterBoxRepository())..load(),
  child: MaterialApp(
    theme: HareupTheme.light,
    home: LitterBoxPage(
      cats: const [CatOption(id: 'sample', name: '나비')],
      photoSource: _PreviewPhotoSource(),
    ),
  ),
);
