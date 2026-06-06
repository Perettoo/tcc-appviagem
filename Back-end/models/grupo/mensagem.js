'use strict';

const security = require('../../config/security');

module.exports = (sequelize, DataTypes) => {
  const Mensagem = sequelize.define(
    'Mensagem',
    {
      idMensagem: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idGrupo: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      idUsuario: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      conteudo: {
        type: DataTypes.TEXT,
        allowNull: false,
      },
      // Texto comum ou pedido de carona (renderizado como card no app).
      tipo: {
        type: DataTypes.ENUM(...Object.values(security.MENSAGEM_TIPO)),
        allowNull: false,
        defaultValue: security.MENSAGEM_TIPO.TEXTO,
      },
      // Preenchido somente quando tipo = CARONA.
      idCarona: {
        type: DataTypes.INTEGER,
        allowNull: true,
      },
      dataEnvio: {
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
      tableName: 'mensagem',
      timestamps: false,
    },
  );

  Mensagem.associate = (models) => {
    Mensagem.belongsTo(models.Grupo, { foreignKey: 'idGrupo', as: 'grupo' });
    Mensagem.belongsTo(models.Usuario, { foreignKey: 'idUsuario', as: 'autor' });
    Mensagem.belongsTo(models.Carona, { foreignKey: 'idCarona', as: 'carona' });
  };

  return Mensagem;
};
