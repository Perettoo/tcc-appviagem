import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:test_tcc/core/theme/app_colors.dart';
import 'package:test_tcc/core/utils/greeting.dart';
import 'package:test_tcc/domain/entities/user.dart';
import 'package:test_tcc/presentation/controllers/auth_controller.dart';
import 'package:test_tcc/presentation/pages/grafico_page.dart';
import 'package:test_tcc/presentation/pages/grupos/gerenciar_grupo_page.dart';
import 'package:test_tcc/presentation/pages/home/motorista_page.dart';
import 'package:test_tcc/presentation/pages/login_page.dart';

class CaronaPage extends StatefulWidget {
  final User? user;
  const CaronaPage({super.key, this.user});

  @override
  State<CaronaPage> createState() => _CaronaPageState();
}

class _CaronaPageState extends State<CaronaPage> {
  int _selectedIndex = 0;
  String _selectedPeriod = 'Mensal';

  final Map<String, String> _gastosValores = const {
    'Diário': 'R\$ 350,00',
    'Semanal': 'R\$ 2.450,00',
    'Mensal': 'R\$ 10.650,00',
  };

  final Map<String, String> _gastosTextos = const {
    'Diário': 'Gasto Diário',
    'Semanal': 'Gasto Semanal',
    'Mensal': 'Gasto Mensal',
  };

