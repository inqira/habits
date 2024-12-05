import 'package:flutter/material.dart';

/// A widget that constrains its child's maximum dimensions while centering it.
class ConstrainedFittedBox extends StatelessWidget {
  /// Creates a [ConstrainedFittedBox].
  ///
  /// The [child] parameter is required.
  /// The [maxWidth] and [maxHeight] parameters are optional.
  const ConstrainedFittedBox({
    super.key,
    required this.child,
    this.maxWidth,
    this.maxHeight,
    this.fit = BoxFit.contain,
    this.alignment = Alignment.center,
  });

  /// The widget below this widget in the tree.
  final Widget child;

  /// The maximum width constraint to apply to the child.
  final double? maxWidth;

  /// The maximum height constraint to apply to the child.
  final double? maxHeight;

  /// How to inscribe the child into the space allocated during layout.
  final BoxFit fit;

  /// How to align the child within its bounds.
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(
          maxWidth: maxWidth ?? double.infinity,
          maxHeight: maxHeight ?? double.infinity,
        ),
        child: child,
      ),
    );
  }
}
