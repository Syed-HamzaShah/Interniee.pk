import 'package:flutter/material.dart';

class ResponsiveLayout {
  static bool isMobileLayout(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTabletLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1200;
  }

  static bool isDesktopLayout(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1200;
  }

  static double getSpacing(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 12.0;
    if (width < 1200) return 16.0;
    return 20.0;
  }

  static EdgeInsets getPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return const EdgeInsets.all(16.0);
    if (width < 1200) return const EdgeInsets.all(24.0);
    return const EdgeInsets.all(32.0);
  }

  static double getFontSize(BuildContext context, {required double base}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return base;
    if (width < 1200) return base * 1.1;
    return base * 1.2;
  }

  static double getButtonHeight(BuildContext context) {
    return MediaQuery.of(context).size.width < 600 ? 48.0 : 56.0;
  }

  static double getIconSize(BuildContext context, {required double base}) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return base;
    if (width < 1200) return base * 1.2;
    return base * 1.4;
  }
}
