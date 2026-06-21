'use strict';

// Capacidade total do carro (motorista incluso). O limite de passageiros de uma
// carona e capacidade - 1. Carros ja cadastrados recebem 5 (valor tipico).
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('carro', 'capacidade', {
      type: Sequelize.INTEGER,
      allowNull: true,
    });

    await queryInterface.sequelize.query(
      'UPDATE carro SET capacidade = 5 WHERE capacidade IS NULL',
    );

    await queryInterface.changeColumn('carro', 'capacidade', {
      type: Sequelize.INTEGER,
      allowNull: false,
      defaultValue: 5,
    });
  },

  async down(queryInterface) {
    await queryInterface.removeColumn('carro', 'capacidade');
  },
};
