'use strict';

// Destino/observacao do anuncio do motorista (ex.: "Saindo para a faculdade").
// Nullable: caronas antigas nao tem destino.
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('carona', 'destino', {
      type: Sequelize.STRING(120),
      allowNull: true,
    });
  },

  async down(queryInterface) {
    await queryInterface.removeColumn('carona', 'destino');
  },
};