  Future<void> _handleLogout() async {
    await context.read<AuthController>().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;
    if (_selectedIndex == 0) {
      bodyContent = _buildTelaHome();
    } else if (_selectedIndex == 1) {
      bodyContent = GraficoPage(user: widget.user);
    } else if (_selectedIndex == 2) {
      bodyContent = _buildTelaGrupos();
    } else if (_selectedIndex == 3) {
      bodyContent = _buildTelaChat();
    } else {
      bodyContent = _buildTelaPerfil();
    }

    return Scaffold(
      backgroundColor: AppColors.fundoLeve,
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.verdePrincipal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Dados'),
          BottomNavigationBarItem(
            icon: Icon(Icons.group_add),
            label: 'Grupos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Mensagem'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }

  Widget _buildTelaHome() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: AppColors.verdePrincipal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user?.name ?? 'Usuário',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        if (widget.user?.tipo == TipoUsuario.ambos)
                          Tooltip(
                            message: 'Modo Motorista',
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        MotoristaPage(user: widget.user),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.drive_eta,
                                color: Colors.white,
                                size: 24,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ),
                        IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.notifications_none,
                            color: Colors.white,
                            size: 28,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _gastosTextos[_selectedPeriod] ?? 'Gasto',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          PopupMenuButton(
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'Diário',
                                onTap: () => setState(
                                  () => _selectedPeriod = 'Diário',
                                ),
                                child: const Text('Diário'),
                              ),
                              PopupMenuItem(
                                value: 'Semanal',
                                onTap: () => setState(
                                  () => _selectedPeriod = 'Semanal',
                                ),
                                child: const Text('Semanal'),
                              ),
                              PopupMenuItem(
                                value: 'Mensal',
                                onTap: () => setState(
                                  () => _selectedPeriod = 'Mensal',
                                ),
                                child: const Text('Mensal'),
                              ),
                            ],
                            icon: const Icon(
                              Icons.more_horiz,
                              color: Colors.grey,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _gastosValores[_selectedPeriod] ?? 'R\$ 0,00',
                        style: const TextStyle(
                          color: AppColors.verdePrincipal,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GerenciarGrupoPage(
                          acao: 'Criar',
                          tipo: 'Privado',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.group),
                    label: const Text('Grupo Privado'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.verdePrincipal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GerenciarGrupoPage(
                          acao: 'Criar',
                          tipo: 'Público',
                        ),
                      ),
                    ),
                    icon: const Icon(Icons.public),
                    label: const Text('Grupo Público'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.grey[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Histórico Recente',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Ver tudo',
                    style: TextStyle(
                      color: AppColors.verdePrincipal,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4,
              itemBuilder: (context, index) {
                const trips = [
                  ('Campos Novos -> Unoesc', 'Gustavo', '- R\$6,25'),
                  ('Unoesc -> Campos Novos', 'Gustavo', '- R\$6,25'),
                  ('Centro -> Bairro Novo', 'Carlos', '- R\$8,50'),
                  ('Bairro Novo -> Centro', 'Ana', '- R\$7,00'),
                ];
                return _buildTripItem(
                  trips[index].$1,
                  trips[index].$2,
                  trips[index].$3,
                );
              },
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildTelaGrupos() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.verdePrincipal,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Text(
            'Gerenciar Grupos',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Criar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildOpcaoGrupoCard(
                Icons.add_moderator,
                'Criar Grupo Privado',
                'Para convidados com link/senha',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GerenciarGrupoPage(
                      acao: 'Criar',
                      tipo: 'Privado',
                    ),
                  ),
                ),
              ),
              _buildOpcaoGrupoCard(
                Icons.public,
                'Criar Grupo Público',
                'Aberto para qualquer pessoa da região',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GerenciarGrupoPage(
                      acao: 'Criar',
                      tipo: 'Público',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Participar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildOpcaoGrupoCard(
                Icons.lock_outline,
                'Entrar em Grupo Privado',
                'Usar código de convite',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GerenciarGrupoPage(
                      acao: 'Entrar',
                      tipo: 'Privado',
                    ),
                  ),
                ),
              ),
              _buildOpcaoGrupoCard(
                Icons.search,
                'Buscar Grupo Público',
                'Ver rotas disponíveis',
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const GerenciarGrupoPage(
                      acao: 'Entrar',
                      tipo: 'Público',
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTelaChat() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: const BoxDecoration(
            color: AppColors.verdePrincipal,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Text(
            'Mensagens',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Grupos de Carona',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildChatItem(
                'Unoesc Noturno',
                'Gustavo: Estou saindo da facul agora!',
                '21:15',
                isGroup: true,
              ),
              _buildChatItem(
                'Campos Novos -> Joaçaba',
                'Ana: Alguém tem vaga para amanhã?',
                'Ontem',
                isGroup: true,
              ),
              const SizedBox(height: 20),
              const Text(
                'Privado',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildChatItem(
                'Gustavo (Motorista)',
                'Te encontro na praça central.',
                '18:30',
                isGroup: false,
              ),
              _buildChatItem(
                'Carlos',
                'Obrigado pela carona cara!',
                'Segunda',
                isGroup: false,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTelaPerfil() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              color: AppColors.verdePrincipal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  'Meu Perfil',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: const Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: AppColors.verdePrincipal,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user?.name ?? 'Daniel Bezerra',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user?.email ?? 'daniel@tcc.com.br',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _buildProfileMenuItem(
                  Icons.group_add_outlined,
                  'Convidar Amigos',
                  'Compartilhe seu código de referência',
                ),
                _buildProfileMenuItem(
                  Icons.person_outline,
                  'Meus Dados',
                  'Informações pessoais, perfil e privacidade',
                ),
                _buildProfileMenuItem(
                  Icons.shield_outlined,
                  'Login e Segurança',
                  'Gerencie senhas e autenticação',
                ),
                _buildProfileMenuItem(
                  Icons.chat_bubble_outline,
                  'Centro de Mensagens',
                  'Gerencie seus contatos',
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleLogout,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red[50],
                      foregroundColor: Colors.red,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.exit_to_app),
                        SizedBox(width: 8),
                        Text(
                          'Sair',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripItem(String titulo, String motorista, String valor) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: AppColors.verdePrincipal.withValues(alpha: 0.1),
          child:
              const Icon(Icons.directions_car, color: AppColors.verdePrincipal),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text('Motorista: $motorista'),
        trailing: Text(
          valor,
          style: const TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildChatItem(
    String name,
    String lastMessage,
    String time, {
    required bool isGroup,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isGroup
              ? AppColors.verdePrincipal.withValues(alpha: 0.1)
              : Colors.grey[200],
          child: Icon(
            isGroup ? Icons.group : Icons.person,
            color: isGroup ? AppColors.verdePrincipal : Colors.grey[700],
          ),
        ),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Text(
          time,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildProfileMenuItem(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.verdePrincipal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.verdePrincipal),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: () {},
      ),
    );
  }

  Widget _buildOpcaoGrupoCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.verdePrincipal.withValues(alpha: 0.1),
          child: Icon(icon, color: AppColors.verdePrincipal),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
