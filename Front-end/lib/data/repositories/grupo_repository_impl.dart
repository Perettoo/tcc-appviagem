import 'package:test_tcc/data/datasources/grupo_remote_datasource.dart';
import 'package:test_tcc/domain/entities/grupo.dart';
import 'package:test_tcc/domain/repositories/grupo_repository.dart';

class GrupoRepositoryImpl implements GrupoRepository {
  final GrupoRemoteDatasource remote;

  const GrupoRepositoryImpl(this.remote);

  @override
  Future<Grupo> criar({required String nome, required bool isPrivado}) {
    return remote.criar(nome: nome, isPrivado: isPrivado);
  }

  @override
  Future<List<Grupo>> listarMeus() => remote.listarMeus();
}
