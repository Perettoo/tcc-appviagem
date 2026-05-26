'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('grupo', {
      idGrupo: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idUsuarioCriado: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'usuario', key: 'idUsuario' },
        onUpdate: 'CASCADE',
        onDelete: 'RESTRICT',
      },
      nome: {
        type: Sequelize.STRING(120),
        allowNull: false,
      },
      isPrivado: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
      dataCriacao: {
        type: Sequelize.DATE,
        allowNull: false,
        defaultValue: Sequelize.literal('CURRENT_TIMESTAMP'),
      },
      ativo: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('grupo');
  },
};
