import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hareup_design_system/design_system.dart';
import 'app.dart';

@Preview(name: '홈', group: '하릅')
Widget homePreview() => const HareupApp();

@Preview(name: '빈 상태', group: '디자인 시스템')
Widget emptyPreview() => MaterialApp(
  theme: HareupTheme.light,
  home: const Scaffold(body: EmptyNotice(message: '등록된 항목이 없습니다.')),
);

@Preview(name: '핵심 컴포넌트와 상태', group: '디자인 시스템')
Widget componentPreview() => MaterialApp(
  theme: HareupTheme.light,
  home: const Scaffold(
    body: SafeArea(child: HareupContent(child: _ComponentsGallery())),
  ),
);

class _ComponentsGallery extends StatefulWidget {
  const _ComponentsGallery();
  @override
  State<_ComponentsGallery> createState() => _ComponentsGalleryState();
}

class _ComponentsGalleryState extends State<_ComponentsGallery> {
  bool _selected = true;

  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(HareupSpacing.medium),
    children: [
      const HareupSectionHeader(title: '버튼'),
      Wrap(
        spacing: HareupSpacing.small,
        runSpacing: HareupSpacing.small,
        children: [
          FilledButton(onPressed: () {}, child: const Text('기본')),
          const FilledButton(onPressed: null, child: Text('비활성')),
          OutlinedButton(onPressed: () {}, child: const Text('보조')),
          TextButton(onPressed: () {}, child: const Text('텍스트')),
        ],
      ),
      const SizedBox(height: HareupSpacing.large),
      const HareupSectionHeader(title: '입력'),
      const TextField(decoration: InputDecoration(labelText: '기본 입력')),
      const SizedBox(height: HareupSpacing.small),
      const TextField(
        decoration: InputDecoration(
          labelText: '오류 입력',
          errorText: '내용을 확인해 주세요.',
        ),
      ),
      const SizedBox(height: HareupSpacing.small),
      const TextField(
        enabled: false,
        decoration: InputDecoration(labelText: '비활성 입력'),
      ),
      const SizedBox(height: HareupSpacing.large),
      const HareupSectionHeader(title: '선택과 상태'),
      CheckboxListTile(
        title: const Text('선택됨'),
        value: _selected,
        onChanged: (value) => setState(() => _selected = value ?? false),
      ),
      const CheckboxListTile(title: Text('비활성'), value: false, onChanged: null),
      const Wrap(
        spacing: HareupSpacing.small,
        runSpacing: HareupSpacing.small,
        children: [
          HareupStatusBadge(label: '안내'),
          HareupStatusBadge(label: '완료', status: HareupStatus.success),
          HareupStatusBadge(label: '주의', status: HareupStatus.warning),
          HareupStatusBadge(label: '오류', status: HareupStatus.error),
        ],
      ),
      const SizedBox(height: HareupSpacing.large),
      const HareupPanel(child: Text('카드는 관련 정보를 묶습니다.')),
    ],
  );
}
