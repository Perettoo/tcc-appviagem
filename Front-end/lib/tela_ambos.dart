import 'package:flutter/material.dart';
import 'package:test_tcc/user.dart';

class TelaAmbos extends StatefulWidget {
  final User? user;
  const TelaAmbos({super.key, this.user});

  @override
  State<TelaAmbos> createState() => _TelaAmbosState();
}

class _TelaAmbosState extends State<TelaAmbos> {
  static const Color verdePrincipal = Color(0xFF2E7D73);
  static const Color fundoLeve = Color(0xFFF5F7F9);

  int _selectedIndex = 0;

  // A CHAVE MESTRA DA TELA: Controla a visão atual
  bool _isMotorista = false;

  // Variáveis de período separadas para não dar conflito
  String _selectedPeriodHomeCarona = 'Mensal';
  String _selectedPeriodGraficoCarona = 'Diário';
  String _selectedPeriodHomeMoto = 'Mensal';
  String _selectedPeriodGraficoMoto = 'Diário';

  int? _pontoTocadoIndex;

  // ==========================================
  // --- MOCK DE DADOS: PASSAGEIRO ---
  // ==========================================
  final Map<String, String> _gastosValoresCarona = {
    'Diário': 'R\$ 12,50',
    'Semanal': 'R\$ 62,50',
    'Mensal': 'R\$ 250,00',
  };
  final Map<String, List<double>> _graficosCarona = {
    'Diário': [12.50, 25.00, 12.50, 37.50, 25.00, 0.0],
    'Semanal': [50.0, 75.0, 62.50, 100.0, 80.0, 0.0],
    'Mensal': [200.0, 350.0, 280.0, 410.0, 390.0, 450.0],
  };

  // ==========================================
  // --- MOCK DE DADOS: MOTORISTA ---
  // ==========================================
  final Map<String, String> _economiaValoresMoto = {
    'Diário': 'R\$ 45,00',
    'Semanal': 'R\$ 190,00',
    'Mensal': 'R\$ 680,00',
  };
  final Map<String, List<double>> _graficosMoto = {
    'Diário': [25.00, 50.00, 30.00, 65.00, 45.00, 0.0],
    'Semanal': [120.0, 180.0, 150.0, 210.0, 190.0, 0.0],
    'Mensal': [450.0, 600.0, 520.0, 700.0, 680.0, 800.0],
  };

  final Map<String, List<String>> _labelsGraficos = {
    'Diário': ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'],
    'Semanal': ['Sem 1', 'Sem 2', 'Sem 3', 'Sem 4', 'Sem 5', 'Sem 6'],
    'Mensal': ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
  };

  final List<Map<String, dynamic>> _historicoViagensMoto = [
    {
      'data': 'Hoje, 28 de Abril',
      'rota': 'Campos Novos ➔ Unoesc',
      'passageiros': [
        {'nome': 'Ana Clara', 'valor': 15.00, 'pago': false},
        {'nome': 'Lucas', 'valor': 15.00, 'pago': true},
      ],
    },
    {
      'data': 'Ontem, 27 de Abril',
      'rota': 'Unoesc ➔ Campos Novos',
      'passageiros': [
        {'nome': 'Carlos', 'valor': 12.50, 'pago': true},
      ],
    },
  ];

  double get _totalPendenteMoto {
    double total = 0.0;
    for (var viagem in _historicoViagensMoto) {
      for (var pass in viagem['passageiros']) {
        if (pass['pago'] == false) total += pass['valor'];
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
    if (_pontoTocadoIndex != index) setState(() => _pontoTocadoIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    Widget bodyContent;

    if (_selectedIndex == 0) {
      bodyContent = _buildTelaHome();
    } else if (_selectedIndex == 1) {
      bodyContent = _buildTelaDados();
    } else if (_selectedIndex == 2) {
      bodyContent = _buildTelaGrupos();
    } else if (_selectedIndex == 3) {
      bodyContent = _buildTelaChat();
    } else {
      bodyContent = _buildTelaPerfil();
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
            _pontoTocadoIndex = null; // Reseta o gráfico ao mudar de aba
          });
        },
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Início",
          ),
          // O rótulo da aba muda dinamicamente conforme a visão
          BottomNavigationBarItem(
            icon: Icon(_isMotorista ? Icons.handshake : Icons.bar_chart),
            label: _isMotorista ? "Repasses" : "Gastos",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.group_add),
            label: "Grupos",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "Mensagem",
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }

