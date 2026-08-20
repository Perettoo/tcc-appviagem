import 'package:test_tcc/domain/entities/carona_resumo.dart';

/// Um passageiro de uma carona, com o status do seu pedido.
class PassageiroCarona {
  final int idUsuario;
  final String nome;
  final StatusPassageiro status;

  const PassageiroCarona({
    required this.idUsuario,
    required this.nome,
    required this.status,
  });
}

/// O carro atrelado a uma carona (o carro ativo do motorista no anúncio).
class CarroCarona {
  final int idCarro;
  final String marca;
  final String modelo;
  final int anoFabricacao;
  final String cor;
  final String placa;
  final int capacidade;

  const CarroCarona({
    required this.idCarro,
    required this.marca,
    required this.modelo,
    required this.anoFabricacao,
    required this.cor,
    required this.placa,
    required this.capacidade,
  });

  String get descricao => '$marca $modelo';
  String get detalhe => '$cor • $anoFabricacao';
}

/// Custos da viagem e o rateio, calculados pelo backend a partir dos km
/// rodados e do valor do litro informados pelo motorista.
///
/// combustível = (km ÷ consumo médio) × valor do litro
/// taxa        = km × taxa por km
/// total       = combustível + taxa, dividido pelos passageiros aprovados.
class CustosCarona {
  final double kmRodados;
  final double valorLitro;

  /// Consumo médio (km/L) usado para converter km em litros.
  final double consumoMedio;
  final double litros;
  final double combustivel;

  /// Taxa cobrada por km rodado e o total dela na viagem.
  final double taxaPorKm;
  final double taxa;

  /// Combustível + taxa.
  final double total;

  /// Passageiros aprovados que dividem o total.
  final int passageiros;

  /// Total ÷ passageiros. Null enquanto não há passageiro aprovado.
  final double? valorPorPassageiro;

  const CustosCarona({
    required this.kmRodados,
    required this.valorLitro,
    required this.consumoMedio,
    required this.litros,
    required this.combustivel,
    required this.taxaPorKm,
    required this.taxa,
    required this.total,
    required this.passageiros,
    required this.valorPorPassageiro,
  });
}

/// Detalhe de uma carona: motorista + carro + passageiros (com status).
class CaronaDetalhe {
  final int idCarona;
  final int idGrupo;
  final String grupoNome;
  final StatusCarona status;
  final DateTime data;
  final String? destino;
  final int? idMotorista;
  final String? motoristaNome;
  final CarroCarona? carro;

  /// Vagas de passageiro (capacidade - 1) e quantas já ocupadas (aprovados).
  final int? lugares;
  final int ocupadas;

  final List<PassageiroCarona> passageiros;

  /// Custos da viagem. Null enquanto o motorista não informar km + R$/litro.
  final CustosCarona? custos;

  const CaronaDetalhe({
    required this.idCarona,
    required this.idGrupo,
    required this.grupoNome,
    required this.status,
    required this.data,
    required this.destino,
    required this.idMotorista,
    required this.motoristaNome,
    required this.carro,
    required this.lugares,
    required this.ocupadas,
    required this.passageiros,
    required this.custos,
  });

  /// Vagas restantes (nunca negativo), quando há informação de lugares.
  int? get vagasRestantes =>
      lugares == null ? null : (lugares! - ocupadas).clamp(0, lugares!);

  /// Cópia com novo status (após concluir/cancelar).
  CaronaDetalhe copyWith({StatusCarona? status}) {
    return CaronaDetalhe(
      idCarona: idCarona,
      idGrupo: idGrupo,
      grupoNome: grupoNome,
      status: status ?? this.status,
      data: data,
      destino: destino,
      idMotorista: idMotorista,
      motoristaNome: motoristaNome,
      carro: carro,
      lugares: lugares,
      ocupadas: ocupadas,
      passageiros: passageiros,
      custos: custos,
    );
  }
}
