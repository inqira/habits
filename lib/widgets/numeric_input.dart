import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class NumericInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String? hint;
  final InputDecoration Function({
    required String labelText,
    String? hintText,
  }) buildInputDecoration;
  final int minValue;
  final int? maxValue;
  final int step;

  const NumericInput({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    required this.buildInputDecoration,
    this.minValue = 0,
    this.maxValue,
    this.step = 1,
  });

  void _increment() {
    final currentValue = int.tryParse(controller.text) ?? 0;
    if (maxValue == null || currentValue < maxValue!) {
      controller.text = (currentValue + step).toString();
    }
  }

  void _decrement() {
    final currentValue = int.tryParse(controller.text) ?? 0;
    if (currentValue > minValue) {
      controller.text = (currentValue - step).toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: buildInputDecoration(
              labelText: label,
              hintText: hint,
            ).copyWith(
              suffixIcon: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    onTap: _increment,
                    child: const Icon(
                      Icons.keyboard_arrow_up,
                      size: 20,
                    ),
                  ),
                  InkWell(
                    onTap: _decrement,
                    child: const Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a value';
              }
              final numValue = int.tryParse(value);
              if (numValue == null) {
                return 'Please enter a valid number';
              }
              if (numValue < minValue) {
                return 'Value must be at least $minValue';
              }
              if (maxValue != null && numValue > maxValue!) {
                return 'Value must not exceed $maxValue';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
