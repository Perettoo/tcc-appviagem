import 'package:test_tcc/domain/entities/grupo.dart';
import 'package:test_tcc/domain/repositories/grupo_repository.dart';

class ListarGruposUseCase {
  final GrupoRepository repository;

  const ListarGruposUseCase(this.repository);

  Future<List<Grupo>> call() => repository.listarMeus();
}
