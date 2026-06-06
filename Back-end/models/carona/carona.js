'use strict';

const security = require('../../config/security');

module.exports = (sequelize, DataTypes) => {
  const Carona = sequelize.define(
    'Carona',
    {
      idCarona: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idGrupo: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      // Nulo no pedido; preenchido quando um motorista aceitar (fluxo futuro).
      idMotorista: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      // Sem associacao por enquanto: a tabela 'carro' vem depois.
      idCarro: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      status: {
        type: DataTypes.ENUM(...Object.values(security.CARONA_STATUS)),
        allowNull: false,
        defaultValue: security.CARONA_STATUS.PENDENTE,
      },
      data: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      ativo: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
    },
    {
      tableName: 'carona',
      timestamps: false,
    },
  );

  Carona.associate = (models) => {
    Carona.belongsTo(models.Grupo, { foreignKey: 'idGrupo', as: 'grupo' });
    Carona.belongsTo(models.Usuario, { foreignKey: 'idMotorista', as: 'motorista' });
    Carona.hasMany(models.CaronaUsuario, { foreignKey: 'idCarona', as: 'passageiros' });
    Carona.hasMany(models.Mensagem, { foreignKey: 'idCarona', as: 'mensagens' });
  };

  return Carona;
};
