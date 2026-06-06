import 'package:test_tcc/domain/entities/carona_resumo.dart';

/// Um passageiro de uma carona.
class PassageiroCarona {
  final int idUsuario;
  final String nome;

  const PassageiroCarona({required this.idUsuario, required this.nome});
}

/// O carro atrelado a uma carona (o carro ativo do motorista no aceite).
class CarroCarona {
  final int idCarro;
  final String marca;
  final String modelo;
  final int anoFabricacao;
  final String cor;
  final String placa;

  const CarroCarona({
    required this.idCarro,
    required this.marca,
    required this.modelo,
    required this.anoFabricacao,
    required this.cor,
    required this.placa,
  });

  String get descricao => '$marca $modelo';
  String get detalhe => '$cor • $anoFabricacao';
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
  final CarroCarona? carro;
  final List<PassageiroCarona> passageiros;

  const CaronaDetalhe({
    required this.idCarona,
    required this.idGrupo,
    required this.grupoNome,
    required this.status,
    required this.data,
    required this.idMotorista,
    required this.motoristaNome,
    required this.carro,
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
      carro: carro,
      passageiros: passageiros,
    );
  }
}
