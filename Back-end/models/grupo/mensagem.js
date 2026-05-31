'use strict';

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
  };

  return Mensagem;
};
