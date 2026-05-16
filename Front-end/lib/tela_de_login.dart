import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';
import 'package:test_tcc/campo_formulario.dart';
import 'package:test_tcc/criar_contas.dart';
import 'package:test_tcc/tela_carona.dart';
import 'package:test_tcc/tela_motorista.dart';
import 'package:test_tcc/tela_ambos.dart';

class TelaDeLogin extends StatefulWidget {
  // CORRIGIDO: O construtor agora é limpo, pois a lista de usuários nasce aqui dentro!
  const TelaDeLogin({super.key});

  @override
  State<TelaDeLogin> createState() => _TelaDeLoginState();
}

class _TelaDeLoginState extends State<TelaDeLogin> {
  static const Color verdePrincipal = Color(0xFF2E7D73);
  static const Color fundoLeve = Color(0xFFF5F7F9);

  String? _loginError;
  final TextEditingController loginController = TextEditingController();
  final TextEditingController senhaLoginController = TextEditingController();

  // A lista oficial de usuários fica aqui e é passada para as outras telas
  final List<User> _usuarios = [];

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
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
              decoration: const BoxDecoration(
                color: verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.directions_car,
                    size: 56,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Compartilhe Caronas',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Conecte-se e economize',
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

                  // --- CARD COM SHADOW ---
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
                      children: [
                        const Text(
                          'Faça seu Login',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: verdePrincipal,
                          ),
                        ),
                        const SizedBox(height: 24),
                        CampoFormulario(
                          label: 'E-mail / Usuário',
                          isPassword: false,
                          controller: loginController,
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        CampoFormulario(
                          label: 'Senha',
                          isPassword: true,
                          controller: senhaLoginController,
                          icon: Icons.lock,
                        ),
                        if (_loginError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.red.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Text(
                                _loginError!,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                // 1. Verificação do Admin
                                if (loginController.text == 'admin' &&
                                    senhaLoginController.text == 'admin') {
                                  _loginError = null;
                                  final adminUser = User(
                                    name: 'Daniel',
                                    email: 'admin',
                                    password: 'admin',
                                    tipo: TipoUsuario.ambos,
                                  );
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          TelaCarona(user: adminUser),
                                    ),
                                  ).then((_) {
                                    loginController.clear();
                                    senhaLoginController.clear();
                                  });
                                }
                                // 2. Verificação de Usuário Comum
                                else {
                                  try {
                                    final loggedUser = _usuarios.firstWhere(
                                      (u) =>
                                          (u.email == loginController.text ||
                                              u.name == loginController.text) &&
                                          u.password ==
                                              senhaLoginController.text,
                                    );

                                    _loginError = null;

                                    // Redireciona baseado no tipo de usuário
                                    Widget telaDestino;
                                    if (loggedUser.tipo ==
                                        TipoUsuario.motorista) {
                                      telaDestino = TelaMotorista(
                                        user: loggedUser,
                                      );
                                    } else if (loggedUser.tipo ==
                                        TipoUsuario.ambos) {
                                      telaDestino = TelaAmbos(user: loggedUser);
                                    } else {
                                      // Para carona
                                      telaDestino = TelaCarona(
                                        user: loggedUser,
                                      );
                                    }

                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => telaDestino,
                                      ),
                                    ).then((_) {
                                      loginController.clear();
                                      senhaLoginController.clear();
                                    });
                                  } catch (e) {
                                    _loginError = 'Usuário ou senha inválidos';
                                  }
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
                              'Entrar',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- DIVISOR ---
                  Row(
                    children: [
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Novo por aqui?',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(height: 1, color: Colors.grey[300]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- BOTÃO CRIAR CONTA ---
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        final novoUsuario = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CriarContas(usuariosExistentes: _usuarios),
                          ),
                        );

                        if (!context.mounted) return;

                        if (novoUsuario != null && novoUsuario is User) {
                          setState(() {
                            _usuarios.add(novoUsuario);
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Usuário cadastrado com sucesso! Faça login.',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: verdePrincipal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.person_add),
                      label: const Text(
                        'Criar nova conta',
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
