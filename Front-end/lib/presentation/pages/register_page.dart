import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/widgets/campo_formulario.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController controllernome = TextEditingController();
  final TextEditingController controlleremail = TextEditingController();
  final TextEditingController controllersenha = TextEditingController();
  final TextEditingController controllerConfirmarSenha = TextEditingController();
  final TextEditingController controllerCpf = TextEditingController();

  DateTime? _dataNascimento;
  TipoUsuario _tipoSelecionado = TipoUsuario.passageiro;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AuthController>().clearError();
    });
  }

  @override
  void dispose() {
    controllernome.dispose();
    controlleremail.dispose();
    controllersenha.dispose();
    controllerConfirmarSenha.dispose();
    controllerCpf.dispose();
    super.dispose();
  }

  Future<void> _selecionarData() async {
    final hoje = DateTime.now();
    final escolhida = await showDatePicker(
      context: context,
      initialDate: _dataNascimento ?? DateTime(hoje.year - 18, hoje.month, hoje.day),
      firstDate: DateTime(1900),
      lastDate: hoje,
      helpText: 'Data de Nascimento',
    );
    if (escolhida != null) {
      setState(() => _dataNascimento = escolhida);
    }
  }

  Future<void> _handleSubmit() async {
    final auth = context.read<AuthController>();
    final user = await auth.register(
      name: controllernome.text,
      email: controlleremail.text,
      password: controllersenha.text,
      confirmPassword: controllerConfirmarSenha.text,
      cpf: controllerCpf.text,
      dataNascimento: _dataNascimento,
      tipo: _tipoSelecionado,
    );
    if (!mounted || user == null) return;
    Navigator.pop(context, user);
  }

  @override
  Widget build(BuildContext context) {
    final erroSenha = context.watch<AuthController>().error;

    return Scaffold(
      backgroundColor: AppColors.fundoLeve,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
              decoration: const BoxDecoration(
                color: AppColors.verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Icon(Icons.person_add, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Crie sua Conta',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Junte-se à comunidade de caronas',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CampoFormulario(
                          label: 'Nome Completo',
                          isPassword: false,
                          controller: controllernome,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        CampoFormulario(
                          label: 'Email',
                          isPassword: false,
                          controller: controlleremail,
                          icon: Icons.email,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: controllerCpf,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(11),
                          ],
                          decoration: InputDecoration(
                            labelText: 'CPF (somente números)',
                            prefixIcon: const Icon(Icons.badge),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InkWell(
                          onTap: _selecionarData,
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: 'Data de Nascimento',
                              prefixIcon: const Icon(Icons.calendar_today),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _dataNascimento == null
                                  ? 'Selecione uma data'
                                  : '${_dataNascimento!.day.toString().padLeft(2, '0')}/${_dataNascimento!.month.toString().padLeft(2, '0')}/${_dataNascimento!.year}',
                              style: TextStyle(
                                color: _dataNascimento == null
                                    ? Colors.grey
                                    : Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        CampoFormulario(
                          label: 'Senha',
                          isPassword: true,
                          controller: controllersenha,
                          icon: Icons.lock,
                        ),
                        const SizedBox(height: 16),
                        CampoFormulario(
                          label: 'Confirmar Senha',
                          isPassword: true,
                          controller: controllerConfirmarSenha,
                          icon: Icons.lock_outline,
                        ),
                        const SizedBox(height: 20),
                        if (erroSenha != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                erroSenha,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.fundoLeve,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Qual é seu tipo de perfil?',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: AppColors.verdePrincipal,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  _buildChip('Passageiro', TipoUsuario.passageiro),
                                  _buildChip('Motorista', TipoUsuario.motorista),
                                  _buildChip('Ambos', TipoUsuario.ambos),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.verdePrincipal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Finalizar Cadastro',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.verdePrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(
                          color: AppColors.verdePrincipal,
                          width: 2,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Voltar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, TipoUsuario tipo) {
    final selected = _tipoSelecionado == tipo;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _tipoSelecionado = tipo),
      backgroundColor: Colors.white,
      selectedColor: AppColors.verdePrincipal,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      side: BorderSide(
        color: selected ? AppColors.verdePrincipal : Colors.grey[300]!,
      ),
    );
  }
}
