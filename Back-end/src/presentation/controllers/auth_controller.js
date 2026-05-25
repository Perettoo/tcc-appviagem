'use strict';

const { autenticarUsuario } = require('../../domain/usecases/autenticar_usuario');
const AppError = require('../../domain/errors/app_error');

async function login(req, res) {
  try {
    const resultado = await autenticarUsuario({
      email: req.body.email,
      senha: req.body.senha,
    });
    return res.status(200).json(resultado);
  } catch (err) {
    if (err instanceof AppError) {
      return res.status(401).json({
        error: 'UNAUTHENTICATED',
        message: err.message,
      });
    }
    console.error('[auth_controller.login]', err);
    return res.status(500).json({
      error: 'INTERNAL',
      message: 'Erro interno ao autenticar.',
    });
  }
}

function me(req, res) {
  return res.status(200).json({ user: req.user });
}

module.exports = { login, me };
