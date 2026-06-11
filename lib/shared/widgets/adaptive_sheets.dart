import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'action_buttons.dart';

Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String cancelLabel = 'Annuler',
  String confirmLabel = 'Confirmer',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => Dialog(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.muted, height: 1.4),
            ),
            const SizedBox(height: 24),
            PrimaryActionButton(
              label: confirmLabel,
              onPressed: () => Navigator.of(context).pop(true),
            ),
            const SizedBox(height: 10),
            SecondaryActionButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(context).pop(false),
            ),
          ],
        ),
      ),
    ),
  );
  return result ?? false;
}

Future<void> showAppActionSheet(
  BuildContext context, {
  required List<AppSheetAction> actions,
  String cancelLabel = 'Annuler',
}) async {
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppTheme.sheet,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
    ),
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.24),
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            const SizedBox(height: 8),
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              _SheetRow(action: actions[i]),
            ],
            Divider(
              height: 8,
              thickness: 8,
              color: AppTheme.ink,
            ),
            _SheetRow(
              action: AppSheetAction(
                label: cancelLabel,
                onPressed: () {},
              ),
              muted: true,
            ),
          ],
        ),
      );
    },
  );
}

class AppSheetAction {
  const AppSheetAction({
    required this.label,
    required this.onPressed,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool destructive;
}

class _SheetRow extends StatelessWidget {
  const _SheetRow({required this.action, this.muted = false});

  final AppSheetAction action;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final color = action.destructive
        ? Colors.redAccent
        : muted
        ? AppTheme.muted
        : Colors.white;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          Navigator.of(context).pop();
          if (!muted) action.onPressed();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          child: Text(
            action.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
