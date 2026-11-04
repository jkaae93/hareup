import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';

import '../../l10n/l10n.dart';

class TargetGridTile extends StatelessWidget {
  const TargetGridTile({
    super.key,
    required this.name,
    required this.icon,
    required this.onTap,
  });
  final String name;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(HareupSpacing.small),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(child: Icon(icon)),
            const SizedBox(height: HareupSpacing.small),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> confirmTargetDeletion(BuildContext context, String name) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.targetDeleteTitle(name)),
        content: Text(context.l10n.targetDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.dsL10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.l10n.commonDelete),
          ),
        ],
      ),
    ) ??
    false;
