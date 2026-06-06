'use strict';

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
