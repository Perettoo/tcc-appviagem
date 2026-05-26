'use strict';

const db = require('../models');
const AppError = require('../utils/app_error');
const security = require('../config/security');

function validarNome(nome) {
  if (!nome || nome.trim().length < security.GRUPO_NOME_TAMANHO_MIN) {
    throw AppError.validation('Dados invalidos.', {
      nome: `Nome do grupo deve ter ao menos ${security.GRUPO_NOME_TAMANHO_MIN} caracteres.`,
    });
  }
}

async function criar(req, res) {
  try {
    const { nome, isPrivado } = req.body;
    validarNome(nome);

    // idUsuarioCriado vem do token (req.user), nunca do corpo.
    const idUsuarioCriado = req.user.idUsuario;

    // Cria o grupo e ja registra o criador como membro admin (atomico).
    const grupo = await db.sequelize.transaction(async (t) => {
      const novo = await db.Grupo.create(
        { idUsuarioCriado, nome: nome.trim(), isPrivado: Boolean(isPrivado) },
        { transaction: t },
      );
      await db.GrupoUsuario.create(
        { idGrupo: novo.idGrupo, idUsuario: idUsuarioCriado, isAdm: true },
        { transaction: t },
      );
      return novo;
    });

    return res.status(201).json({
      idGrupo: grupo.idGrupo,
      nome: grupo.nome,
      isPrivado: grupo.isPrivado,
      dataCriacao: grupo.dataCriacao,
      ativo: grupo.ativo,
      isAdm: true,
    });
  } catch (err) {
    if (err instanceof AppError) {
      const status = err.type === 'CONFLICT' ? 409 : 400;
      return res.status(status).json({
        error: err.type,
        message: err.message,
        details: err.details,
      });
    }
    console.error('[grupo_controller.criar]', err);
    return res.status(500).json({
      error: 'INTERNAL',
      message: 'Erro interno ao criar grupo.',
    });
  }
}

async function listar(req, res) {
  try {
    // Grupos ativos em que o usuario autenticado e membro.
    const membros = await db.GrupoUsuario.findAll({
      where: { idUsuario: req.user.idUsuario },
      include: [{ model: db.Grupo, as: 'grupo', where: { ativo: true } }],
      order: [[{ model: db.Grupo, as: 'grupo' }, 'dataCriacao', 'DESC']],
    });

    const grupos = membros.map((m) => ({
      idGrupo: m.grupo.idGrupo,
      nome: m.grupo.nome,
      isPrivado: m.grupo.isPrivado,
      dataCriacao: m.grupo.dataCriacao,
      isAdm: m.isAdm,
    }));

    return res.status(200).json(grupos);
  } catch (err) {
    console.error('[grupo_controller.listar]', err);
    return res.status(500).json({
      error: 'INTERNAL',
      message: 'Erro interno ao listar grupos.',
    });
  }
}

module.exports = { criar, listar };
