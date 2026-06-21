/// Ciclo de vida de uma carona: o motorista anuncia (aberta) e conclui/cancela.
enum StatusCarona { aberta, concluida, cancelada }

extension StatusCaronaLabel on StatusCarona {
  String get label => switch (this) {
        StatusCarona.aberta => 'Aberta',
        StatusCarona.concluida => 'Concluída',
        StatusCarona.cancelada => 'Cancelada',
      };
}

/// Status do pedido de um passageiro: pediu (pendente) e o motorista
/// aprova/recusa.
enum StatusPassageiro { pendente, aprovado, recusado }

extension StatusPassageiroLabel on StatusPassageiro {
  String get label => switch (this) {
        StatusPassageiro.pendente => 'Pendente',
        StatusPassageiro.aprovado => 'Aprovado',
        StatusPassageiro.recusado => 'Recusado',
      };
}

/// Converte a string do backend em [StatusCarona] (default: aberta).
StatusCarona statusCaronaFromString(Object? raw) =>
    StatusCarona.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => StatusCarona.aberta,
    );

/// Converte a string do backend em [StatusPassageiro] (default: pendente).
StatusPassageiro statusPassageiroFromString(Object? raw) =>
    StatusPassageiro.values.firstWhere(
      (s) => s.name == raw,
      orElse: () => StatusPassageiro.pendente,
    );

/// Resumo de uma carona embutido numa mensagem-card do tipo CARONA.
class CaronaResumo {
  final int idCarona;
  final StatusCarona status;
  final int? idMotorista;
  final String? motoristaNome;
  final String? destino;

  /// Total de vagas de passageiro (capacidade do carro - 1).
  final int? lugares;

  /// Passageiros já aprovados (ocupam vaga).
  final int ocupadas;

  /// Pedidos aguardando decisão do motorista.
  final int pendentes;

  final DateTime data;

  const CaronaResumo({
    required this.idCarona,
    required this.status,
    required this.idMotorista,
    required this.motoristaNome,
    required this.destino,
    required this.lugares,
    required this.ocupadas,
    required this.pendentes,
    required this.data,
  });

  /// "1 de 3 vagas" — quando há informação de lugares.
  String? get vagasLabel =>
      lugares == null ? null : '$ocupadas de $lugares vagas';
}
