import 'package:test_tcc/data/datasources/carona_remote_datasource.dart';
import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_item.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/domain/repositories/carona_repository.dart';

class CaronaRepositoryImpl implements CaronaRepository {
  final CaronaRemoteDatasource remote;

  const CaronaRepositoryImpl(this.remote);

  @override
  Future<List<CaronaItem>> listarMinhas() => remote.listarMinhas();

  @override
  Future<CaronaDetalhe> detalhe(int idCarona) => remote.detalhe(idCarona);

  @override
  Future<StatusCarona> concluir(int idCarona) => remote.concluir(idCarona);

  @override
  Future<StatusCarona> cancelar(int idCarona) => remote.cancelar(idCarona);
}
