import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  const CustomTextFormField({
    super.key,
    required this.labelText,
    required this.validateText,
    required this.onSaved,
    this.validator,
    this.inputType = TextInputType.text,
  });
  final String labelText;
  final String validateText;
  final Function(String?)? onSaved;
  final String? Function(String?)? validator;
  final TextInputType inputType;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: labelText,
          fillColor: Colors.black,
          border: const OutlineInputBorder(),
        ),
        keyboardType: inputType,
        validator: validator ??
            (value) {
              if (value!.isEmpty) {
                return validateText;
              }
              return null;
            },
        onSaved: onSaved,
      ),
    );
  }
}
