'use strict';

const bcrypt = require('bcryptjs');
const db = require('../models');
const AppError = require('../utils/app_error');
const security = require('../config/security');

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

async function registrar(req, res) {
  try {
    const input = req.body;
    const { cpfDigitos } = validar(input);
    const email = input.email.trim().toLowerCase();

    const [emailExistente, cpfExistente] = await Promise.all([
      db.Usuario.findOne({ where: { email } }),
      db.Usuario.findOne({ where: { cpf: cpfDigitos } }),
    ]);
    if (emailExistente) {
      throw AppError.conflict('E-mail ja cadastrado.', { campo: 'email' });
    }
    if (cpfExistente) {
      throw AppError.conflict('CPF ja cadastrado.', { campo: 'cpf' });
    }

    const senhaHash = await bcrypt.hash(input.senha, security.BCRYPT_COST);

    const usuario = await db.Usuario.create({
      nome: input.nome.trim(),
      email,
      senhaHash,
      dataNascimento: input.dataNascimento,
      cpf: cpfDigitos,
      tipo: input.tipo,
    });

    return res.status(201).json({
      idUsuario: usuario.idUsuario,
      nome: usuario.nome,
      email: usuario.email,
      tipo: usuario.tipo,
      dataNascimento: usuario.dataNascimento,
      dataCadastro: usuario.dataCadastro,
      ativo: usuario.ativo,
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
