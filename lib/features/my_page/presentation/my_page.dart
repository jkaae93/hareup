import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import '../../../l10n/l10n.dart';

class MyPage extends StatelessWidget {
  const MyPage({
    super.key,
    required this.onFamily,
    required this.onSettings,
    this.onSwitchFamily,
  });
  final VoidCallback onFamily;
  final VoidCallback onSettings;
  final VoidCallback? onSwitchFamily;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.navMyPage)),
    body: HareupContent(
      child: ListView(
        padding: const EdgeInsets.all(HareupSpacing.pageMargin),
        children: [
          HareupCard(
            leading: const CircleAvatar(child: Icon(Icons.people_outline)),
            title: context.l10n.homeManageFamily,
            trailing: const Icon(Icons.chevron_right),
            onTap: onFamily,
          ),
          if (onSwitchFamily != null)
            HareupCard(
              leading: const CircleAvatar(
                child: Icon(Icons.switch_account_outlined),
              ),
              title: context.l10n.homeSwitchFamily,
              trailing: const Icon(Icons.chevron_right),
              onTap: onSwitchFamily,
            ),
          HareupCard(
            leading: const CircleAvatar(child: Icon(Icons.settings_outlined)),
            title: context.l10n.settingsTitle,
            trailing: const Icon(Icons.chevron_right),
            onTap: onSettings,
          ),
        ],
      ),
    ),
  );
}
