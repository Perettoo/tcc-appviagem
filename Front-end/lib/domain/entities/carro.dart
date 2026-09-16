/// Um carro do usuário. `ativo` indica o carro selecionado — o que é atrelado
/// à carona quando o motorista a anuncia. No máximo um ativo por usuário.
class Carro {
  final int idCarro;
  final String marca;
  final String modelo;
  final int anoFabricacao;
  final String cor;
  final String placa;
  final int capacidade;
  final double consumoMedio;
  final bool ativo;

  const Carro({
    required this.idCarro,
    required this.marca,
    required this.modelo,
    required this.anoFabricacao,
    required this.cor,
    required this.placa,
    required this.capacidade,
    required this.consumoMedio,
    required this.ativo,
  });

  /// "VW Gol" — para títulos.
  String get descricao => '$marca $modelo';

  /// "Prata • 2020 • 5 lugares" — subtítulo curto.
  String get detalhe => '$cor • $anoFabricacao • $capacidade lugares';

  Carro copyWith({bool? ativo}) {
    return Carro(
      idCarro: idCarro,
      marca: marca,
      modelo: modelo,
      anoFabricacao: anoFabricacao,
      cor: cor,
      placa: placa,
      capacidade: capacidade,
      ativo: ativo ?? this.ativo,
    );
  }
}
