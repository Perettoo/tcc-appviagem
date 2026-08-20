import 'package:flutter/foundation.dart';
import 'package:test_tcc/domain/entities/carona_detalhe.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';
import 'package:test_tcc/domain/repositories/carona_repository.dart';

/// Estado da tela de detalhe de uma carona. No novo fluxo o motorista anuncia
/// e os passageiros pedem para entrar; o motorista aprova/recusa cada pedido
/// (respeitando capacidade-1) e conclui/cancela a viagem. Criado por navegação.
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
  // Passageiros com decisão em andamento (spinner por linha).
  final Set<int> _decidindo = {};
  String? _error;

  CaronaDetalhe? get detalhe => _detalhe;
  bool get loading => _loading;
  bool get agindo => _agindo;
  String? get error => _error;

  bool estaDecidindo(int idPassageiro) => _decidindo.contains(idPassageiro);

  bool get souMotorista => _detalhe?.idMotorista == currentUserId;

  /// Status do meu pedido como passageiro (null se não pedi / sou o motorista).
  StatusPassageiro? get meuStatus {
    final d = _detalhe;
    if (d == null) return null;
    for (final p in d.passageiros) {
      if (p.idUsuario == currentUserId) return p.status;
    }
    return null;
  }

  /// Posso pedir: carona aberta, não sou o motorista e ainda não tenho pedido
  /// ativo (sem pedido, ou um anterior recusado que posso reenviar).
  bool get podePedir {
    final d = _detalhe;
    if (d == null || souMotorista) return false;
    if (d.status != StatusCarona.aberta) return false;
    final s = meuStatus;
    return s == null || s == StatusPassageiro.recusado;
  }

  /// Posso cancelar meu pedido: tenho pedido pendente ou aprovado, carona aberta.
  bool get podeCancelarPedido {
    final d = _detalhe;
    if (d == null || souMotorista) return false;
    if (d.status != StatusCarona.aberta) return false;
    final s = meuStatus;
    return s == StatusPassageiro.pendente || s == StatusPassageiro.aprovado;
  }

  bool get _aberta => _detalhe?.status == StatusCarona.aberta;

  /// Só o motorista informa os custos, e só enquanto a carona está aberta.
  bool get podeEditarCustos => _aberta && souMotorista;

  /// Só o motorista conclui, e só enquanto a carona está aberta.
  bool get podeConcluir => _aberta && souMotorista;

  /// Só o motorista cancela a carona, enquanto aberta.
  bool get podeCancelar => _aberta && souMotorista;

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

  /// Passageiro pede para entrar.
  Future<bool> pedir() => _mutarDetalhe(() => _repo.pedir(idCarona));

  /// Passageiro cancela o próprio pedido.
  Future<bool> cancelarPedido() =>
      _mutarDetalhe(() => _repo.cancelarPedido(idCarona));

  /// Motorista aprova/recusa um passageiro. Mantém um spinner por linha.
  Future<bool> decidir({required int idPassageiro, required bool aprovar}) async {
    if (_decidindo.contains(idPassageiro)) return false;
    _decidindo.add(idPassageiro);
    notifyListeners();
    try {
      _detalhe = await _repo.decidir(
        idCarona: idCarona,
        idPassageiro: idPassageiro,
        aprovar: aprovar,
      );
      _error = null;
      return true;
    } on GrupoFailure catch (f) {
      _error = f.message;
      return false;
    } finally {
      _decidindo.remove(idPassageiro);
      notifyListeners();
    }
  }

  /// Motorista informa km rodados e valor do litro; o backend devolve o
  /// detalhe já com o total da viagem e o rateio por passageiro.
  Future<bool> atualizarCustos({
    required double kmRodados,
    required double valorLitro,
  }) =>
      _mutarDetalhe(() => _repo.atualizarCustos(
            idCarona: idCarona,
            kmRodados: kmRodados,
            valorLitro: valorLitro,
          ));

  Future<bool> concluir() => _agirStatus(() => _repo.concluir(idCarona));
  Future<bool> cancelar() => _agirStatus(() => _repo.cancelar(idCarona));

  // Ação que devolve o detalhe atualizado (pedir/cancelarPedido). Usa o flag
  // global [agindo] para desabilitar a barra de ações enquanto roda.
  Future<bool> _mutarDetalhe(Future<CaronaDetalhe> Function() acao) async {
    if (_agindo) return false;
    _agindo = true;
    notifyListeners();
    try {
      _detalhe = await acao();
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

  // Ação que devolve só o novo status (concluir/cancelar).
  Future<bool> _agirStatus(Future<StatusCarona> Function() acao) async {
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
