import 'package:flutter/material.dart';
import '../utils/disclaimer_helper.dart';

/// A warning icon widget that shows a disclaimer when tapped
/// Designed to be minimally intrusive with low opacity
class DisclaimerIcon extends StatelessWidget {
  /// Whether to show a snackbar (true) or modal (false) when tapped
  final bool useSnackbar;
  
  /// Optional custom size for the icon
  final double? size;
  
  /// Optional custom opacity (0.0 - 1.0)
  final double? opacity;
  
  const DisclaimerIcon({
    super.key,
    this.useSnackbar = true,
    this.size,
    this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size ?? 20.0;
    final iconOpacity = opacity ?? 0.4;
    
    return Tooltip(
      message: 'Disclaimer',
      child: InkWell(
        onTap: () {
          if (useSnackbar) {
            DisclaimerHelper.showDisclaimerSnackbar(context);
          } else {
            DisclaimerHelper.showDisclaimerModal(context);
          }
        },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Opacity(
            opacity: iconOpacity,
            child: Text(
              '⚠️',
              style: TextStyle(
                fontSize: iconSize,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
