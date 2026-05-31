import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:test_tcc/core/config/api_config.dart';
import 'package:test_tcc/data/datasources/chat_remote_datasource.dart';
import 'package:test_tcc/data/datasources/token_storage.dart';
import 'package:test_tcc/domain/entities/mensagem.dart';

/// Conexão Socket.IO para o tempo-real do chat. Uma conexão por vez (entra
/// na sala de um grupo e emite as mensagens novas que chegam pelo socket).
///
/// Os pacotes são Dart puro (sem plugin nativo), então funcionam mesmo sem o
/// Dev Mode do Windows habilitado.
class ChatSocketService {
  final TokenStorage _tokenStorage;

  io.Socket? _socket;
  StreamController<Mensagem>? _controller;

  ChatSocketService({required TokenStorage tokenStorage})
      : _tokenStorage = tokenStorage;

  /// Conecta, entra na sala `grupo:<idGrupo>` e devolve o stream de mensagens
  /// novas. Erros de conexão não derrubam o app — o chat continua via REST.
  Stream<Mensagem> conectar(int idGrupo) {
    desconectar();

    final controller = StreamController<Mensagem>.broadcast();
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

    socket.onConnect((_) {
      socket.emit('grupo:entrar', idGrupo);
    });

    socket.on('mensagem:nova', (data) {
      if (data is Map && !controller.isClosed) {
        controller.add(mensagemFromJson(Map<String, dynamic>.from(data)));
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
