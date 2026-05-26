'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('grupo_usuario', {
      idGrupoUsuario: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idUsuario: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'usuario', key: 'idUsuario' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      idGrupo: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'grupo', key: 'idGrupo' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      isAdm: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    });

    // Um usuario nao pode aparecer duas vezes no mesmo grupo.
    await queryInterface.addConstraint('grupo_usuario', {
      fields: ['idUsuario', 'idGrupo'],
      type: 'unique',
      name: 'uq_grupo_usuario_membro',
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('grupo_usuario');
  },
};
