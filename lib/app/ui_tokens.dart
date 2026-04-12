import 'package:flutter/material.dart';

/// Spacing, radii, and layout limits shared across the app.
abstract final class UiTokens {
  static const double pageH = 20;
  static const double pageV = 16;
  static const double sectionGap = 24;
  static const double cardRadius = 16;
  static const double sheetRadius = 20;
  static const double maxContentWidth = 520;
  /// Clearance above bottom navigation + system inset (for FABs, etc.).
  static double fabClearance(BuildContext context) =>
      MediaQuery.paddingOf(context).bottom + 80;

  static const EdgeInsets pageInsets =
      EdgeInsets.symmetric(horizontal: pageH, vertical: pageV);
}
