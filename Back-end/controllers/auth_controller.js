'use strict';

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../models');
const AppError = require('../utils/app_error');
const jwtConfig = require('../config/jwt');

const CREDENCIAIS_INVALIDAS = 'Email ou senha invalidos.';
const USUARIO_INATIVO = 'Usuario inativo. Contate o administrador.';

async function login(req, res) {
  try {
    const { email, senha } = req.body;
    if (!email || !senha) {
      throw AppError.validation(CREDENCIAIS_INVALIDAS);
    }

    const usuario = await db.Usuario.findOne({
      where: { email: email.trim().toLowerCase() },
    });

    // Mesma mensagem pra "nao existe" e "senha errada" (evita enumeration).
    if (!usuario) {
      throw AppError.validation(CREDENCIAIS_INVALIDAS);
    }

    const senhaCorreta = await bcrypt.compare(senha, usuario.senhaHash);
    if (!senhaCorreta) {
      throw AppError.validation(CREDENCIAIS_INVALIDAS);
    }

    if (!usuario.ativo) {
      throw AppError.validation(USUARIO_INATIVO);
    }

    const token = jwt.sign(
      {
        sub: usuario.idUsuario,
        tipo: usuario.tipo,
        email: usuario.email,
      },
      jwtConfig.secret,
      { expiresIn: jwtConfig.expiresIn },
    );

    return res.status(200).json({
      token,
      usuario: {
        idUsuario: usuario.idUsuario,
        nome: usuario.nome,
        email: usuario.email,
        tipo: usuario.tipo,
        dataNascimento: usuario.dataNascimento,
        dataCadastro: usuario.dataCadastro,
        ativo: usuario.ativo,
      },
    });
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
