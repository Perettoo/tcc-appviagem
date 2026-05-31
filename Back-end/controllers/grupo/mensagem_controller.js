'use strict';

const db = require('../../models');
const AppError = require('../../utils/app_error');
const security = require('../../config/security');
const { ensureMembro } = require('../../utils/membership');

const HISTORICO_LIMITE = 200;

// Formato unico de mensagem usado pelo REST e pelo broadcast do socket,
// pra que o cliente Flutter tenha um parser so.
function toPayload(msg) {
  return {
    idMensagem: msg.idMensagem,
    idGrupo: msg.idGrupo,
    idAutor: msg.idUsuario,
    autorNome: msg.autor ? msg.autor.nome : null,
    conteudo: msg.conteudo,
    dataEnvio: msg.dataEnvio,
  };
}

function parseIdGrupo(req) {
  const idGrupo = Number(req.params.idGrupo);
  if (!Number.isInteger(idGrupo) || idGrupo <= 0) {
    throw AppError.validation('Grupo invalido.');
  }
  return idGrupo;
}

function tratarErro(res, err, tag) {
  if (err instanceof AppError) {
    return res.status(err.httpStatus).json({
      error: err.type,
      message: err.message,
      details: err.details,
    });
  }
  console.error(tag, err);
  return res.status(500).json({
    error: 'INTERNAL',
    message: 'Erro interno ao processar mensagem.',
  });
}

async function listar(req, res) {
  try {
    const idGrupo = parseIdGrupo(req);
    await ensureMembro(req.user.idUsuario, idGrupo);

    const mensagens = await db.Mensagem.findAll({
      where: { idGrupo, ativo: true },
      include: [{ model: db.Usuario, as: 'autor', attributes: ['idUsuario', 'nome'] }],
      order: [['dataEnvio', 'ASC'], ['idMensagem', 'ASC']],
      limit: HISTORICO_LIMITE,
    });

    return res.status(200).json(mensagens.map(toPayload));
  } catch (err) {
    return tratarErro(res, err, '[mensagem_controller.listar]');
  }
}

async function enviar(req, res) {
  try {
    const idGrupo = parseIdGrupo(req);
    await ensureMembro(req.user.idUsuario, idGrupo);

    const conteudo = (req.body.conteudo || '').trim();
    if (conteudo.length < security.MENSAGEM_TAMANHO_MIN) {
      throw AppError.validation('Mensagem vazia.', { conteudo: 'Mensagem nao pode ser vazia.' });
    }
    if (conteudo.length > security.MENSAGEM_TAMANHO_MAX) {
      throw AppError.validation('Mensagem muito longa.', {
        conteudo: `Maximo de ${security.MENSAGEM_TAMANHO_MAX} caracteres.`,
      });
    }

    const novo = await db.Mensagem.create({
      idGrupo,
      idUsuario: req.user.idUsuario,
      conteudo,
    });

    // Recarrega com o autor pra montar o payload completo (com nome).
    const msg = await db.Mensagem.findByPk(novo.idMensagem, {
      include: [{ model: db.Usuario, as: 'autor', attributes: ['idUsuario', 'nome'] }],
    });
    const payload = toPayload(msg);

    // Broadcast realtime pra todos na sala do grupo (inclui o remetente).
    const io = req.app.get('io');
    if (io) {
      io.to(`grupo:${idGrupo}`).emit('mensagem:nova', payload);
    }

    return res.status(201).json(payload);
  } catch (err) {
    return tratarErro(res, err, '[mensagem_controller.enviar]');
  }
}

module.exports = { listar, enviar };
