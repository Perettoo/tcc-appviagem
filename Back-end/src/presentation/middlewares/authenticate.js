'use strict';

const jwt = require('jsonwebtoken');
const jwtConfig = require('../../core/config/jwt');

function authenticate(req, res, next) {
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
