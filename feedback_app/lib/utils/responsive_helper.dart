import 'package:flutter/material.dart';

class ResponsiveHelper {
  // Breakpoints
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  static const double largeDesktopBreakpoint = 1440;

  // Screen size checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static bool isLargeDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= largeDesktopBreakpoint;
  }

  // Get screen type
  static ScreenType getScreenType(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < mobileBreakpoint) return ScreenType.mobile;
    if (width < tabletBreakpoint) return ScreenType.smallTablet;
    if (width < desktopBreakpoint) return ScreenType.tablet;
    if (width < largeDesktopBreakpoint) return ScreenType.desktop;
    return ScreenType.largeDesktop;
  }

  // Responsive values
  static double getResponsiveValue(
    BuildContext context, {
    required double mobile,
    double? smallTablet,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile;
      case ScreenType.smallTablet:
        return smallTablet ?? mobile;
      case ScreenType.tablet:
        return tablet ?? smallTablet ?? mobile;
      case ScreenType.desktop:
        return desktop ?? tablet ?? smallTablet ?? mobile;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? smallTablet ?? mobile;
    }
  }

  // Responsive padding
  static EdgeInsets getResponsivePadding(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? smallTablet,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile ?? const EdgeInsets.all(16);
      case ScreenType.smallTablet:
        return smallTablet ?? mobile ?? const EdgeInsets.all(16);
      case ScreenType.tablet:
        return tablet ?? smallTablet ?? mobile ?? const EdgeInsets.all(20);
      case ScreenType.desktop:
        return desktop ??
            tablet ??
            smallTablet ??
            mobile ??
            const EdgeInsets.all(24);
      case ScreenType.largeDesktop:
        return largeDesktop ??
            desktop ??
            tablet ??
            smallTablet ??
            mobile ??
            const EdgeInsets.all(32);
    }
  }

  // Responsive margin
  static EdgeInsets getResponsiveMargin(
    BuildContext context, {
    EdgeInsets? mobile,
    EdgeInsets? smallTablet,
    EdgeInsets? tablet,
    EdgeInsets? desktop,
    EdgeInsets? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile ?? const EdgeInsets.all(16);
      case ScreenType.smallTablet:
        return smallTablet ?? mobile ?? const EdgeInsets.all(16);
      case ScreenType.tablet:
        return tablet ?? smallTablet ?? mobile ?? const EdgeInsets.all(20);
      case ScreenType.desktop:
        return desktop ??
            tablet ??
            smallTablet ??
            mobile ??
            const EdgeInsets.all(24);
      case ScreenType.largeDesktop:
        return largeDesktop ??
            desktop ??
            tablet ??
            smallTablet ??
            mobile ??
            const EdgeInsets.all(32);
    }
  }

  // Responsive font size
  static double getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    double? smallTablet,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      smallTablet: smallTablet,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Responsive spacing
  static double getResponsiveSpacing(
    BuildContext context, {
    required double mobile,
    double? smallTablet,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      smallTablet: smallTablet,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }

  // Grid columns based on screen size
  static int getGridColumns(
    BuildContext context, {
    int? mobile,
    int? smallTablet,
    int? tablet,
    int? desktop,
    int? largeDesktop,
  }) {
    final screenType = getScreenType(context);
    switch (screenType) {
      case ScreenType.mobile:
        return mobile ?? 1;
      case ScreenType.smallTablet:
        return smallTablet ?? mobile ?? 2;
      case ScreenType.tablet:
        return tablet ?? smallTablet ?? mobile ?? 2;
      case ScreenType.desktop:
        return desktop ?? tablet ?? smallTablet ?? mobile ?? 3;
      case ScreenType.largeDesktop:
        return largeDesktop ?? desktop ?? tablet ?? smallTablet ?? mobile ?? 4;
    }
  }

  // Aspect ratio based on screen size
  static double getResponsiveAspectRatio(
    BuildContext context, {
    required double mobile,
    double? smallTablet,
    double? tablet,
    double? desktop,
    double? largeDesktop,
  }) {
    return getResponsiveValue(
      context,
      mobile: mobile,
      smallTablet: smallTablet,
      tablet: tablet,
      desktop: desktop,
      largeDesktop: largeDesktop,
    );
  }
}

enum ScreenType { mobile, smallTablet, tablet, desktop, largeDesktop }

// Extension for easy access
extension ResponsiveExtension on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);
  bool get isLargeDesktop => ResponsiveHelper.isLargeDesktop(this);
  ScreenType get screenType => ResponsiveHelper.getScreenType(this);
}
