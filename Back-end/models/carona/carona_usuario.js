'use strict';

const security = require('../../config/security');

module.exports = (sequelize, DataTypes) => {
  const CaronaUsuario = sequelize.define(
    'CaronaUsuario',
    {
      idPivot: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idCarona: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      idPassageiro: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      // Pedido do passageiro: pendente -> aprovado/recusado (decisao do motorista).
      status: {
        type: DataTypes.ENUM(...Object.values(security.CARONA_PASSAGEIRO_STATUS)),
        allowNull: false,
        defaultValue: security.CARONA_PASSAGEIRO_STATUS.PENDENTE,
      },
      // Nula no pedido; so faz sentido quando houver rota definida.
      distancia: {
        type: DataTypes.FLOAT,
        allowNull: true,
      },
    },
    {
      tableName: 'carona_usuario',
      timestamps: false,
    },
  );

  CaronaUsuario.associate = (models) => {
    CaronaUsuario.belongsTo(models.Carona, { foreignKey: 'idCarona', as: 'carona' });
    CaronaUsuario.belongsTo(models.Usuario, {
      foreignKey: 'idPassageiro',
      as: 'passageiro',
    });
  };

  return CaronaUsuario;
};
