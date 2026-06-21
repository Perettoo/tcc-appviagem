import 'package:test_tcc/domain/entities/carona_resumo.dart';

/// Papel do usuário numa carona da sua lista.
enum PapelCarona { motorista, passageiro }

extension PapelCaronaLabel on PapelCarona {
  String get label => switch (this) {
        PapelCarona.motorista => 'Você é o motorista',
        PapelCarona.passageiro => 'Você é passageiro',
      };
}

/// Item da lista "Minhas caronas" (resumo de uma viagem).
class CaronaItem {
  final int idCarona;
  final int idGrupo;
  final String grupoNome;
  final StatusCarona status;
  final DateTime data;
  final PapelCarona papel;
  final String? motoristaNome;
  final String? destino;

  /// Vagas de passageiro (capacidade - 1) e quantas já ocupadas (aprovados).
  final int? lugares;
  final int ocupadas;

  /// Status do meu pedido — só quando sou passageiro.
  final StatusPassageiro? meuStatus;

  const CaronaItem({
    required this.idCarona,
    required this.idGrupo,
    required this.grupoNome,
    required this.status,
    required this.data,
    required this.papel,
    required this.motoristaNome,
    required this.destino,
    required this.lugares,
    required this.ocupadas,
    required this.meuStatus,
  });
}
