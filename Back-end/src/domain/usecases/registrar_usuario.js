'use strict';

const bcrypt = require('bcryptjs');
const AppError = require('../errors/app_error');
const security = require('../../core/config/security');
const usuarioRepository = require('../../data/repositories/usuario_repository');
const db = require('../../data/models');

const TIPOS_VALIDOS = db.Usuario.rawAttributes.tipo.values;

function validar(input) {
  const erros = {};

  if (!input.nome || input.nome.trim().length < security.NOME_TAMANHO_MIN) {
    erros.nome = `Nome deve ter ao menos ${security.NOME_TAMANHO_MIN} caracteres.`;
  }

  if (!input.email || !security.EMAIL_REGEX.test(input.email)) {
    erros.email = 'E-mail invalido.';
  }

  if (!input.senha || input.senha.length < security.SENHA_TAMANHO_MIN) {
    erros.senha = `Senha deve ter ao menos ${security.SENHA_TAMANHO_MIN} caracteres.`;
  }

  const cpfDigitos = (input.cpf || '').replace(/\D/g, '');
  if (cpfDigitos.length !== security.CPF_TAMANHO) {
    erros.cpf = `CPF deve ter ${security.CPF_TAMANHO} digitos.`;
  }

  const dataNasc = input.dataNascimento ? new Date(input.dataNascimento) : null;
  if (!dataNasc || Number.isNaN(dataNasc.getTime())) {
    erros.dataNascimento = 'Data de nascimento invalida.';
  } else {
    const hoje = new Date();
    const idade = hoje.getFullYear() - dataNasc.getFullYear()
      - (hoje < new Date(hoje.getFullYear(), dataNasc.getMonth(), dataNasc.getDate()) ? 1 : 0);
    if (idade < security.IDADE_MINIMA) {
      erros.dataNascimento = `Usuario deve ter no minimo ${security.IDADE_MINIMA} anos.`;
    }
  }

  if (!TIPOS_VALIDOS.includes(input.tipo)) {
    erros.tipo = `Tipo deve ser um de: ${TIPOS_VALIDOS.join(', ')}.`;
  }

  if (Object.keys(erros).length > 0) {
    throw AppError.validation('Dados invalidos.', erros);
  }

  return { cpfDigitos };
}

async function registrarUsuario(input) {
  const { cpfDigitos } = validar(input);

  const [emailExistente, cpfExistente] = await Promise.all([
    usuarioRepository.findByEmail(input.email),
    usuarioRepository.findByCpf(cpfDigitos),
  ]);

  if (emailExistente) {
    throw AppError.conflict('E-mail ja cadastrado.', { campo: 'email' });
  }
  if (cpfExistente) {
    throw AppError.conflict('CPF ja cadastrado.', { campo: 'cpf' });
  }

  const senhaHash = await bcrypt.hash(input.senha, security.BCRYPT_COST);

  const usuario = await usuarioRepository.create({
    nome: input.nome.trim(),
    email: input.email.trim().toLowerCase(),
    senhaHash,
    dataNascimento: input.dataNascimento,
    cpf: cpfDigitos,
    tipo: input.tipo,
  });

  return {
    idUsuario: usuario.idUsuario,
    nome: usuario.nome,
    email: usuario.email,
    tipo: usuario.tipo,
    dataNascimento: usuario.dataNascimento,
    dataCadastro: usuario.dataCadastro,
    ativo: usuario.ativo,
  };
}

module.exports = { registrarUsuario };