  // ==========================================
  // --- TELA HOME (MIX DINÂMICO) ---
  // ==========================================
  Widget _buildTelaHome() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // CABEÇALHO COM O TOGGLE SWITCH
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
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white24,
                          child: Icon(
                            _isMotorista ? Icons.drive_eta : Icons.person,
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
                              widget.user?.name ?? "Daniel Bezerra",
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
                const SizedBox(height: 24),

                // --- TOGGLE SWITCH (MOTORISTA <-> PASSAGEIRO) ---
                Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isMotorista = false),
                          child: Container(
                            decoration: BoxDecoration(
                              color: !_isMotorista
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Passageiro",
                              style: TextStyle(
                                color: !_isMotorista
                                    ? verdePrincipal
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _isMotorista = true),
                          child: Container(
                            decoration: BoxDecoration(
                              color: _isMotorista
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              "Motorista",
                              style: TextStyle(
                                color: _isMotorista
                                    ? verdePrincipal
                                    : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // CARD PRINCIPAL DINÂMICO
                _isMotorista
                    ? _buildCardResumoMotorista()
                    : _buildCardResumoCarona(),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // CONTEÚDO ESPECÍFICO DINÂMICO
          _isMotorista ? _buildHomeBodyMotorista() : _buildHomeBodyCarona(),
        ],
      ),
    );
  }

  // --- CARDS DA HOME ---
  Widget _buildCardResumoCarona() {
    return Container(
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
                "Gasto $_selectedPeriodHomeCarona",
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
                    onTap: () =>
                        setState(() => _selectedPeriodHomeCarona = 'Diário'),
                    child: const Text("Diário"),
                  ),
                  PopupMenuItem(
                    value: 'Semanal',
                    onTap: () =>
                        setState(() => _selectedPeriodHomeCarona = 'Semanal'),
                    child: const Text("Semanal"),
                  ),
                  PopupMenuItem(
                    value: 'Mensal',
                    onTap: () =>
                        setState(() => _selectedPeriodHomeCarona = 'Mensal'),
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
            _gastosValoresCarona[_selectedPeriodHomeCarona] ?? "R\$ 0,00",
            style: const TextStyle(
              color: verdePrincipal,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardResumoMotorista() {
    return Container(
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
                _economiaValoresMoto.keys.contains(_selectedPeriodHomeMoto)
                    ? "Economia $_selectedPeriodHomeMoto"
                    : "Economia",
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
                    onTap: () =>
                        setState(() => _selectedPeriodHomeMoto = 'Diário'),
                    child: const Text("Diário"),
                  ),
                  PopupMenuItem(
                    value: 'Semanal',
                    onTap: () =>
                        setState(() => _selectedPeriodHomeMoto = 'Semanal'),
                    child: const Text("Semanal"),
                  ),
                  PopupMenuItem(
                    value: 'Mensal',
                    onTap: () =>
                        setState(() => _selectedPeriodHomeMoto = 'Mensal'),
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
            _economiaValoresMoto[_selectedPeriodHomeMoto] ?? "R\$ 0,00",
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
                    "A receber",
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                ],
              ),
              Text(
                "R\$ ${_totalPendenteMoto.toStringAsFixed(2).replaceAll('.', ',')}",
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
    );
  }

  // --- CORPOS DA HOME ---
  Widget _buildHomeBodyCarona() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.group),
                  label: const Text("Grupo Privado"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: verdePrincipal,
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
                  onPressed: () {},
                  icon: const Icon(Icons.public),
                  label: const Text("Grupo Público"),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Histórico Recente",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildTripItemCarona(
                "Campos Novos -> Unoesc",
                "Gustavo",
                "- R\$ 6,25",
              ),
              _buildTripItemCarona(
                "Centro -> Bairro Novo",
                "Carlos",
                "- R\$ 8,50",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHomeBodyMotorista() {
    return Column(
      children: [
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
              const SizedBox(height: 30),
              const Text(
                "Viagens Anteriores",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ..._historicoViagensMoto.map((viagem) {
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
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================
  // --- TELA DADOS/REPASSES (MIX DINÂMICO) ---
  // ==========================================
  Widget _buildTelaDados() {
    String periodoAtivo = _isMotorista
        ? _selectedPeriodGraficoMoto
        : _selectedPeriodGraficoCarona;
    List<double> dadosAtuais = _isMotorista
        ? (_graficosMoto[periodoAtivo] ?? [])
        : (_graficosCarona[periodoAtivo] ?? []);
    List<String> labelsAtuais = _labelsGraficos[periodoAtivo] ?? [];

    if (dadosAtuais.isEmpty) dadosAtuais = [0, 0, 0, 0, 0, 0];
    if (labelsAtuais.isEmpty) labelsAtuais = ['', '', '', '', '', ''];

    final int indexAtivo = _pontoTocadoIndex ?? (dadosAtuais.length - 1);

    String tituloHeader = _isMotorista
        ? "Controle de Repasses"
        : "Estatísticas de Gastos";
    String tituloTag = _isMotorista ? "Valor Arrecadado" : "Valor Gasto";

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
            child: Text(
              tituloHeader,
              style: const TextStyle(
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
                Expanded(child: _buildPeriodButtonDados('Dia', 'Diário')),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodButtonDados('Semana', 'Semanal')),
                const SizedBox(width: 12),
                Expanded(child: _buildPeriodButtonDados('Mês', 'Mensal')),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // GRÁFICO (REUTILIZÁVEL)
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
                            "Visualização $periodoAtivo",
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
                            child: Text(
                              tituloTag,
                              style: const TextStyle(
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

          // LISTA INFERIOR ESPECÍFICA
          _isMotorista
              ? _buildListaPagamentosMotorista()
              : _buildSaldosPendentesCarona(),
        ],
      ),
    );
  }

  Widget _buildSaldosPendentesCarona() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Meus Débitos Pendentes",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _buildDebtCard("Gustavo (Motorista)", "R\$ 12,50"),
          _buildDebtCard("Carlos", "R\$ 8,50"),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildListaPagamentosMotorista() {
    bool temPendentes = _historicoViagensMoto.any(
      (viagem) => viagem['passageiros'].any((p) => p['pago'] == false),
    );
    List<Map<String, dynamic>> viagensParaExibir = temPendentes
        ? _historicoViagensMoto
              .where((v) => v['passageiros'].any((p) => p['pago'] == false))
              .toList()
        : _historicoViagensMoto.take(3).toList();

    return Padding(
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
          ...List.generate(
            viagensParaExibir.length,
            (index) => _buildViagemControleCardMoto(viagensParaExibir[index]),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildViagemControleCardMoto(Map<String, dynamic> viagemRef) {
    int indexOriginal = _historicoViagensMoto.indexOf(viagemRef);
    List<dynamic> passageiros =
        _historicoViagensMoto[indexOriginal]['passageiros'];
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
                        onTap: () => setState(
                          () =>
                              _historicoViagensMoto[indexOriginal]['passageiros'][indexPassageiro]['pago'] =
                                  !isPago,
                        ),
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
  // --- ABAS UNIFICADAS (GRUPOS, CHAT, PERFIL) ---
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
            "Grupos de Carona",
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
                "Ações Rápidas",
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
                Icons.search,
                "Buscar Grupo Público",
                "Encontre rotas ativas",
              ),
              const SizedBox(height: 30),
              const Text(
                "Meus Grupos",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 10),
              _buildOpcaoCard(
                Icons.directions_car,
                "Unoesc Noturno (Motorista)",
                "Gerenciar passageiros",
              ),
              _buildOpcaoCard(
                Icons.group,
                "Campos Novos -> Centro (Passageiro)",
                "Ver rota e membros",
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
                "Conversas Ativas",
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
              _buildChatItem(
                "Grupo: Unoesc Noturno",
                "Gustavo: Saindo em 10 min",
                "18:00",
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
              color: verdePrincipal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  "Meu Perfil",
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
                  widget.user?.name ?? "Daniel Bezerra",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "Perfil Misto (Passageiro & Motorista)",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // MIX DE OPÇÕES (Carona + Motorista)
                _buildOpcaoCard(
                  Icons.person_outline,
                  "Meus Dados",
                  "Informações pessoais e CNH",
                ),
                _buildOpcaoCard(
                  Icons.directions_car,
                  "Meu Veículo",
                  "Placa, modelo e capacidade (Apenas Motorista)",
                ),
                _buildOpcaoCard(
                  Icons.account_balance_wallet,
                  "Dados Financeiros",
                  "Chave Pix e Formas de Pagamento",
                ),
                _buildOpcaoCard(
                  Icons.group_add_outlined,
                  "Convidar Amigos",
                  "Compartilhe seu código de referência",
                ),
                _buildOpcaoCard(
                  Icons.shield_outlined,
                  "Segurança",
                  "Gerencie senhas e privacidade",
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

  Widget _buildPeriodButtonDados(String label, String period) {
    bool isSelected = _isMotorista
        ? (_selectedPeriodGraficoMoto == period)
        : (_selectedPeriodGraficoCarona == period);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (_isMotorista) {
            _selectedPeriodGraficoMoto = period;
          } else {
            _selectedPeriodGraficoCarona = period;
          }
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

  Widget _buildTripItemCarona(String titulo, String motorista, String valor) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: verdePrincipal.withValues(alpha: 0.1),
          child: const Icon(Icons.directions_car, color: verdePrincipal),
        ),
        title: Text(
          titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text("Motorista: $motorista"),
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

  Widget _buildDebtCard(String person, String amount) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: verdePrincipal.withValues(alpha: 0.1),
                  child: const Icon(Icons.person, color: verdePrincipal),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      person,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "Você deve pagar este valor para o motorista",
                      style: TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
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
