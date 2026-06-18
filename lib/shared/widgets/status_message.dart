import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class StatusMessage extends StatelessWidget {
  const StatusMessage({this.error, this.notice, super.key});

  final String? error;
  final String? notice;

  @override
  Widget build(BuildContext context) {
    final text = error ?? notice;
    if (text == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: error == null ? AppTheme.neon : Colors.redAccent,
        ),
      ),
    );
  }
}
