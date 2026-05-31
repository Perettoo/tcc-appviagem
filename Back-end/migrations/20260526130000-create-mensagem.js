'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('mensagem', {
      idMensagem: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false,
      },
      idGrupo: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'grupo', key: 'idGrupo' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      idUsuario: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'usuario', key: 'idUsuario' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      conteudo: {
        type: Sequelize.TEXT,
        allowNull: false,
      },
      dataEnvio: {
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

    // Histórico do chat por grupo, em ordem cronológica.
    await queryInterface.addIndex('mensagem', ['idGrupo', 'dataEnvio'], {
      name: 'ix_mensagem_grupo_data',
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('mensagem');
  },
};
