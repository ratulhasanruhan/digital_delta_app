import 'package:flutter/material.dart';

import '../app/ui_tokens.dart';

/// Top-of-screen intro for feature hubs: title, description, optional child.
class DdPageIntro extends StatelessWidget {
  const DdPageIntro({
    super.key,
    required this.title,
    required this.description,
    this.child,
  });

  final String title;
  final String description;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              cs.primaryContainer.withValues(alpha: 0.55),
              cs.surfaceContainerHighest.withValues(alpha: 0.85),
            ],
          ),
          border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
          borderRadius: BorderRadius.circular(UiTokens.cardRadius),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: tt.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: tt.bodyMedium?.copyWith(
                color: cs.onSurface.withValues(alpha: 0.92),
                height: 1.4,
              ),
            ),
            if (child != null) ...[
              const SizedBox(height: 14),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
