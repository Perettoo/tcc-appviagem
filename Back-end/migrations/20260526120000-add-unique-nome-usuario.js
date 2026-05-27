'use strict';

/**
 * Torna `usuario.nome` unico para que possa ser usado como identificador de
 * login (alem do email). Pre-condicao: nao podem existir nomes duplicados.
 */
module.exports = {
  async up(queryInterface) {
    await queryInterface.addConstraint('usuario', {
      fields: ['nome'],
      type: 'unique',
      name: 'uq_usuario_nome',
    });
  },

  async down(queryInterface) {
    await queryInterface.removeConstraint('usuario', 'uq_usuario_nome');
  },
};
