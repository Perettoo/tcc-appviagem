'use strict';

const bcrypt = require('bcryptjs');
const AppError = require('../errors/app_error');
const usuarioRepository = require('../../data/repositories/usuario_repository');

const TIPOS_VALIDOS = ['motorista', 'passageiro', 'ambos'];
const EMAIL_REGEX = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
const BCRYPT_COST = 10;
const IDADE_MINIMA = 18;
const SENHA_TAMANHO_MIN = 8;

function validar(input) {
  const erros = {};

  if (!input.nome || input.nome.trim().length < 2) {
    erros.nome = 'Nome deve ter ao menos 2 caracteres.';
  }

  if (!input.email || !EMAIL_REGEX.test(input.email)) {
    erros.email = 'E-mail invalido.';
  }

  if (!input.senha || input.senha.length < SENHA_TAMANHO_MIN) {
    erros.senha = `Senha deve ter ao menos ${SENHA_TAMANHO_MIN} caracteres.`;
  }

  const cpfDigitos = (input.cpf || '').replace(/\D/g, '');
  if (cpfDigitos.length !== 11) {
    erros.cpf = 'CPF deve ter 11 digitos.';
  }

  const dataNasc = input.dataNascimento ? new Date(input.dataNascimento) : null;
  if (!dataNasc || Number.isNaN(dataNasc.getTime())) {
    erros.dataNascimento = 'Data de nascimento invalida.';
  } else {
    const hoje = new Date();
    const idade = hoje.getFullYear() - dataNasc.getFullYear()
      - (hoje < new Date(hoje.getFullYear(), dataNasc.getMonth(), dataNasc.getDate()) ? 1 : 0);
    if (idade < IDADE_MINIMA) {
      erros.dataNascimento = `Usuario deve ter no minimo ${IDADE_MINIMA} anos.`;
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

  const senhaHash = await bcrypt.hash(input.senha, BCRYPT_COST);

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
