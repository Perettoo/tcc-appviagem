'use strict';

const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const AppError = require('../errors/app_error');
const jwtConfig = require('../../core/config/jwt');
const usuarioRepository = require('../../data/repositories/usuario_repository');

const CREDENCIAIS_INVALIDAS = 'Email ou senha invalidos.';
const USUARIO_INATIVO = 'Usuario inativo. Contate o administrador.';

async function autenticarUsuario({ email, senha }) {
  if (!email || !senha) {
    throw AppError.validation(CREDENCIAIS_INVALIDAS);
  }

  const usuario = await usuarioRepository.findByEmail(email.trim().toLowerCase());

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

  return {
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
  };
}

module.exports = { autenticarUsuario };
