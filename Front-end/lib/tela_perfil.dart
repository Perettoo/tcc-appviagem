import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';

class TelaPerfil extends StatefulWidget {
  final User? user;
  const TelaPerfil({super.key, this.user});

  @override
  State<TelaPerfil> createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  static const Color verdePrincipal = Color(0xFF2E7D73);
  static const Color fundoLeve = Color(0xFFF5F7F9);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundoLeve,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // CABEÇALHO COM FOTO DO PERFIL
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: const BoxDecoration(
                color: verdePrincipal,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  // FOTO DO PERFIL
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: verdePrincipal.withValues(alpha: 0.2),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: verdePrincipal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // NOME DO USUÁRIO
                  Text(
                    widget.user?.name ?? "Usuário",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // USERNAME
                  Text(
                    "@${(widget.user?.name ?? 'usuario').toLowerCase().replaceAll(' ', '')}",
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // OPÇÕES DO PERFIL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildProfileOption(
                    icon: Icons.card_giftcard,
                    title: "Convidar Amigos",
                    subtitle: "Compartilhe seu código de referência",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: "Informações Pessoais",
                    subtitle: "Edite seus dados pessoais",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.security,
                    title: "Login e Segurança",
                    subtitle: "Gerencie senhas e autenticação",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.person_outline,
                    title: "Perfil Pessoal",
                    subtitle: "Customize seu perfil público",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.message_outlined,
                    title: "Centro de Mensagens",
                    subtitle: "Gerencie seus contatos",
                    onTap: () {},
                  ),
                  _buildProfileOption(
                    icon: Icons.lock_outline,
                    title: "Privacidade e Dados",
                    subtitle: "Controle suas informações",
                    onTap: () {},
                  ),
                  const SizedBox(height: 20),
                  // BOTÃO DE LOGOUT
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Implementar logout aqui
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Confirmar Logout"),
                            content: const Text(
                              "Você tem certeza que deseja sair?",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("Cancelar"),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Implement actual logout here
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  "Sair",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade100,
                        foregroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Sair",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ÍCONE
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: verdePrincipal.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: verdePrincipal, size: 24),
                ),
                const SizedBox(width: 16),
                // TEXTO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                // SETA
                const Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
