import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_media/media.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../../pet/domain/pet.dart';
import '../domain/health_chat.dart';

class HealthChatPage extends StatefulWidget {
  const HealthChatPage({
    super.key,
    required this.repository,
    required this.groupId,
    required this.pets,
    required this.photoSource,
  });
  final HealthChatRepository repository;
  final String groupId;
  final List<Pet> pets;
  final PhotoSource photoSource;
  @override
  State<HealthChatPage> createState() => _HealthChatPageState();
}

class _HealthChatPageState extends State<HealthChatPage> {
  final _text = TextEditingController();
  final _scroll = ScrollController();
  final _selected = <String>{};
  late final Stream<List<HealthChatMessage>> _messages;
  Uint8List? _photo;
  bool _busy = false;
  int _messageCount = -1;
  @override
  void initState() {
    super.initState();
    _messages = widget.repository.watch(widget.groupId);
  }

  @override
  void dispose() {
    _text.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final selection = await widget.photoSource.pickFromGallery();
    if (!mounted) return;
    if (selection is PhotoSelectionFailed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.chatPhotoSelectFailed)),
      );
      return;
    }
    if (selection is! PhotoSelected) return;
    try {
      if (await selection.file.length() > 3 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.waterPhotoTooLarge)),
          );
        }
        return;
      }
      final bytes = await selection.file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.photoReadFailed)));
      }
    }
  }

  Future<void> _mention() async {
    final selected = Set<String>.of(_selected);
    final result = await showDialog<Set<String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(context.l10n.chatMentionPets),
          content: SizedBox(
            width: double.maxFinite,
            child: widget.pets.isEmpty
                ? Text(context.l10n.chatNoPets)
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (final pet in widget.pets)
                          CheckboxListTile(
                            title: Text(pet.name),
                            value: selected.contains(pet.id),
                            onChanged: (value) => setDialogState(() {
                              if (value == true) {
                                selected.add(pet.id);
                              } else {
                                selected.remove(pet.id);
                              }
                            }),
                          ),
                      ],
                    ),
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(context.dsL10n.cancelAction),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, selected),
              child: Text(context.l10n.commonDone),
            ),
          ],
        ),
      ),
    );
    if (mounted && result != null) {
      setState(() {
        _selected
          ..clear()
          ..addAll(result);
      });
    }
  }

  Future<void> _send() async {
    if (_busy || (_text.text.trim().isEmpty && _photo == null)) return;
    setState(() => _busy = true);
    final result = await widget.repository.send(
      groupId: widget.groupId,
      text: _text.text,
      petIds: _selected.toList(),
      languageCode: Localizations.localeOf(context).languageCode,
      photo: _photo,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Success<void>():
        _text.clear();
        setState(() {
          _selected.clear();
          _photo = null;
        });
      case Failure<void>(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failureDisplayMessage(context, failure))),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.chatTitle)),
    body: SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(context.l10n.chatDisclaimer),
          ),
          Expanded(
            child: StreamBuilder<List<HealthChatMessage>>(
              stream: _messages,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(context.l10n.chatLoadFailed));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final messages = snapshot.data!;
                if (messages.isEmpty) {
                  return Center(child: Text(context.l10n.chatEmptyPrompt));
                }
                if (_messageCount != messages.length) {
                  _messageCount = messages.length;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _scroll.hasClients) {
                      _scroll.jumpTo(_scroll.position.maxScrollExtent);
                    }
                  });
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final item = messages[index];
                    final mine = item.role == 'user';
                    return Align(
                      alignment: mine
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 340),
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: mine
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(
                                  context,
                                ).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              mine
                                  ? context.l10n.chatGuardianLabel
                                  : context.l10n.chatAssistantLabel,
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                            if (item.mentions.isNotEmpty)
                              Text(
                                item.mentions.map((name) => '@$name').join(' '),
                              ),
                            if (item.photoPath case final path?)
                              FutureBuilder<Uint8List?>(
                                future: widget.repository.loadPhoto(path),
                                builder: (context, image) => image.hasData
                                    ? Image.memory(
                                        image.data!,
                                        height: 160,
                                        fit: BoxFit.contain,
                                      )
                                    : Text(context.l10n.chatPhotoLoading),
                              ),
                            if (item.text.isNotEmpty) Text(item.text),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          if (_selected.isNotEmpty)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final pet in widget.pets.where(
                    (pet) => _selected.contains(pet.id),
                  ))
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: InputChip(
                        label: Text('@${pet.name}'),
                        onDeleted: _busy
                            ? null
                            : () => setState(() => _selected.remove(pet.id)),
                      ),
                    ),
                ],
              ),
            ),
          if (_photo != null)
            Row(
              children: [
                const SizedBox(width: 12),
                Image.memory(_photo!, width: 64, height: 64, fit: BoxFit.cover),
                IconButton(
                  onPressed: _busy ? null : () => setState(() => _photo = null),
                  icon: const Icon(Icons.close),
                  tooltip: context.l10n.chatRemovePhoto,
                ),
              ],
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _busy ? null : _mention,
                  icon: const Icon(Icons.alternate_email),
                  tooltip: context.l10n.chatMentionPets,
                ),
                IconButton(
                  onPressed: _busy ? null : _pickPhoto,
                  icon: const Icon(Icons.photo_outlined),
                  tooltip: context.l10n.chatAttachPhoto,
                ),
                Expanded(
                  child: TextField(
                    controller: _text,
                    enabled: !_busy,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      hintText: context.l10n.chatInputHint,
                      counterText: '',
                    ),
                  ),
                ),
                _busy
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : IconButton(
                        onPressed: _send,
                        icon: const Icon(Icons.send),
                        tooltip: context.l10n.chatSendAction,
                      ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
