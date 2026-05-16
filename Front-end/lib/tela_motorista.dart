import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';
import 'package:test_tcc/tela_carona.dart';

class TelaMotorista extends StatefulWidget {
  final User? user;
  const TelaMotorista({super.key, this.user});

  @override
  State<TelaMotorista> createState() => _TelaMotoristaState();
}

class _TelaMotoristaState extends State<TelaMotorista> {
  static const Color verdePrincipal = Color(0xFF2E7D73);
  static const Color fundoLeve = Color(0xFFF5F7F9);

  int _selectedIndex = 0;

  String _selectedPeriodHome = 'Mensal';
  String _selectedPeriodRepasses = 'Diário';

  int? _pontoTocadoIndex;

  // --- DADOS DA HOME (GASTOS) ---
  final Map<String, String> _gastosValores = {
    'Diário': 'R\$ 120,00',
    'Semanal': 'R\$ 840,00',
    'Mensal': 'R\$ 3.250,00',
  };

  final Map<String, String> _gastosTextos = {
    'Diário': 'Gasto Diário',
    'Semanal': 'Gasto Semanal',
    'Mensal': 'Gasto Mensal',
  };

  // --- DADOS DO GRÁFICO ---
  final Map<String, List<double>> _gastosGraficos = {
    'Diário': [25.00, 50.00, 30.00, 65.00, 45.00, 0.0],
    'Semanal': [120.0, 180.0, 150.0, 210.0, 190.0, 0.0],
    'Mensal': [450.0, 600.0, 520.0, 700.0, 680.0, 800.0],
  };

  final Map<String, List<String>> _labelsGraficos = {
    'Diário': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
    'Semanal': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6'],
    'Mensal': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
  };

  // --- DADOS DE VIAGENS PARA O CONTROLE DE PAGAMENTOS ---
  final List<Map<String, dynamic>> _historicoViagens = [
    {
      'data': 'Hoje, 28 de Abril',
      'rota': 'Campos Novos ➔ Unoesc',
      'passageiros': [
        {'nome': 'Ana Clara', 'valor': 15.00, 'pago': false},
        {'nome': 'Lucas', 'valor': 15.00, 'pago': true},
        {'nome': 'Mariana', 'valor': 15.00, 'pago': false},
      ],
    },
    {
      'data': 'Ontem, 27 de Abril',
      'rota': 'Unoesc ➔ Campos Novos',
      'passageiros': [
        {'nome': 'Carlos', 'valor': 12.50, 'pago': true},
        {'nome': 'Beatriz', 'valor': 12.50, 'pago': false},
      ],
    },
    {
      'data': '25 de Abril',
      'rota': 'Campos Novos ➔ Unoesc',
      'passageiros': [
        {'nome': 'Gustavo', 'valor': 15.00, 'pago': true},
        {'nome': 'Lucas', 'valor': 15.00, 'pago': true},
      ],
    },
    {
      'data': '24 de Abril',
      'rota': 'Unoesc ➔ Campos Novos',
      'passageiros': [
        {'nome': 'Ana Clara', 'valor': 12.50, 'pago': true},
      ],
    },
  ];

  double get _totalPendente {
    double total = 0.0;
    for (var viagem in _historicoViagens) {
      for (var pass in viagem['passageiros']) {
        if (pass['pago'] == false) {
          total += pass['valor'];
        }
      }
    }
    return total;
  }

  void _atualizarPontoTocado(
    double posicaoX,
    double larguraTotal,
    int quantidadePontos,
  ) {
    const double paddingLaterais = 10.0;
    final double larguraUtil = larguraTotal - (paddingLaterais * 2);
    final double espacamento = larguraUtil / (quantidadePontos - 1);

    int index = ((posicaoX - paddingLaterais) / espacamento).round();
    index = index.clamp(0, quantidadePontos - 1);

    if (_pontoTocadoIndex != index) {
      setState(() {
        _pontoTocadoIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_selectedIndex == 0) {
      bodyContent = _buildTelaHomeMotorista();
    } else if (_selectedIndex == 1) {
      bodyContent = _buildTelaRepasses();
    } else if (_selectedIndex == 2) {
      bodyContent = _buildTelaGrupos();
    } else if (_selectedIndex == 3) {
      bodyContent = _buildTelaChat();
    } else {
      bodyContent = _buildTelaPerfilMotorista();
    }

    return Scaffold(
      backgroundColor: fundoLeve,
      body: bodyContent,
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: verdePrincipal,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 11,
        unselectedFontSize: 11,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Início"),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: "Repasses",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group_add), label: "Grupos"),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "Mensagem"),
          BottomNavigationBarItem(icon: Icon(Icons.drive_eta), label: "Perfil"),
        ],
      ),
    );
  }

