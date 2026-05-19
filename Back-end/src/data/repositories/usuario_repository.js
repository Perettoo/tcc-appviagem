'use strict';

const db = require('../models');

class UsuarioRepository {
  async create(data) {
    return db.Usuario.create(data);
  }

  async findByEmail(email) {
    return db.Usuario.findOne({ where: { email } });
  }

  async findByCpf(cpf) {
    return db.Usuario.findOne({ where: { cpf } });
  }
}

module.exports = new UsuarioRepository();
