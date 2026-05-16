import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';
import 'package:test_tcc/campo_formulario.dart';

class CriarContas extends StatefulWidget {
  final List<User> usuariosExistentes; // Para checar se o email já existe

  const CriarContas({super.key, required this.usuariosExistentes});

  @override
  State<CriarContas> createState() => _CriarContasState();
}

class _CriarContasState extends State<CriarContas> {
  static const Color verdePrincipal = Color(0xFF2E7D73);
  static const Color fundoLeve = Color(0xFFF5F7F9);

  final TextEditingController controllernome = TextEditingController();
  final TextEditingController controlleremail = TextEditingController();
  final TextEditingController controllersenha = TextEditingController();
  final TextEditingController controllerConfirmarSenha =
      TextEditingController();

  String? _erroSenha;
  TipoUsuario _tipoSelecionado = TipoUsuario.carona;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoLeve,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // --- CABEÇALHO DINÂMICO ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 40),
              decoration: const BoxDecoration(
                color: verdePrincipal,
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

            // --- FORMULÁRIO ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 20),

                  // --- CARD COM FORMULÁRIO ---
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

                        if (_erroSenha != null)
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
                                _erroSenha!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),

                        // --- SELEÇÃO DE TIPO ---
                        Container(
                          width: double.infinity, // <--- A MÁGICA ACONTECE AQUI
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: fundoLeve,
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
                                  color: verdePrincipal,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                alignment: WrapAlignment.center,
                                children: [
                                  FilterChip(
                                    label: const Text('Passageiro'),
                                    selected:
                                        _tipoSelecionado == TipoUsuario.carona,
                                    onSelected: (val) => setState(
                                      () =>
                                          _tipoSelecionado = TipoUsuario.carona,
                                    ),
                                    backgroundColor: Colors.white,
                                    selectedColor: verdePrincipal,
                                    labelStyle: TextStyle(
                                      color:
                                          _tipoSelecionado == TipoUsuario.carona
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    side: BorderSide(
                                      color:
                                          _tipoSelecionado == TipoUsuario.carona
                                          ? verdePrincipal
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  FilterChip(
                                    label: const Text('Motorista'),
                                    selected:
                                        _tipoSelecionado ==
                                        TipoUsuario.motorista,
                                    onSelected: (val) => setState(
                                      () => _tipoSelecionado =
                                          TipoUsuario.motorista,
                                    ),
                                    backgroundColor: Colors.white,
                                    selectedColor: verdePrincipal,
                                    labelStyle: TextStyle(
                                      color:
                                          _tipoSelecionado ==
                                              TipoUsuario.motorista
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    side: BorderSide(
                                      color:
                                          _tipoSelecionado ==
                                              TipoUsuario.motorista
                                          ? verdePrincipal
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  FilterChip(
                                    label: const Text('Ambos'),
                                    selected:
                                        _tipoSelecionado == TipoUsuario.ambos,
                                    onSelected: (val) => setState(
                                      () =>
                                          _tipoSelecionado = TipoUsuario.ambos,
                                    ),
                                    backgroundColor: Colors.white,
                                    selectedColor: verdePrincipal,
                                    labelStyle: TextStyle(
                                      color:
                                          _tipoSelecionado == TipoUsuario.ambos
                                          ? Colors.white
                                          : Colors.grey[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                    side: BorderSide(
                                      color:
                                          _tipoSelecionado == TipoUsuario.ambos
                                          ? verdePrincipal
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- BOTÃO FINALIZAR ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          String nome = controllernome.text.trim();
                          String email = controlleremail.text.trim();
                          String senha = controllersenha.text;
                          String confirmarSenha = controllerConfirmarSenha.text;

                          bool emailValido = RegExp(
                            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
                          ).hasMatch(email);

                          if (nome.isEmpty || email.isEmpty || senha.isEmpty) {
                            _erroSenha = 'Preencha todos os campos.';
                          } else if (!emailValido) {
                            _erroSenha =
                                'Digite um e-mail válido (ex: nome@email.com).';
                          } else if (widget.usuariosExistentes.any(
                            (u) => u.email == email,
                          )) {
                            _erroSenha =
                                'Este e-mail já está em uso por outra conta.';
                          } else if (senha.length < 8) {
                            _erroSenha =
                                'A senha deve ter no mínimo 8 caracteres.';
                          } else if (senha != confirmarSenha) {
                            _erroSenha = 'As senhas não coincidem.';
                          } else {
                            _erroSenha = null;
                            User novoUsuario = User(
                              name: nome,
                              email: email,
                              password: senha,
                              tipo: _tipoSelecionado,
                            );
                            Navigator.pop(context, novoUsuario);
                          }
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: verdePrincipal,
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

                  // --- BOTÃO CANCELAR ---
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: verdePrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: const BorderSide(color: verdePrincipal, width: 2),
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
}
