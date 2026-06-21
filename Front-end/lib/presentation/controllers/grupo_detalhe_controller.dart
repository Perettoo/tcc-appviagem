import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:test_tcc/domain/entities/carona_resumo.dart';
import 'package:test_tcc/domain/entities/membro_grupo.dart';
import 'package:test_tcc/domain/entities/mensagem.dart';
import 'package:test_tcc/domain/entities/usuario_resumo.dart';
import 'package:test_tcc/domain/failures/grupo_failure.dart';
import 'package:test_tcc/domain/repositories/chat_repository.dart';

/// Dono do estado da tela de um grupo: histórico do chat, membros e o
/// tempo-real. Criado por grupo (escopo de navegação) e descartado ao sair.
class GrupoDetalheController extends ChangeNotifier {
  final ChatRepository _repo;
  final int idGrupo;
  final int currentUserId;

  GrupoDetalheController({
    required ChatRepository repo,
    required this.idGrupo,
    required this.currentUserId,
  }) : _repo = repo;

  List<Mensagem> _mensagens = const [];
  List<MembroGrupo> _membros = const [];
  bool _loading = false;
  bool _enviando = false;
  String? _error;

  // Evita duplicar a mensagem que chega tanto pela resposta do POST quanto
  // pelo eco do broadcast no socket.
  final Set<int> _idsVistos = {};
  StreamSubscription<Mensagem>? _sub;
  StreamSubscription<CaronaResumo>? _caronaSub;

  List<Mensagem> get mensagens => _mensagens;
  List<MembroGrupo> get membros => _membros;
  bool get loading => _loading;
  bool get enviando => _enviando;
  String? get error => _error;

  bool ehMinha(Mensagem m) => m.idAutor == currentUserId;

  Future<void> iniciar() async {
    // Seguro pra ser chamado de novo (retry após erro).
    await _sub?.cancel();
    _sub = null;
    await _caronaSub?.cancel();
    _caronaSub = null;
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Dispara as duas chamadas em paralelo.
      final histFuture = _repo.historico(idGrupo);
      final membrosFuture = _repo.membros(idGrupo);

      final hist = await histFuture;
      _mensagens = List.of(hist);
      for (final m in _mensagens) {
        _idsVistos.add(m.idMensagem);
      }
      _membros = await membrosFuture;

      // Liga o tempo-real. Falha no socket não derruba o chat (REST segue ok).
      _sub = _repo.conectar(idGrupo).listen(_aoReceber, onError: (_) {});
      _caronaSub =
          _repo.caronaUpdates.listen(_aoAtualizarCarona, onError: (_) {});
    } on GrupoFailure catch (f) {
      _error = f.message;
    } catch (_) {
      _error = 'Não foi possível carregar o grupo.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _aoReceber(Mensagem m) {
    if (_idsVistos.contains(m.idMensagem)) return;
    _idsVistos.add(m.idMensagem);
    _mensagens = [..._mensagens, m];
    notifyListeners();
  }

  // Atualiza o card da carona (vagas/pedidos/status). Chega pelo socket; aplicar
  // duas vezes é idempotente (mesma carona).
  void _aoAtualizarCarona(CaronaResumo c) {
    var mudou = false;
    _mensagens = _mensagens.map((m) {
      if (m.carona?.idCarona == c.idCarona) {
        mudou = true;
        return m.copyWith(carona: c);
      }
      return m;
    }).toList();
    if (mudou) notifyListeners();
  }

  Future<bool> enviar(String texto) async {
    final conteudo = texto.trim();
    if (conteudo.isEmpty) return false;
    _enviando = true;
    notifyListeners();
    try {
      final msg = await _repo.enviar(idGrupo, conteudo);
      _aoReceber(msg); // dedupe cuida do eco do socket
      _error = null;
      return true;
    } on GrupoFailure catch (f) {
      _error = f.message;
      return false;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  /// Motorista anuncia uma carona no grupo (destino opcional). O card chega pela
  /// resposta do POST (e também pelo socket; o dedupe evita duplicar). Reusa o
  /// flag [enviando].
  Future<bool> anunciarCarona({String? destino}) async {
    if (_enviando) return false;
    _enviando = true;
    notifyListeners();
    try {
      final msg = await _repo.anunciarCarona(idGrupo, destino: destino);
      _aoReceber(msg); // dedupe cuida do eco do socket
      _error = null;
      return true;
    } on GrupoFailure catch (f) {
      _error = f.message;
      return false;
    } finally {
      _enviando = false;
      notifyListeners();
    }
  }

  /// Busca usuários para adicionar, já removendo quem é membro do grupo.
  /// Propaga [GrupoFailure] para a tela de busca tratar.
  Future<List<UsuarioResumo>> buscarUsuarios(String termo) async {
    final resultados = await _repo.buscarUsuarios(termo);
    final idsMembros = _membros.map((m) => m.idUsuario).toSet();
    return resultados
        .where((u) => !idsMembros.contains(u.idUsuario))
        .toList(growable: false);
  }

  Future<bool> adicionarMembro(UsuarioResumo u) async {
    try {
      final novo = await _repo.adicionarMembro(idGrupo, u.idUsuario);
      _membros = [..._membros, novo];
      _error = null;
      notifyListeners();
      return true;
    } on GrupoFailure catch (f) {
      _error = f.message;
      return false;
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    _caronaSub?.cancel();
    _repo.desconectar();
    super.dispose();
  }
}
