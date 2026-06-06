'use strict';

const db = require('../../models');
const AppError = require('../../utils/app_error');
const security = require('../../config/security');
const { ensureMembro } = require('../../utils/membership');
const {
  montarPayload,
  includeMensagem,
  caronaPayload,
} = require('../../utils/mensagem_payload');

function parseIdGrupo(req) {
  const idGrupo = Number(req.params.idGrupo);
  if (!Number.isInteger(idGrupo) || idGrupo <= 0) {
    throw AppError.validation('Grupo invalido.');
  }
  return idGrupo;
}

function parseIdCarona(req) {
  const idCarona = Number(req.params.idCarona);
  if (!Number.isInteger(idCarona) || idCarona <= 0) {
    throw AppError.validation('Carona invalida.');
  }
  return idCarona;
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
    message: 'Erro interno ao processar carona.',
  });
}

// Recarrega a carona com o motorista, emite carona:atualizada pra sala do grupo
// e responde 200 com o payload. Chamar como ultimo passo apos salvar o status.
async function emitirEResponder(req, res, idCarona, idGrupo) {
  const completa = await db.Carona.findByPk(idCarona, {
    include: [
      { model: db.Usuario, as: 'motorista', attributes: ['idUsuario', 'nome'] },
    ],
  });
  const payload = caronaPayload(completa);
  const io = req.app.get('io');
  if (io) {
    io.to(`grupo:${idGrupo}`).emit('carona:atualizada', payload);
  }
  return res.status(200).json(payload);
}

// Passageiro pede uma carona no grupo. Cria a carona (pendente, sem motorista),
// registra o solicitante como passageiro e posta um pedido no chat. Tudo numa
// transacao: ou as tres coisas existem, ou nenhuma.
async function solicitar(req, res) {
  const t = await db.sequelize.transaction();
  let payload;
  let idGrupo;
  try {
    idGrupo = parseIdGrupo(req);
    await ensureMembro(req.user.idUsuario, idGrupo);

    const carona = await db.Carona.create(
      { idGrupo, status: security.CARONA_STATUS.PENDENTE },
      { transaction: t },
    );

    await db.CaronaUsuario.create(
      { idCarona: carona.idCarona, idPassageiro: req.user.idUsuario },
      { transaction: t },
    );

    const nova = await db.Mensagem.create(
      {
        idGrupo,
        idUsuario: req.user.idUsuario,
        tipo: security.MENSAGEM_TIPO.CARONA,
        idCarona: carona.idCarona,
        conteudo: security.CARONA_MENSAGEM_PADRAO,
      },
      { transaction: t },
    );

    const msg = await db.Mensagem.findByPk(nova.idMensagem, {
      include: includeMensagem(db),
      transaction: t,
    });
    payload = montarPayload(msg);

    await t.commit();
  } catch (err) {
    await t.rollback().catch(() => {});
    return tratarErro(res, err, '[carona_controller.solicitar]');
  }

  // Broadcast pra sala do grupo (inclui o solicitante) so apos o commit.
  const io = req.app.get('io');
  if (io) {
    io.to(`grupo:${idGrupo}`).emit('mensagem:nova', payload);
  }

  return res.status(201).json(payload);
}

