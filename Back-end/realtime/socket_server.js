'use strict';

const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');
const jwtConfig = require('../config/jwt');
const db = require('../models');

function salaDoGrupo(idGrupo) {
  return `grupo:${idGrupo}`;
}

function salaDoUsuario(idUsuario) {
  return `user:${idUsuario}`;
}

/**
 * Inicializa o Socket.IO sobre o servidor HTTP.
 *
 * - Autentica no handshake com o MESMO JWT da API (socket.handshake.auth.token).
 * - Eventos:
 *     grupo:entrar (idGrupo, ack)  -> valida membro e entra na sala
 *     grupo:sair   (idGrupo)       -> sai da sala
 * - O envio de mensagem NAO passa por aqui: o POST /mensagens persiste e faz
 *   io.to(sala).emit('mensagem:nova', payload). Aqui so cuidamos das salas.
 */
function initSocket(httpServer) {
  const io = new Server(httpServer, {
    cors: { origin: '*' },
  });

  // Middleware de autenticacao do handshake.
  io.use((socket, next) => {
    const token = socket.handshake.auth && socket.handshake.auth.token;
    if (!token) {
      return next(new Error('UNAUTHENTICATED'));
    }
    try {
      const payload = jwt.verify(token, jwtConfig.secret);
      socket.user = {
        idUsuario: payload.sub,
        tipo: payload.tipo,
        email: payload.email,
      };
      return next();
    } catch (err) {
      return next(new Error('UNAUTHENTICATED'));
    }
  });

  io.on('connection', (socket) => {
    // Sala pessoal do usuario: permite notificar so ele (ex: foi adicionado
    // a um grupo) sem ele precisar estar na sala daquele grupo.
    socket.join(salaDoUsuario(socket.user.idUsuario));

    socket.on('grupo:entrar', async (idGrupoRaw, ack) => {
      const idGrupo = Number(idGrupoRaw);
      if (!Number.isInteger(idGrupo) || idGrupo <= 0) {
        if (typeof ack === 'function') ack({ ok: false, error: 'GRUPO_INVALIDO' });
        return;
      }
      try {
        // Mesma regra do REST: so membro entra na sala.
        const vinculo = await db.GrupoUsuario.findOne({
          where: { idUsuario: socket.user.idUsuario, idGrupo },
        });
        if (!vinculo) {
          if (typeof ack === 'function') ack({ ok: false, error: 'FORBIDDEN' });
          return;
        }
        socket.join(salaDoGrupo(idGrupo));
        if (typeof ack === 'function') ack({ ok: true });
      } catch (err) {
        console.error('[socket.grupo:entrar]', err);
        if (typeof ack === 'function') ack({ ok: false, error: 'INTERNAL' });
      }
    });

    socket.on('grupo:sair', (idGrupoRaw) => {
      const idGrupo = Number(idGrupoRaw);
      if (Number.isInteger(idGrupo) && idGrupo > 0) {
        socket.leave(salaDoGrupo(idGrupo));
      }
    });
  });

  return io;
}

module.exports = { initSocket, salaDoGrupo };
