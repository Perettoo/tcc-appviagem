import 'package:flutter/foundation.dart';
import 'package:test_tcc/domain/entities/carona_item.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';
import 'package:test_tcc/domain/repositories/carona_repository.dart';

/// Dono da lista "Minhas caronas". As telas observam este controller.
class CaronaController extends ChangeNotifier {
  final CaronaRepository _repo;

  CaronaController(this._repo);

  List<CaronaItem> _caronas = const [];
  bool _loading = false;
  String? _error;
  bool _carregouUmaVez = false;

  List<CaronaItem> get caronas => _caronas;
  bool get loading => _loading;
  String? get error => _error;
  bool get carregouUmaVez => _carregouUmaVez;

  Future<void> carregar() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _caronas = await _repo.listarMinhas();
    } on GrupoFailure catch (f) {
      _error = f.message;
    } finally {
      _loading = false;
      _carregouUmaVez = true;
      notifyListeners();
    }
  }
}
