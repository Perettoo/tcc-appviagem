import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_item.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';

abstract class CaronaRepository {
  /// Caronas em que o usuário participa (como motorista ou passageiro).
  Future<List<CaronaItem>> listarMinhas();

  /// Detalhe de uma carona (motorista + passageiros).
  Future<CaronaDetalhe> detalhe(int idCarona);

  /// Conclui a carona (só motorista). Retorna o novo status.
  Future<StatusCarona> concluir(int idCarona);

  /// Cancela a carona (solicitante ou motorista). Retorna o novo status.
  Future<StatusCarona> cancelar(int idCarona);
}
