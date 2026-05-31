'use strict';

const db = require('../models');
const AppError = require('./app_error');

/**
 * Garante que o usuario autenticado e membro do grupo (e que o grupo existe e
 * esta ativo). Retorna o vinculo GrupoUsuario (util pra saber se e admin).
 * Lanca AppError NOT_FOUND/FORBIDDEN caso contrario.
 */
async function ensureMembro(idUsuario, idGrupo) {
  const grupo = await db.Grupo.findOne({ where: { idGrupo, ativo: true } });
  if (!grupo) {
    throw AppError.notFound('Grupo nao encontrado.');
  }

  const vinculo = await db.GrupoUsuario.findOne({
    where: { idUsuario, idGrupo },
  });
  if (!vinculo) {
    throw AppError.forbidden('Voce nao e membro deste grupo.');
  }

  return vinculo;
}

module.exports = { ensureMembro };
