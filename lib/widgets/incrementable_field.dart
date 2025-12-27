import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class IncrementableField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool isDouble;

  const IncrementableField({
    super.key,
    required this.controller,
    required this.label,
    this.isDouble = false,
  });

  void _increment() {
    if (isDouble) {
      double currentValue = double.tryParse(controller.text) ?? 0.0;
      currentValue++;
      controller.text = currentValue.toString();
    } else {
      int currentValue = int.tryParse(controller.text) ?? 0;
      currentValue++;
      controller.text = currentValue.toString();
    }
  }

  void _decrement() {
    if (isDouble) {
      double currentValue = double.tryParse(controller.text) ?? 0.0;
      if (currentValue > 0) {
        currentValue--;
        controller.text = currentValue.toString();
      }
    } else {
      int currentValue = int.tryParse(controller.text) ?? 0;
      if (currentValue > 0) {
        currentValue--;
        controller.text = currentValue.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: _decrement,
        ),
        Expanded(
          child: TextField(
            controller: controller,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              labelText: label,
            ),
            keyboardType: TextInputType.numberWithOptions(decimal: isDouble),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.add_circle_outline),
          onPressed: _increment,
        ),
      ],
    );
  }
}