'use strict';

const jwt = require('jsonwebtoken');
const jwtConfig = require('../config/jwt');
const db = require('../models');

// 2. Transformamos a função em async para poder consultar o banco
async function authenticate(req, res, next) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({
      error: 'UNAUTHENTICATED',
      message: 'Token nao fornecido.',
    });
  }

  const token = header.substring(7);

  try {
    const payload = jwt.verify(token, jwtConfig.secret);

    // 3. NOVO: Verificação em tempo real (Impede o "Token Fantasma")
    const usuarioAtivo = await db.Usuario.findOne({
      where: { idUsuario: payload.sub, ativo: true },
      attributes: ['idUsuario'], // Buscamos só o ID para a consulta ser na velocidade da luz
    });

    if (!usuarioAtivo) {
      return res.status(401).json({
        error: 'UNAUTHENTICATED',
        message: 'Usuário desativado ou conta inexistente.',
      });
    }

    req.user = {
      idUsuario: payload.sub,
      tipo: payload.tipo,
      email: payload.email,
    };
    return next();
  } catch (err) {
    const motivo = err.name === 'TokenExpiredError'
      ? 'Token expirado.'
      : 'Token invalido.';
    return res.status(401).json({
      error: 'UNAUTHENTICATED',
      message: motivo,
    });
  }
}

module.exports = authenticate;