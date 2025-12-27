import 'package:flutter/material.dart';

class RoutineNameField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const RoutineNameField({super.key, required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Routine Name',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a routine name';
        }
        return null;
      },
      onChanged: onChanged,
    );
  }
}
