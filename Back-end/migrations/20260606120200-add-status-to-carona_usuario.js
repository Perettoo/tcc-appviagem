'use strict';

// Status do pedido de cada passageiro: pendente (pediu) -> aprovado/recusado
// (decisao do motorista). Vinculos antigos (fluxo anterior) viram 'aprovado',
// pois ja eram passageiros efetivos da carona.
const STATUS = ['pendente', 'aprovado', 'recusado'];

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('carona_usuario', 'status', {
      type: Sequelize.ENUM(...STATUS),
      allowNull: false,
      defaultValue: 'pendente',
    });

    await queryInterface.sequelize.query(
      "UPDATE carona_usuario SET status = 'aprovado'",
    );
  },

  async down(queryInterface) {
    await queryInterface.removeColumn('carona_usuario', 'status');
    // Em MySQL o ENUM gera um tipo proprio; removeColumn ja o descarta.
  },
};
