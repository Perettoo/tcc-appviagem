'use strict';

// Valores congelados no momento da migration (espelham config/security.js
// CARONA_STATUS). Migrations sao snapshots e nao devem depender do config.
const STATUS = ['pendente', 'aceita', 'concluida', 'cancelada'];

module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.createTable('carona', {
      idCarona: {
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
      // Nulo no momento do pedido: so e preenchido quando um motorista aceita.
      idMotorista: {
        type: Sequelize.INTEGER,
        allowNull: true,
        references: { model: 'usuario', key: 'idUsuario' },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      // Sem FK por enquanto: a tabela 'carro' sera criada depois.
      idCarro: {
        type: Sequelize.INTEGER,
        allowNull: true,
      },
      status: {
        type: Sequelize.ENUM(...STATUS),
        allowNull: false,
        defaultValue: 'pendente',
      },
      data: {
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

    // Caronas de um grupo, das mais recentes para as mais antigas.
    await queryInterface.addIndex('carona', ['idGrupo', 'data'], {
      name: 'ix_carona_grupo_data',
    });
  },

  async down(queryInterface) {
    await queryInterface.dropTable('carona');
  },
};