  // ==========================================
  // --- TELA HOME (MOTORISTA) ---
  // ==========================================
  Widget _buildTelaHomeMotorista() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CABEÇALHO
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: verdePrincipal,
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
                            Icons.drive_eta,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getGreeting(),
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.user?.name ?? "Motorista Parceiro",
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
                            message: 'Modo Passageiro',
                            child: IconButton(
                              onPressed: () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TelaCarona(user: widget.user),
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.person,
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

                // CARD PRINCIPAL: GASTOS E SALDO PENDENTE
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
                            _gastosTextos[_selectedPeriodHome] ?? "Gasto",
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
                                  () => _selectedPeriodHome = 'Diário',
                                ),
                                child: const Text("Diário"),
                              ),
                              PopupMenuItem(
                                value: 'Semanal',
                                onTap: () => setState(
                                  () => _selectedPeriodHome = 'Semanal',
                                ),
                                child: const Text("Semanal"),
                              ),
                              PopupMenuItem(
                                value: 'Mensal',
                                onTap: () => setState(
                                  () => _selectedPeriodHome = 'Mensal',
                                ),
                                child: const Text("Mensal"),
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
                      const SizedBox(height: 4),
                      Text(
                        _gastosValores[_selectedPeriodHome] ?? "R\$ 0,00",
                        style: const TextStyle(
                          color: verdePrincipal,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Divider(height: 1, color: Color(0xFFEEEEEE)),
                      ),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.hourglass_empty,
                                color: Colors.orange[400],
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "Repasses a receber",
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "R\$ ${_totalPendente.toStringAsFixed(2).replaceAll('.', ',')}",
                            style: const TextStyle(
                              color: Colors.orange,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
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

          // PRÓXIMA CORRIDA
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Sua Próxima Viagem",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: verdePrincipal.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: verdePrincipal.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.schedule,
                                color: verdePrincipal,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hoje, 18:30",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  "Campos Novos -> Unoesc",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "3 Colegas confirmados",
                              style: TextStyle(fontWeight: FontWeight.w500),
                            ),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: verdePrincipal,
                                foregroundColor: Colors.white,
                                elevation: 0,
                              ),
                              child: const Text("Iniciar"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // VIAGENS ANTERIORES FINALIZADAS
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Viagens Anteriores",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),

                ..._historicoViagens.take(3).map((viagem) {
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.only(bottom: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: verdePrincipal.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.check_circle,
                          color: verdePrincipal,
                        ),
                      ),
                      title: Text(
                        viagem['rota'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        viagem['data'],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      trailing: Text(
                        "${viagem['passageiros'].length} passageiros",
                        style: const TextStyle(
                          color: verdePrincipal,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  // ==========================================
  // --- TELA DE REPASSES (GRÁFICO E LISTA DE PAGAMENTOS) ---
  // ==========================================
  Widget _buildTelaRepasses() {
    final dadosAtuais =
        _gastosGraficos[_selectedPeriodRepasses] ?? [0, 0, 0, 0, 0, 0];
    final labelsAtuais =
        _labelsGraficos[_selectedPeriodRepasses] ?? ['', '', '', '', '', ''];
    final int indexAtivo = _pontoTocadoIndex ?? (dadosAtuais.length - 1);

    // LÓGICA DE FILTRAGEM INTELIGENTE
    bool temPendentes = _historicoViagens.any(
      (viagem) => viagem['passageiros'].any((p) => p['pago'] == false),
    );

    List<Map<String, dynamic>> viagensParaExibir = temPendentes
        ? _historicoViagens
              .where((v) => v['passageiros'].any((p) => p['pago'] == false))
              .toList()
        : _historicoViagens.take(3).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
            decoration: const BoxDecoration(
              color: verdePrincipal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: const Text(
              "Controle de Repasses",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildPeriodButton('Dia', 'Diário')),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodButton('Semana', 'Semanal')),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodButton('Mês', 'Mensal')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                width: double.infinity,
                height: 340,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _getGraphTitle(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: verdePrincipal,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: verdePrincipal.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              "Gastos",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: verdePrincipal,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return GestureDetector(
                              onTapDown: (details) => _atualizarPontoTocado(
                                details.localPosition.dx,
                                constraints.maxWidth,
                                dadosAtuais.length,
                              ),
                              onPanUpdate: (details) => _atualizarPontoTocado(
                                details.localPosition.dx,
                                constraints.maxWidth,
                                dadosAtuais.length,
                              ),
                              child: CustomPaint(
                                size: Size(
                                  constraints.maxWidth,
                                  constraints.maxHeight,
                                ),
                                painter: PremiumChartPainter(
                                  data: dadosAtuais,
                                  lineColor: verdePrincipal,
                                  selectedIndex: indexAtivo,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: labelsAtuais.map((label) {
                            bool estaAtivo =
                                labelsAtuais.indexOf(label) == indexAtivo;
                            return Text(
                              label,
                              style: TextStyle(
                                color: estaAtivo ? verdePrincipal : Colors.grey,
                                fontSize: 12,
                                fontWeight: estaAtivo
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // --- CONTROLE DE PAGAMENTOS ---
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      temPendentes ? "Corridas em Aberto" : "Últimas Corridas",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (temPendentes)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          "Pendências",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                ...List.generate(viagensParaExibir.length, (index) {
                  return _buildViagemControleCard(viagensParaExibir[index]);
                }),

                const SizedBox(height: 12),

                // BOTÃO PARA VER HISTÓRICO COMPLETO
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TelaHistoricoRepasses(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: verdePrincipal,
                      side: const BorderSide(color: verdePrincipal),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Ver Todo o Histórico",
                      style: TextStyle(fontWeight: FontWeight.bold),
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

  // WIDGET DO CARD DE CADA VIAGEM E SEUS PASSAGEIROS
  Widget _buildViagemControleCard(Map<String, dynamic> viagemRef) {
    int indexOriginal = _historicoViagens.indexOf(viagemRef);
    List<dynamic> passageiros = _historicoViagens[indexOriginal]['passageiros'];

    double totalEsperado = passageiros.fold(0, (s, p) => s + p['valor']);
    double totalPago = passageiros
        .where((p) => p['pago'] == true)
        .fold(0, (s, p) => s + p['valor']);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: verdePrincipal.withValues(alpha: 0.05),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(15),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viagemRef['data'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      viagemRef['rota'],
                      style: TextStyle(color: Colors.grey[700], fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Arrecadado",
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                    Text(
                      "R\$ ${totalPago.toStringAsFixed(2)} / R\$ ${totalEsperado.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: totalPago == totalEsperado
                            ? Colors.green
                            : verdePrincipal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: List.generate(passageiros.length, (indexPassageiro) {
                var pass = passageiros[indexPassageiro];
                bool isPago = pass['pago'];

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.grey[200],
                            child: Icon(
                              Icons.person,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pass['nome'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                "R\$ ${pass['valor'].toStringAsFixed(2)}",
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      GestureDetector(
                        onTap: () {
                          setState(() {
                            // Atualiza na lista oficial e força rebuild geral
                            _historicoViagens[indexOriginal]['passageiros'][indexPassageiro]['pago'] =
                                !isPago;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isPago
                                ? Colors.green.withValues(alpha: 0.1)
                                : Colors.orange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isPago ? Colors.green : Colors.orange,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                isPago
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: isPago ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isPago ? "Pago" : "Pendente",
                                style: TextStyle(
                                  color: isPago ? Colors.green : Colors.orange,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- ABAS COMPARTILHADAS (GRUPOS, CHAT E PERFIL) ---
  // ==========================================
  Widget _buildTelaGrupos() {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
          decoration: const BoxDecoration(
            color: verdePrincipal,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Text(
            "Gerenciar Grupos",
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
                "Criar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildOpcaoCard(
                Icons.add_moderator,
                "Criar Grupo Privado",
                "Para colegas com link/senha",
              ),
              _buildOpcaoCard(
                Icons.public,
                "Criar Grupo Público",
                "Aberto para a faculdade",
              ),
              const SizedBox(height: 30),
              const Text(
                "Meus Grupos de Carona",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildOpcaoCard(
                Icons.settings,
                "Gerenciar: Unoesc Noturno",
                "Aprovar colegas e definir rotas",
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
            color: verdePrincipal,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: const Text(
            "Mensagens",
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
                "Colegas de Viagem",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildChatItem(
                "Ana Clara",
                "Me avisa quando estiver chegando!",
                "Agora",
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // --- TELA DE PERFIL ATUALIZADA ---
  // ==========================================
  Widget _buildTelaPerfilMotorista() {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: const BoxDecoration(
              color: verdePrincipal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Perfil do Motorista",
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
                        color: verdePrincipal,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.user?.name ?? "Motorista Solidário",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      "4.9 (120 viagens colaborativas)",
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // OPÇÕES ORIGINAIS DO PASSAGEIRO MISTURADAS COM AS DE MOTORISTA
                _buildOpcaoCard(
                  Icons.group_add_outlined,
                  "Convidar Amigos",
                  "Compartilhe seu código de referência",
                ),
                _buildOpcaoCard(
                  Icons.person_outline,
                  "Meus Dados",
                  "Informações pessoais, CNH e privacidade",
                ),

                _buildOpcaoCard(
                  Icons.directions_car,
                  "Meu Veículo",
                  "Placa, modelo e capacidade de lotação",
                ),
                _buildOpcaoCard(
                  Icons.account_balance_wallet,
                  "Dados Pix",
                  "Chave para receber os repasses",
                ),

                _buildOpcaoCard(
                  Icons.shield_outlined,
                  "Login e Segurança",
                  "Gerencie senhas e autenticação",
                ),
                _buildOpcaoCard(
                  Icons.chat_bubble_outline,
                  "Centro de Mensagens",
                  "Gerencie seus contatos",
                ),

                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(
                      context,
                    ).popUntil((route) => route.isFirst),
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
                          "Sair",
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

  // ==========================================
  // --- WIDGETS AUXILIARES GERAIS ---
  // ==========================================
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return "Bom dia";
    if (hour >= 12 && hour < 18) return "Boa tarde";
    return "Boa noite";
  }

  Widget _buildPeriodButton(String label, String period) {
    bool isSelected = _selectedPeriodRepasses == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriodRepasses = period;
          _pontoTocadoIndex = null;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected ? verdePrincipal : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? verdePrincipal : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  String _getGraphTitle() {
    switch (_selectedPeriodRepasses) {
      case 'Diário':
        return 'Gasto Diário';
      case 'Semanal':
        return 'Gasto Semanal';
      case 'Mensal':
        return 'Gasto Mensal';
      default:
        return 'Gastos';
    }
  }

  Widget _buildOpcaoCard(IconData icon, String title, String subtitle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: verdePrincipal.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: verdePrincipal),
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

  Widget _buildChatItem(String name, String lastMessage, String time) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.person, color: Colors.grey[700]),
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
}

// =========================================================================
// CUSTOM PAINTER INTERATIVO
// =========================================================================
class PremiumChartPainter extends CustomPainter {
  final List<double> data;
  final Color lineColor;
  final int selectedIndex;

  PremiumChartPainter({
    required this.data,
    required this.lineColor,
    required this.selectedIndex,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final double paddingEixoY = 40.0;
    final double paddingPontosSide = 10.0;
    final double chartHeight = size.height - paddingEixoY;
    final double chartWidth = size.width - (paddingPontosSide * 2);

    final Paint paintLinha = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    double maxData = data.reduce((a, b) => a > b ? a : b);
    if (maxData == 0) maxData = 1.0;
    maxData = maxData * 1.15;

    final List<Offset> points = [];
    final double stepX = chartWidth / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      double x = paddingPontosSide + (i * stepX);
      double y = size.height - ((data[i] / maxData) * chartHeight);
      points.add(Offset(x, y));
    }

    final Paint paintGrid = Paint()
      ..color = Colors.grey.withValues(alpha: 0.15)
      ..strokeWidth = 1;
    canvas.drawLine(
      Offset(0, paddingEixoY),
      Offset(size.width, paddingEixoY),
      paintGrid,
    );
    canvas.drawLine(
      Offset(0, paddingEixoY + (chartHeight / 2)),
      Offset(size.width, paddingEixoY + (chartHeight / 2)),
      paintGrid,
    );
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paintGrid,
    );

    final Path pathPreenchimento = Path();
    pathPreenchimento.moveTo(points.first.dx, size.height);
    pathPreenchimento.lineTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      pathPreenchimento.cubicTo(
        p1.dx + (p2.dx - p1.dx) / 2,
        p1.dy,
        p1.dx + (p2.dx - p1.dx) / 2,
        p2.dy,
        p2.dx,
        p2.dy,
      );
    }
    pathPreenchimento.lineTo(points.last.dx, size.height);
    pathPreenchimento.close();

    Paint paintFill = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          lineColor.withValues(alpha: 0.3),
          Colors.white.withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTRB(0, paddingEixoY, size.width, size.height));
    canvas.drawPath(pathPreenchimento, paintFill);

    final Path pathLinha = Path();
    pathLinha.moveTo(points.first.dx, points.first.dy);
    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      pathLinha.cubicTo(
        p1.dx + (p2.dx - p1.dx) / 2,
        p1.dy,
        p1.dx + (p2.dx - p1.dx) / 2,
        p2.dy,
        p2.dx,
        p2.dy,
      );
    }
    canvas.drawPath(pathLinha, paintLinha);

    for (int i = 0; i < points.length; i++) {
      if (i != selectedIndex) {
        canvas.drawCircle(
          points[i],
          4,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill,
        );
        canvas.drawCircle(
          points[i],
          4,
          Paint()
            ..color = lineColor
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke,
        );
      }
    }

    final Offset pontoDestaque = points[selectedIndex];
    final double valorDestaque = data[selectedIndex];

    canvas.drawLine(
      pontoDestaque,
      Offset(pontoDestaque.dx, size.height),
      Paint()
        ..color = lineColor.withValues(alpha: 0.3)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(
      pontoDestaque,
      10,
      Paint()
        ..color = Colors.black12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
    canvas.drawCircle(
      pontoDestaque,
      8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
    canvas.drawCircle(
      pontoDestaque,
      5,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );

    String valStr = valorDestaque.toStringAsFixed(2);
    List<String> partes = valStr.split('.');
    String inteiros = partes[0].replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    String textoFinal = 'R\$ $inteiros,${partes[1]}';

    final textPainter = TextPainter(
      text: TextSpan(
        text: textoFinal,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    final double rectW = textPainter.width + 16;
    final double rectH = textPainter.height + 10;
    double rectT = pontoDestaque.dy - rectH - 15;
    double rectL = pontoDestaque.dx - (rectW / 2);

    if (rectL < 0) rectL = 0;
    if (rectL + rectW > size.width) rectL = size.width - rectW;

    final RRect tooltipRect = RRect.fromLTRBR(
      rectL,
      rectT,
      rectL + rectW,
      rectT + rectH,
      const Radius.circular(8),
    );
    canvas.drawRRect(
      tooltipRect.shift(const Offset(0, 2)),
      Paint()
        ..color = Colors.black12
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawRRect(
      tooltipRect,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.fill,
    );
    textPainter.paint(canvas, Offset(rectL + 8, rectT + 5));
  }

  @override
  bool shouldRepaint(PremiumChartPainter oldDelegate) =>
      oldDelegate.data != data || oldDelegate.selectedIndex != selectedIndex;
}

// =========================================================================
// TELA PLACEHOLDER PARA O HISTÓRICO COMPLETO
// =========================================================================
class TelaHistoricoRepasses extends StatelessWidget {
  const TelaHistoricoRepasses({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Histórico Completo",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF2E7D73),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          "Aqui serão listadas todas as corridas puxadas do Banco de Dados",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ),
    );
  }
}
