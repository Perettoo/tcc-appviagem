import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:test_tcc/core/theme/app_colors.dart';

/// Campo de texto padrão do app. Suporta senha (com toggle de visibilidade),
/// ícone, validação e formatadores. Substitui o antigo CampoFormulario e os
/// TextField soltos espalhados pelas telas.
class AppTextField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData? icon;
  final bool isPassword;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final String? hint;

  const AppTextField({
    super.key,
    required this.label,
    required this.controller,
    this.icon,
    this.isPassword = false,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.textInputAction,
    this.onSubmitted,
    this.hint,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscure = widget.isPassword;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      obscureText: _obscure,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      validator: widget.validator,
      textInputAction: widget.textInputAction,
      onFieldSubmitted: widget.onSubmitted,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        prefixIcon: widget.icon != null ? Icon(widget.icon) : null,
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.textMuted,
                ),
              )
            : null,
      ),
    );
  }
}
