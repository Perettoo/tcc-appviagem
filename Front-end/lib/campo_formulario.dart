import 'package:flutter/material.dart';

// Widget de campo de formulário reutilizável
class CampoFormulario extends StatelessWidget {
  // Texto que aparece como rótulo do campo
  final String label;
  // Define se o campo é para senha (oculta o texto)
  final bool isPassword;
  // Controlador para acessar o valor do campo
  final TextEditingController controller;
  // Ícone opcional para o campo
  final IconData? icon;

  // Construtor do widget
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
        obscureText: isPassword, // Oculta o texto se for senha
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          labelText: label,
          border: OutlineInputBorder(), // Deixa o campo mais visível
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
      ),
    );
  }
}