// Um motorista do grupo aceita uma carona pendente. Regras: precisa ser membro
// do grupo, ter tipo motorista/ambos e NAO ser o solicitante. So caronas
// pendentes podem ser aceitas.
async function aceitar(req, res) {
  try {
    const idCarona = parseIdCarona(req);

    const carona = await db.Carona.findOne({ where: { idCarona, ativo: true } });
    if (!carona) {
      throw AppError.notFound('Carona nao encontrada.');
    }
    const idGrupo = carona.idGrupo;

    // Membro do grupo (mesma regra do chat).
    await ensureMembro(req.user.idUsuario, idGrupo);

    // So motorista/ambos podem aceitar.
    if (!security.CARONA_TIPOS_MOTORISTA.includes(req.user.tipo)) {
      throw AppError.forbidden('Apenas motoristas podem aceitar caronas.');
    }

    // Nao pode aceitar a propria carona (quem pediu e passageiro dela).
    const ehSolicitante = await db.CaronaUsuario.findOne({
      where: { idCarona, idPassageiro: req.user.idUsuario },
    });
    if (ehSolicitante) {
      throw AppError.forbidden('Voce nao pode aceitar a propria carona.');
    }

    // So pendente pode ser aceita (evita corrida entre dois motoristas).
    if (carona.status !== security.CARONA_STATUS.PENDENTE) {
      throw AppError.conflict('Esta carona ja foi aceita ou nao esta disponivel.');
    }

    // O carro ativo do motorista e atrelado a carona. Sem carro, nao aceita.
    const carro = await db.Carro.findOne({
      where: { idUsuario: req.user.idUsuario, ativo: true },
    });
    if (!carro) {
      throw AppError.validation(security.CARRO_OBRIGATORIO_MSG);
    }

    carona.idMotorista = req.user.idUsuario;
    carona.idCarro = carro.idCarro;
    carona.status = security.CARONA_STATUS.ACEITA;
    await carona.save();

    return await emitirEResponder(req, res, idCarona, idGrupo);
  } catch (err) {
    return tratarErro(res, err, '[carona_controller.aceitar]');
  }
}

// So o motorista da carona conclui, e somente quando ela esta 'aceita'.
async function concluir(req, res) {
  try {
    const idCarona = parseIdCarona(req);

    const carona = await db.Carona.findOne({ where: { idCarona, ativo: true } });
    if (!carona) {
      throw AppError.notFound('Carona nao encontrada.');
    }
    const idGrupo = carona.idGrupo;

    await ensureMembro(req.user.idUsuario, idGrupo);

    // Estado antes do papel: numa carona pendente nao ha motorista, e a razao
    // correta e "ainda nao foi aceita" (409), nao "voce nao e o motorista".
    if (carona.status !== security.CARONA_STATUS.ACEITA) {
      throw AppError.conflict('So caronas aceitas podem ser concluidas.');
    }

    if (carona.idMotorista !== req.user.idUsuario) {
      throw AppError.forbidden('Apenas o motorista pode concluir a carona.');
    }

    carona.status = security.CARONA_STATUS.CONCLUIDA;
    await carona.save();

    return await emitirEResponder(req, res, idCarona, idGrupo);
  } catch (err) {
    return tratarErro(res, err, '[carona_controller.concluir]');
  }
}

// Solicitante (passageiro) ou motorista podem cancelar, enquanto pendente ou
// aceita. Depois de concluida/cancelada nao da mais.
async function cancelar(req, res) {
  try {
    const idCarona = parseIdCarona(req);

    const carona = await db.Carona.findOne({ where: { idCarona, ativo: true } });
    if (!carona) {
      throw AppError.notFound('Carona nao encontrada.');
    }
    const idGrupo = carona.idGrupo;

    await ensureMembro(req.user.idUsuario, idGrupo);

    const ehMotorista = carona.idMotorista === req.user.idUsuario;
    const ehSolicitante = await db.CaronaUsuario.findOne({
      where: { idCarona, idPassageiro: req.user.idUsuario },
    });
    if (!ehMotorista && !ehSolicitante) {
      throw AppError.forbidden(
        'Apenas o solicitante ou o motorista podem cancelar a carona.',
      );
    }

    const cancelavel = [
      security.CARONA_STATUS.PENDENTE,
      security.CARONA_STATUS.ACEITA,
    ].includes(carona.status);
    if (!cancelavel) {
      throw AppError.conflict('Esta carona nao pode mais ser cancelada.');
    }

    carona.status = security.CARONA_STATUS.CANCELADA;
    await carona.save();

    return await emitirEResponder(req, res, idCarona, idGrupo);
  } catch (err) {
    return tratarErro(res, err, '[carona_controller.cancelar]');
  }
}

