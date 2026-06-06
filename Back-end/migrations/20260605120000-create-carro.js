'use strict';

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('carro', {
      idCarro: {
        type: Sequelize.INTEGER,
        autoIncrement: true,
        primaryKey: true,
        allowNull: false,
      },
      idUsuario: {
        type: Sequelize.INTEGER,
        allowNull: false,
        references: { model: 'usuario', key: 'idUsuario' },
        onUpdate: 'CASCADE',
        onDelete: 'CASCADE',
      },
      marca: {
        type: Sequelize.STRING(60),
        allowNull: false,
      },
      modelo: {
        type: Sequelize.STRING(60),
        allowNull: false,
      },
      anoFabricacao: {
        type: Sequelize.INTEGER,
        allowNull: false,
      },
      cor: {
        type: Sequelize.STRING(30),
        allowNull: false,
      },
      placa: {
        type: Sequelize.STRING(7),
        allowNull: false,
      },
      // Carro selecionado do usuario (o que e atrelado a carona ao aceitar).
      // No maximo um ativo por usuario; a regra e garantida no controller.
      ativo: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    });

    // Carros de um usuario; busca do ativo passa por aqui.
    await queryInterface.addIndex('carro', ['idUsuario'], {
      name: 'ix_carro_usuario',
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('carro');
  },
};
