import 'package:test_tcc/data/datasources/carro_remote_datasource.dart';
import 'package:test_tcc/domain/entities/carro.dart';
import 'package:test_tcc/domain/repositories/carro_repository.dart';

class CarroRepositoryImpl implements CarroRepository {
  final CarroRemoteDatasource remote;

  const CarroRepositoryImpl(this.remote);

  @override
  Future<List<Carro>> listar() => remote.listar();

  @override
  Future<Carro> criar({
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
    required int capacidade,
    required double consumoMedio,
  }) {
    return remote.criar(
      marca: marca,
      modelo: modelo,
      anoFabricacao: anoFabricacao,
      cor: cor,
      placa: placa,
      capacidade: capacidade,
      consumoMedio: consumoMedio,
    );
  }

  @override
  Future<Carro> atualizar({
    required int idCarro,
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
    required int capacidade,
    required double consumoMedio,
  }) {
    return remote.atualizar(
      idCarro: idCarro,
      marca: marca,
      modelo: modelo,
      anoFabricacao: anoFabricacao,
      cor: cor,
      placa: placa,
      capacidade: capacidade,
      consumoMedio: consumoMedio,
    );
  }

  @override
  Future<void> excluir(int idCarro) => remote.excluir(idCarro);

  @override
  Future<Carro> ativar(int idCarro) => remote.ativar(idCarro);
}
