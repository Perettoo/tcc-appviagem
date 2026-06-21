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
      // Quem anunciou a carona (o motorista). Nullable: SET NULL se o usuario
      // for removido, preservando o historico.
      idMotorista: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      // Carro ativo do motorista no momento do anuncio.
      idCarro: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      // Destino/observacao do anuncio (ex.: "Saindo para a faculdade").
      destino: {
        type: DataTypes.STRING(120),
        allowNull: true,
      },
      status: {
        type: DataTypes.ENUM(...Object.values(security.CARONA_STATUS)),
        allowNull: false,
        defaultValue: security.CARONA_STATUS.ABERTA,
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
    Carona.belongsTo(models.Carro, { foreignKey: 'idCarro', as: 'carro' });
    Carona.hasMany(models.CaronaUsuario, { foreignKey: 'idCarona', as: 'passageiros' });
    Carona.hasMany(models.Mensagem, { foreignKey: 'idCarona', as: 'mensagens' });
  };

  return Carona;
};
