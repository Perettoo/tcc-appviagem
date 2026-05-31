import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/data/datasources/grupo_remote_datasource.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/domain/entities/grupo.dart';

/// Socket de SESSÃO: vive enquanto o usuário está logado (conecta ao entrar
/// no app autenticado, desconecta no logout) — diferente do socket de chat,
/// que é por grupo.
///
/// O servidor coloca este socket na sala `user:<id>` no handshake, então
/// recebemos eventos direcionados só a este usuário (ex: foi adicionado a um
/// grupo) sem precisar estar na sala daquele grupo.
class SessionSocketService {
  final TokenStorage _tokenStorage;

  io.Socket? _socket;
  StreamController<Grupo>? _controller;

  SessionSocketService({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  /// Conecta e devolve o stream de grupos em que o usuário foi adicionado.
  Stream<Grupo> conectar() {
    desconectar();

    final controller = StreamController<Grupo>.broadcast();
    _controller = controller;

    final token = _tokenStorage.read() ?? '';
    final socket = io.io(
      ApiConfig.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .build(),
    );
    _socket = socket;

    socket.on('grupo:adicionado', (data) {
      if (data is Map && !controller.isClosed) {
        controller.add(grupoFromJson(Map<String, dynamic>.from(data)));
      }
    });

    socket.connect();
    return controller.stream;
  }

  void desconectar() {
    final socket = _socket;
    if (socket != null) {
      socket.clearListeners();
      socket.dispose();
      _socket = null;
    }
    _controller?.close();
    _controller = null;
  }
}
