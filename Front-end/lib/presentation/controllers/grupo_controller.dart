import 'package:flutter/foundation.dart';
import 'package:test_tcc/domain/entities/grupo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';
import 'package:test_tcc/domain/usecases/criar_grupo_usecase.dart';
import 'package:test_tcc/domain/usecases/listar_grupos_usecase.dart';

/// Dono da lista de grupos do usuário. As telas observam este controller
/// em vez de fazer setState + chamada de usecase espalhados.
class GrupoController extends ChangeNotifier {
  final ListarGruposUseCase _listar;
  final CriarGrupoUseCase _criar;

  GrupoController({
    required ListarGruposUseCase listar,
    required CriarGrupoUseCase criar,
  })  : _listar = listar,
        _criar = criar;

  List<Grupo> _grupos = const [];
  bool _loading = false;
  String? _error;
  bool _carregouUmaVez = false;

  List<Grupo> get grupos => _grupos;
  bool get loading => _loading;
  String? get error => _error;
  bool get carregouUmaVez => _carregouUmaVez;

  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _grupos = await _listar();
    } on GrupoFailure catch (f) {
      _error = f.message;
    } finally {
      _loading = false;
      _carregouUmaVez = true;
      notifyListeners();
    }
  }

  /// Cria o grupo e o coloca no topo da lista.
  /// Repassa [GrupoFailure] para a tela exibir o erro no formulário.
  Future<Grupo> criar({required String nome, required bool isPrivado}) async {
    final grupo = await _criar(nome: nome, isPrivado: isPrivado);
    _grupos = [grupo, ..._grupos];
    notifyListeners();
    return grupo;
  }
}
