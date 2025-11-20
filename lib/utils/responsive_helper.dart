import 'package:flutter/material.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= 1024;
  }

  // Get responsive font size
  static double getFontSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile * 0.9;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 0.95;
    }
    return mobile;
  }

  // Get responsive padding
  static double getPadding(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile * 0.75;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 0.85;
    }
    return mobile;
  }

  // Get responsive spacing
  static double getSpacing(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile * 0.7;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 0.85;
    }
    return mobile;
  }

  // Get responsive icon size
  static double getIconSize(BuildContext context, {
    required double mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isDesktop(context)) {
      return desktop ?? tablet ?? mobile * 0.8;
    } else if (isTablet(context)) {
      return tablet ?? mobile * 0.9;
    }
    return mobile;
  }

  // Get max content width for desktop
  static double getMaxContentWidth(BuildContext context) {
    if (isDesktop(context)) {
      return 800; // Max width for desktop content
    }
    return double.infinity;
  }
}
