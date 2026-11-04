import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

import '../../l10n/l10n.dart';

/// Management screen with explicit selection and confirmed, sequential deletion.
class SelectionManagementPage<T> extends StatefulWidget {
  const SelectionManagementPage({
    super.key,
    required this.title,
    required this.emptyMessage,
    required this.addLabel,
    required this.cubit,
    required this.idOf,
    required this.nameOf,
    required this.iconOf,
    required this.onAdd,
    required this.onDelete,
    required this.onRetry,
    required this.failureMessage,
    required this.confirmMessage,
  });
  final String title, emptyMessage, addLabel, confirmMessage;
  final LoadCubit<List<T>> cubit;
  final String Function(T) idOf, nameOf;
  final IconData Function(T) iconOf;
  final VoidCallback onAdd, onRetry;
  final Future<bool> Function(T) onDelete;
  final String Function() failureMessage;

  @override
  State<SelectionManagementPage<T>> createState() =>
      _SelectionManagementPageState<T>();
}

class _SelectionManagementPageState<T>
    extends State<SelectionManagementPage<T>> {
  final _selected = <String>{};
  bool _busy = false;

  Future<void> _delete(List<T> items) async {
    final chosen = items
        .where((item) => _selected.contains(widget.idOf(item)))
        .toList();
    if (chosen.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.selectionDeleteTitle(chosen.length)),
        content: SingleChildScrollView(
          child: Text(
            '${chosen.map(widget.nameOf).join(', ')}\n\n${widget.confirmMessage}',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.dsL10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _busy = true);
    String? failure;
    for (final item in chosen) {
      final removed = await widget.onDelete(item);
      if (!mounted) return;
      if (removed) {
        _selected.remove(widget.idOf(item));
      } else {
        failure ??= widget.failureMessage();
      }
    }
    setState(() => _busy = false);
    if (failure != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(failure)));
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<LoadCubit<List<T>>, LoadState<List<T>>>(
    bloc: widget.cubit,
    builder: (context, state) {
      final items = switch (state) {
        Loaded<List<T>>(:final data) => data,
        _ => <T>[],
      };
      final selectedCount = items
          .where((item) => _selected.contains(widget.idOf(item)))
          .length;
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: HareupContent(
          child: LoadView<List<T>>(
            state: state,
            emptyMessage: widget.emptyMessage,
            onRetry: widget.onRetry,
            builder: (context, data) => ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: HareupSpacing.pageMargin,
                vertical: HareupSpacing.small,
              ),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];
                final id = widget.idOf(item);
                return Card(
                  child: CheckboxListTile(
                    secondary: CircleAvatar(child: Icon(widget.iconOf(item))),
                    title: Text(widget.nameOf(item)),
                    value: _selected.contains(id),
                    onChanged: _busy
                        ? null
                        : (checked) => setState(() {
                            if (checked == true) {
                              _selected.add(id);
                            } else {
                              _selected.remove(id);
                            }
                          }),
                  ),
                );
              },
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              HareupSpacing.pageMargin,
              HareupSpacing.small,
              HareupSpacing.pageMargin,
              HareupSpacing.medium,
            ),
            child: Align(
              alignment: Alignment.center,
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: HareupSpacing.maxContentWidth,
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed:
                        _busy ||
                            state is Loading<List<T>> ||
                            state is Initial<List<T>> ||
                            state is Failed<List<T>>
                        ? null
                        : selectedCount == 0
                        ? widget.onAdd
                        : () => _delete(items),
                    icon: Icon(
                      selectedCount == 0 ? Icons.add : Icons.delete_outline,
                    ),
                    label: Text(
                      selectedCount == 0
                          ? widget.addLabel
                          : context.l10n.selectionDeleteAction(selectedCount),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

/// Pinned, full-width action used by management screens.
class ManagementBottomButton extends StatelessWidget {
  const ManagementBottomButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.fromLTRB(
        HareupSpacing.pageMargin,
        HareupSpacing.small,
        HareupSpacing.pageMargin,
        HareupSpacing.medium,
      ),
      child: Align(
        alignment: Alignment.center,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: HareupSpacing.maxContentWidth,
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onPressed,
              icon: Icon(icon),
              label: Text(label),
            ),
          ),
        ),
      ),
    ),
  );
}
