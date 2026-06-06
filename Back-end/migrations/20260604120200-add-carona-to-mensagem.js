'use strict';

// Espelha config/security.js MENSAGEM_TIPO (congelado na migration).
const TIPOS = ['TEXTO', 'CARONA'];

module.exports = {
  async up(queryInterface, Sequelize) {
    // Distingue mensagem de texto de um pedido de carona renderizado como card.
    await queryInterface.addColumn('mensagem', 'tipo', {
      type: Sequelize.ENUM(...TIPOS),
      allowNull: false,
      defaultValue: 'TEXTO',
    });

    // FK opcional para a carona quando tipo = CARONA.
    await queryInterface.addColumn('mensagem', 'idCarona', {
      type: Sequelize.INTEGER,
      allowNull: true,
      references: { model: 'carona', key: 'idCarona' },
      onUpdate: 'CASCADE',
      onDelete: 'CASCADE',
    });
  },

  async down(queryInterface) {
    await queryInterface.removeColumn('mensagem', 'idCarona');
    await queryInterface.removeColumn('mensagem', 'tipo');
    // Em MySQL o tipo ENUM gera um tipo proprio; o removeColumn ja o descarta.
  },
};
