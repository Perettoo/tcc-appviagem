'use strict';

const bcrypt = require('bcryptjs');
const security = require('../../core/config/security');

module.exports = {
  async up(queryInterface) {
    const email = process.env.ADMIN_EMAIL;
    const senha = process.env.ADMIN_SENHA;
    const nome = process.env.ADMIN_NOME;
    const cpf = process.env.ADMIN_CPF;
    const dataNascimento = process.env.ADMIN_DATA_NASCIMENTO;

    if (!email || !senha || !nome || !cpf || !dataNascimento) {
      throw new Error(
        'Seeder admin: variaveis ADMIN_EMAIL, ADMIN_SENHA, ADMIN_NOME, ' +
        'ADMIN_CPF, ADMIN_DATA_NASCIMENTO devem estar no .env',
      );
    }

    const existente = await queryInterface.sequelize.query(
      'SELECT idUsuario FROM usuario WHERE email = :email LIMIT 1',
      {
        replacements: { email },
        type: queryInterface.sequelize.QueryTypes.SELECT,
      },
    );
    if (existente.length > 0) return;

    const senhaHash = await bcrypt.hash(senha, security.BCRYPT_COST);

    await queryInterface.bulkInsert('usuario', [
      {
        nome,
        email,
        senhaHash,
        dataNascimento,
        dataCadastro: new Date(),
        cpf,
        tipo: 'ambos',
        ativo: true,
      },
    ]);
  },

  async down(queryInterface) {
    const email = process.env.ADMIN_EMAIL;
    if (!email) return;
    await queryInterface.bulkDelete('usuario', { email });
  },
};
