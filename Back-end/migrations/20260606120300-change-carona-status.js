'use strict';

// Novo ciclo de vida da carona: o motorista anuncia (aberta) e conclui/cancela.
// Os status antigos (pendente/aceita) saem. Migra os dados existentes:
//   - 'aceita'   (tinha motorista)        -> 'aberta'
//   - 'pendente' (pedido sem motorista)   -> 'cancelada' (invalido no novo fluxo)
module.exports = {
  async up(queryInterface, Sequelize) {
    // 1) Alarga o ENUM para conter antigos + novos, permitindo o UPDATE.
    await queryInterface.changeColumn('carona', 'status', {
      type: Sequelize.ENUM(
        'pendente',
        'aceita',
        'aberta',
        'concluida',
        'cancelada',
      ),
      allowNull: false,
      defaultValue: 'aberta',
    });

    await queryInterface.sequelize.query(
      "UPDATE carona SET status = 'aberta' WHERE status = 'aceita'",
    );
    await queryInterface.sequelize.query(
      "UPDATE carona SET status = 'cancelada' WHERE status = 'pendente'",
    );

    // 2) Estreita o ENUM para o conjunto final.
    await queryInterface.changeColumn('carona', 'status', {
      type: Sequelize.ENUM('aberta', 'concluida', 'cancelada'),
      allowNull: false,
      defaultValue: 'aberta',
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.changeColumn('carona', 'status', {
      type: Sequelize.ENUM(
        'pendente',
        'aceita',
        'aberta',
        'concluida',
        'cancelada',
      ),
      allowNull: false,
      defaultValue: 'pendente',
    });
    await queryInterface.sequelize.query(
      "UPDATE carona SET status = 'aceita' WHERE status = 'aberta'",
    );
    await queryInterface.changeColumn('carona', 'status', {
      type: Sequelize.ENUM('pendente', 'aceita', 'concluida', 'cancelada'),
      allowNull: false,
      defaultValue: 'pendente',
    });
  },
};
