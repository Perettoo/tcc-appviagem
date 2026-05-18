import 'package:flutter/material.dart';

class CampoFormulario extends StatelessWidget {
  final String label;
  final bool isPassword;
  final TextEditingController controller;
  final IconData? icon;

  const CampoFormulario({
    super.key,
    required this.label,
    required this.isPassword,
    required this.controller,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
      ),
    );
  }
}
