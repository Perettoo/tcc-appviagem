'use strict';

const { registrarUsuario } = require('../../domain/usecases/registrar_usuario');
const AppError = require('../../domain/errors/app_error');

async function registrar(req, res) {
  try {
    const usuario = await registrarUsuario(req.body);
    return res.status(201).json(usuario);
  } catch (err) {
    if (err instanceof AppError) {
      const status = err.type === 'CONFLICT' ? 409 : 400;
      return res.status(status).json({
        error: err.type,
        message: err.message,
        details: err.details,
      });
    }
    if (err.name === 'SequelizeUniqueConstraintError') {
      const campo = err.errors?.[0]?.path || 'campo';
      return res.status(409).json({
        error: 'CONFLICT',
        message: `${campo} ja cadastrado.`,
        details: { campo },
      });
    }
    console.error('[usuario_controller.registrar]', err);
    return res.status(500).json({
      error: 'INTERNAL',
      message: 'Erro interno ao registrar usuario.',
    });
  }
}

module.exports = { registrar };
