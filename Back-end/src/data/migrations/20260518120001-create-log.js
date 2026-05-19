'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('log', {
      idLog: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idUsuario: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: {
          model: 'usuario',
          key: 'idUsuario',
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      tabela: {
        type: Sequelize.STRING(60),
        allowNull: false,
      },
      metodo: {
        type: Sequelize.ENUM('get', 'post', 'put', 'delete'),
        allowNull: false,
      },
      status: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      mensagem: {
        type: Sequelize.TEXT,
        allowNull: true,
      },
      createdAt: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('log');
  },
};
