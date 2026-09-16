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
      
      capacidade: {
        type: Sequelize.INTEGER,
        allowNull: false,
        defaultValue: 5, // Assume 5 lugares se nada for enviado
      },
      
      consumoMedio: {
        type: Sequelize.FLOAT,
        allowNull: false,
        defaultValue: 10.0, // Assume 10km/l por padrão
      },
      
      ativo: {
        type: Sequelize.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    });

    await queryInterface.addIndex('carro', ['idUsuario'], {
      name: 'ix_carro_usuario',
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('carro');
  },
};