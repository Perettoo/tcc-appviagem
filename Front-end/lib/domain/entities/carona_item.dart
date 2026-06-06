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
  final int totalPassageiros;

  const CaronaItem({
    required this.idCarona,
    required this.idGrupo,
    required this.grupoNome,
    required this.status,
    required this.data,
    required this.papel,
    required this.motoristaNome,
    required this.totalPassageiros,
  });
}
