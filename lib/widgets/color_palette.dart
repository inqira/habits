import 'package:flutter/material.dart';

import 'package:flex_color_scheme/flex_color_scheme.dart';

import 'package:habits/widgets/constrained_fitted_box.dart';

class ColorPalette extends StatelessWidget {
  const ColorPalette({
    super.key,
    this.selectedColor,
    required this.onColorSelected,
    this.maxWidth = 600,
    this.itemSize = 24.0,
    this.spacing = 12.0,
  });

  final FlexScheme? selectedColor;
  final ValueChanged<FlexScheme> onColorSelected;
  final double maxWidth;
  final double itemSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: ConstrainedFittedBox(
          maxWidth: maxWidth,
          child: Wrap(
            alignment: WrapAlignment.start,
            spacing: spacing,
            runSpacing: spacing,
            children: FlexScheme.values.map((scheme) {
              final isSelected = selectedColor == scheme;
              return InkWell(
                borderRadius: BorderRadius.circular(itemSize / 2),
                onTap: () => onColorSelected(scheme),
                child: Container(
                  width: itemSize,
                  height: itemSize,
                  decoration: BoxDecoration(
                    color: FlexThemeData.light(scheme: scheme).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
