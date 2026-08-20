import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_item.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';

abstract class CaronaRepository {
  /// Caronas em que o usuário participa (como motorista ou passageiro).
  Future<List<CaronaItem>> listarMinhas();

  /// Detalhe de uma carona (motorista + carro + passageiros).
  Future<CaronaDetalhe> detalhe(int idCarona);

  /// Passageiro pede para entrar. Retorna o detalhe atualizado.
  Future<CaronaDetalhe> pedir(int idCarona);

  /// Passageiro cancela o próprio pedido. Retorna o detalhe atualizado.
  Future<CaronaDetalhe> cancelarPedido(int idCarona);

  /// Motorista aprova/recusa o pedido de um passageiro. Retorna o detalhe.
  Future<CaronaDetalhe> decidir({
    required int idCarona,
    required int idPassageiro,
    required bool aprovar,
  });

  /// Motorista informa km rodados + valor do litro (base do rateio da viagem).
  /// Retorna o detalhe com os custos recalculados.
  Future<CaronaDetalhe> atualizarCustos({
    required int idCarona,
    required double kmRodados,
    required double valorLitro,
  });

  /// Conclui a carona (só motorista). Retorna o novo status.
  Future<StatusCarona> concluir(int idCarona);

  /// Cancela a carona (só motorista). Retorna o novo status.
  Future<StatusCarona> cancelar(int idCarona);
}
