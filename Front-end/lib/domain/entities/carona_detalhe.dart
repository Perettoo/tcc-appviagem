import 'package:test_tcc/domain/entities/carona_resumo.dart';

/// Um passageiro de uma carona.
class PassageiroCarona {
  final int idUsuario;
  final String nome;

  const PassageiroCarona({required this.idUsuario, required this.nome});
}

/// Detalhe de uma carona: motorista + passageiros.
class CaronaDetalhe {
  final int idCarona;
  final int idGrupo;
  final String grupoNome;
  final StatusCarona status;
  final DateTime data;
  final int? idMotorista;
  final String? motoristaNome;
  final List<PassageiroCarona> passageiros;

  const CaronaDetalhe({
    required this.idCarona,
    required this.idGrupo,
    required this.grupoNome,
    required this.status,
    required this.data,
    required this.idMotorista,
    required this.motoristaNome,
    required this.passageiros,
  });

  /// Cópia com novo status (após concluir/cancelar).
  CaronaDetalhe copyWith({StatusCarona? status}) {
    return CaronaDetalhe(
      idCarona: idCarona,
      idGrupo: idGrupo,
      grupoNome: grupoNome,
      status: status ?? this.status,
      data: data,
      idMotorista: idMotorista,
      motoristaNome: motoristaNome,
      passageiros: passageiros,
    );
  }
}
