import 'package:flutter/foundation.dart';
import 'package:test_tcc/domain/entities/carro.dart';
import 'package:test_tcc/domain/failures/carro_failure.dart';
import 'package:test_tcc/domain/repositories/carro_repository.dart';

/// Estado dos carros do usuário. Global (escopo da sessão) para que a tela de
/// perfil e a tela de carros compartilhem a mesma fonte de verdade — assim o
/// carro ativo exibido no perfil reflete na hora as mudanças.
class CarroController extends ChangeNotifier {
  final CarroRepository _repo;

  CarroController(this._repo);

  List<Carro> _carros = const [];
  bool _loading = false;
  bool _carregouUmaVez = false;
  bool _salvando = false;
  String? _error;

  List<Carro> get carros => _carros;
  bool get loading => _loading;
  bool get carregouUmaVez => _carregouUmaVez;
  bool get salvando => _salvando;
  String? get error => _error;

  /// O carro selecionado (atrelado às caronas), ou null se não houver nenhum.
  Carro? get carroAtivo {
    for (final c in _carros) {
      if (c.ativo) return c;
    }
    return null;
  }

  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _carros = await _repo.listar();
    } on CarroFailure catch (f) {
      _error = f.message;
    } catch (_) {
      _error = 'Não foi possível carregar os carros.';
    } finally {
      _loading = false;
      _carregouUmaVez = true;
      notifyListeners();
    }
  }

  Future<bool> criar({
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
    required int capacidade,
  }) {
    return _mutar(() => _repo.criar(
          marca: marca,
          modelo: modelo,
          anoFabricacao: anoFabricacao,
          cor: cor,
          placa: placa,
          capacidade: capacidade,
        ));
  }

  Future<bool> atualizar({
    required int idCarro,
    required String marca,
    required String modelo,
    required int anoFabricacao,
    required String cor,
    required String placa,
    required int capacidade,
  }) {
    return _mutar(() => _repo.atualizar(
          idCarro: idCarro,
          marca: marca,
          modelo: modelo,
          anoFabricacao: anoFabricacao,
          cor: cor,
          placa: placa,
          capacidade: capacidade,
        ));
  }

  Future<bool> excluir(int idCarro) {
    return _mutar(() async {
      await _repo.excluir(idCarro);
      return null;
    });
  }

  Future<bool> ativar(int idCarro) {
    return _mutar(() => _repo.ativar(idCarro));
  }

  // Executa uma ação que muda os carros e recarrega a lista do servidor (fonte
  // única de verdade — evita reconstruir o invariante "um ativo" no cliente).
  Future<bool> _mutar(Future<Object?> Function() acao) async {
    if (_salvando) return false;
    _salvando = true;
    _error = null;
    notifyListeners();
    try {
      await acao();
      _carros = await _repo.listar();
      return true;
    } on CarroFailure catch (f) {
      _error = f.message;
      return false;
    } catch (_) {
      _error = 'Não foi possível concluir a operação.';
      return false;
    } finally {
      _salvando = false;
      notifyListeners();
    }
  }
}
