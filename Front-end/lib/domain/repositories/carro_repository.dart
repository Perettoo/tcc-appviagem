import 'package:test_tcc/domain/entities/carro.dart';

abstract class CarroRepository {
  Future<List<Carro>> listar();

  Future<Carro> criar({
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
    required int capacidade,
    required double consumoMedio,
  });

  Future<Carro> atualizar({
    required int idCarro,
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
    required int capacidade,
    required double consumoMedio,
  });

  Future<void> excluir(int idCarro);

  Future<Carro> ativar(int idCarro);
}
