import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/config/app_constants.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/theme/app_spacing.dart';
import 'package:test_tcc/core/theme/app_typography.dart';
import 'package:test_tcc/domain/entities/carro.dart';
import 'package:test_tcc/presentation/controllers/carro_controller.dart';

/// Formulário de cadastro/edição de um carro. Recebe [carro] não-nulo para
/// editar; nulo para criar. Usa o [CarroController] global (provido na raiz).
class CarroFormPage extends StatefulWidget {
  final Carro? carro;

  const CarroFormPage({super.key, this.carro});

  bool get ehEdicao => carro != null;

  @override
  State<CarroFormPage> createState() => _CarroFormPageState();
}

class _CarroFormPageState extends State<CarroFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _marca;
  late final TextEditingController _modelo;
  late final TextEditingController _ano;
  late final TextEditingController _cor;
  late final TextEditingController _placa;
  late final TextEditingController _capacidade;

  @override
  void initState() {
    super.initState();
    final c = widget.carro;
    _marca = TextEditingController(text: c?.marca ?? '');
    _modelo = TextEditingController(text: c?.modelo ?? '');
    _ano = TextEditingController(text: c?.anoFabricacao.toString() ?? '');
    _cor = TextEditingController(text: c?.cor ?? '');
    _placa = TextEditingController(text: c?.placa ?? '');
    _capacidade = TextEditingController(text: c?.capacidade.toString() ?? '');
  }

  @override
  void dispose() {
    _marca.dispose();
    _modelo.dispose();
    _ano.dispose();
    _cor.dispose();
    _placa.dispose();
    _capacidade.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final controller = context.read<CarroController>();
    final ano = int.parse(_ano.text.trim());
    final capacidade = int.parse(_capacidade.text.trim());

    final ok = widget.ehEdicao
        ? await controller.atualizar(
            idCarro: widget.carro!.idCarro,
            marca: _marca.text.trim(),
            modelo: _modelo.text.trim(),
            anoFabricacao: ano,
            cor: _cor.text.trim(),
            placa: _placa.text.trim(),
            capacidade: capacidade,
          )
        : await controller.criar(
            marca: _marca.text.trim(),
            modelo: _modelo.text.trim(),
            anoFabricacao: ano,
            cor: _cor.text.trim(),
            placa: _placa.text.trim(),
            capacidade: capacidade,
          );

    if (!mounted) return;
    if (ok) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.ehEdicao ? 'Carro atualizado.' : 'Carro cadastrado.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(controller.error ?? 'Não foi possível salvar o carro.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final salvando = context.watch<CarroController>().salvando;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.ehEdicao ? 'Editar carro' : 'Novo carro'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            children: [
              _campo(
                controller: _marca,
                label: 'Marca',
                hint: 'Ex: Volkswagen',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.lg),
              _campo(
                controller: _modelo,
                label: 'Modelo',
                hint: 'Ex: Gol',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.lg),
              _campo(
                controller: _ano,
                label: 'Ano de fabricação',
                hint: 'Ex: 2020',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                validator: (v) {
                  final base = _obrigatorio(v);
                  if (base != null) return base;
                  final ano = int.tryParse(v!.trim());
                  final max = DateTime.now().year + 1;
                  if (ano == null ||
                      ano < AppConstants.carroAnoMin ||
                      ano > max) {
                    return 'Ano deve estar entre ${AppConstants.carroAnoMin} e $max.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _campo(
                controller: _cor,
                label: 'Cor',
                hint: 'Ex: Prata',
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: AppSpacing.lg),
              _campo(
                controller: _placa,
                label: 'Placa',
                hint: 'ABC1D23',
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp('[a-zA-Z0-9]')),
                  LengthLimitingTextInputFormatter(7),
                  _UpperCaseFormatter(),
                ],
                validator: (v) {
                  final base = _obrigatorio(v);
                  if (base != null) return base;
                  final placa = v!.trim().toUpperCase();
                  final ok = AppConstants.carroPlacaRegex.hasMatch(placa);
                  return ok ? null : 'Use o formato ABC1234 ou ABC1D23.';
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              _campo(
                controller: _capacidade,
                label: 'Capacidade (lugares, motorista incluso)',
                hint: 'Ex: 5',
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validator: (v) {
                  final base = _obrigatorio(v);
                  if (base != null) return base;
                  final cap = int.tryParse(v!.trim());
                  if (cap == null || cap < AppConstants.carroCapacidadeMin) {
                    return 'Capacidade deve ser de ao menos '
                        '${AppConstants.carroCapacidadeMin} (motorista incluso).';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xxl),
              FilledButton(
                onPressed: salvando ? null : _salvar,
                child: salvando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.onPrimary,
                        ),
                      )
                    : Text(widget.ehEdicao ? 'Salvar alterações' : 'Cadastrar carro'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _obrigatorio(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Campo obrigatório.' : null;

  Widget _campo({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    TextCapitalization textCapitalization = TextCapitalization.none,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTypography.label),
        const SizedBox(height: AppSpacing.sm),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          textCapitalization: textCapitalization,
          validator: validator ?? _obrigatorio,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.background,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}

/// Mantém o texto em maiúsculas (placa) preservando a posição do cursor.
class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}
