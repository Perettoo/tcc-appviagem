import 'package:flutter/foundation.dart';
import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';
import 'package:test_tcc/domain/repositories/carona_repository.dart';

/// Estado da tela de detalhe de uma carona: carrega o detalhe e expõe as ações
/// de concluir/cancelar conforme o papel do usuário. Criado por navegação.
class CaronaDetalheController extends ChangeNotifier {
  final CaronaRepository _repo;
  final int idCarona;
  final int currentUserId;

  CaronaDetalheController({
    required CaronaRepository repo,
    required this.idCarona,
    required this.currentUserId,
  }) : _repo = repo;

  CaronaDetalhe? _detalhe;
  bool _loading = false;
  bool _agindo = false;
  String? _error;

  CaronaDetalhe? get detalhe => _detalhe;
  bool get loading => _loading;
  bool get agindo => _agindo;
  String? get error => _error;

  bool get _souMotorista => _detalhe?.idMotorista == currentUserId;
  bool get _souSolicitante =>
      _detalhe?.passageiros.any((p) => p.idUsuario == currentUserId) ?? false;

  /// Só o motorista conclui, e só quando está aceita.
  bool get podeConcluir =>
      _detalhe?.status == StatusCarona.aceita && _souMotorista;

  /// Solicitante ou motorista cancelam, enquanto pendente ou aceita.
  bool get podeCancelar {
    final s = _detalhe?.status;
    final cancelavel = s == StatusCarona.pendente || s == StatusCarona.aceita;
    return cancelavel && (_souSolicitante || _souMotorista);
  }

  Future<void> iniciar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _detalhe = await _repo.detalhe(idCarona);
    } on GrupoFailure catch (f) {
      _error = f.message;
    } catch (_) {
      _error = 'Não foi possível carregar a carona.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> concluir() => _agir(() => _repo.concluir(idCarona));
  Future<bool> cancelar() => _agir(() => _repo.cancelar(idCarona));

  Future<bool> _agir(Future<StatusCarona> Function() acao) async {
    if (_agindo || _detalhe == null) return false;
    _agindo = true;
    notifyListeners();
    try {
      final novoStatus = await acao();
      _detalhe = _detalhe!.copyWith(status: novoStatus);
      _error = null;
      return true;
    } on GrupoFailure catch (f) {
      _error = f.message;
      return false;
    } finally {
      _agindo = false;
      notifyListeners();
    }
  }
}
