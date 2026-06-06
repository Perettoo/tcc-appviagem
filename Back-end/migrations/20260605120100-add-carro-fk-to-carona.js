'use strict';

// A coluna carona.idCarro ja existe (criada nullable em 20260604120000), mas
// sem FK porque a tabela 'carro' ainda nao existia. Agora amarramos a FK.
// SET NULL ao excluir o carro: preserva o historico da carona sem o carro.
module.exports = {
  async up(queryInterface) {
    await queryInterface.addConstraint('carona', {
      fields: ['idCarro'],
      type: 'foreign key',
      name: 'fk_carona_carro',
      references: { table: 'carro', field: 'idCarro' },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL',
    });
  },

  async down(queryInterface) {
    await queryInterface.removeConstraint('carona', 'fk_carona_carro');
  },
};
