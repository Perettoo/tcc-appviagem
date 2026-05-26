import 'package:test_tcc/domain/entities/grupo.dart';

abstract class GrupoRepository {
  Future<Grupo> criar({required String nome, required bool isPrivado});

  Future<List<Grupo>> listarMeus();
}
