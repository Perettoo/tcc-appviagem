'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('carona_usuario', {
      idPivot: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false,
      },
      idCarona: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'carona', key: 'idCarona' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      idPassageiro: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'usuario', key: 'idUsuario' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      // Nula no pedido: so faz sentido quando houver rota/motorista definidos.
      distancia: {
        type: Sequelize.FLOAT,
        allowNull: true,
      },
    });

    // Um usuario nao pode entrar duas vezes na mesma carona.
    await queryInterface.addConstraint('carona_usuario', {
      fields: ['idCarona', 'idPassageiro'],
      type: 'unique',
      name: 'uq_carona_passageiro',
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('carona_usuario');
  },
};