// Lista as caronas em que o usuario participa: como motorista (aceitou) OU
// como passageiro (pediu/entrou). Resumo por carona, mais recentes primeiro.
async function listar(req, res) {
  try {
    const meuId = req.user.idUsuario;
    const { Op } = db.Sequelize;

    const vinculos = await db.CaronaUsuario.findAll({
      where: { idPassageiro: meuId },
      attributes: ['idCarona'],
    });
    const idsComoPassageiro = vinculos.map((v) => v.idCarona);

    const ondeParticipa = [{ idMotorista: meuId }];
    if (idsComoPassageiro.length) {
      ondeParticipa.push({ idCarona: { [Op.in]: idsComoPassageiro } });
    }

    const caronas = await db.Carona.findAll({
      where: { ativo: true, [Op.or]: ondeParticipa },
      include: [
        { model: db.Grupo, as: 'grupo', attributes: ['idGrupo', 'nome'] },
        { model: db.Usuario, as: 'motorista', attributes: ['idUsuario', 'nome'] },
        { model: db.CaronaUsuario, as: 'passageiros', attributes: ['idPivot'] },
      ],
      order: [['data', 'DESC'], ['idCarona', 'DESC']],
    });

    const lista = caronas.map((c) => ({
      idCarona: c.idCarona,
      idGrupo: c.idGrupo,
      grupoNome: c.grupo ? c.grupo.nome : null,
      status: c.status,
      data: c.data,
      papel: c.idMotorista === meuId ? 'motorista' : 'passageiro',
      motoristaNome: c.motorista ? c.motorista.nome : null,
      totalPassageiros: c.passageiros ? c.passageiros.length : 0,
    }));

    return res.status(200).json(lista);
  } catch (err) {
    return tratarErro(res, err, '[carona_controller.listar]');
  }
}

// Detalhe de uma carona: motorista + lista de passageiros. So membro do grupo
// (motorista e passageiros sao membros) pode ver.
async function detalhe(req, res) {
  try {
    const idCarona = parseIdCarona(req);

    const carona = await db.Carona.findOne({
      where: { idCarona, ativo: true },
      include: [
        { model: db.Grupo, as: 'grupo', attributes: ['idGrupo', 'nome'] },
        { model: db.Usuario, as: 'motorista', attributes: ['idUsuario', 'nome'] },
        {
          model: db.Carro,
          as: 'carro',
          attributes: ['idCarro', 'marca', 'modelo', 'anoFabricacao', 'cor', 'placa'],
        },
        {
          model: db.CaronaUsuario,
          as: 'passageiros',
          include: [
            { model: db.Usuario, as: 'passageiro', attributes: ['idUsuario', 'nome'] },
          ],
        },
      ],
    });
    if (!carona) {
      throw AppError.notFound('Carona nao encontrada.');
    }

    await ensureMembro(req.user.idUsuario, carona.idGrupo);

    return res.status(200).json({
      idCarona: carona.idCarona,
      idGrupo: carona.idGrupo,
      grupoNome: carona.grupo ? carona.grupo.nome : null,
      status: carona.status,
      data: carona.data,
      motorista: carona.motorista
        ? { idUsuario: carona.motorista.idUsuario, nome: carona.motorista.nome }
        : null,
      carro: carona.carro
        ? {
            idCarro: carona.carro.idCarro,
            marca: carona.carro.marca,
            modelo: carona.carro.modelo,
            anoFabricacao: carona.carro.anoFabricacao,
            cor: carona.carro.cor,
            placa: carona.carro.placa,
          }
        : null,
      passageiros: (carona.passageiros || []).map((p) => ({
        idUsuario: p.passageiro ? p.passageiro.idUsuario : p.idPassageiro,
        nome: p.passageiro ? p.passageiro.nome : null,
        distancia: p.distancia,
      })),
    });
  } catch (err) {
    return tratarErro(res, err, '[carona_controller.detalhe]');
  }
}

module.exports = { solicitar, aceitar, concluir, cancelar, listar, detalhe };
