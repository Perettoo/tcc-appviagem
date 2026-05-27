'use strict';

module.exports = (sequelize, DataTypes) => {
  const Usuario = sequelize.define(
    'Usuario',
    {
      idUsuario: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      nome: {
        type: DataTypes.STRING(120),
        allowNull: false,
        unique: true,
      },
      email: {
        type: DataTypes.STRING(180),
        allowNull: false,
        unique: true,
        validate: { isEmail: true },
      },
      senhaHash: {
        type: DataTypes.STRING(60),
        allowNull: false,
      },
      dataNascimento: {
        type: DataTypes.DATEONLY,
        allowNull: false,
      },
      dataCadastro: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
      dataInativacao: {
        type: DataTypes.DATE,
        allowNull: true,
      },
      cpf: {
        type: DataTypes.STRING(11),
        allowNull: false,
        unique: true,
      },
      tipo: {
        type: DataTypes.ENUM('motorista', 'passageiro', 'ambos'),
        allowNull: false,
      },
      ativo: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: true,
      },
    },
    {
      tableName: 'usuario',
      timestamps: false,
    },
  );

  Usuario.associate = (models) => {
    Usuario.hasMany(models.Log, { foreignKey: 'idUsuario', as: 'logs' });
  };

  return Usuario;
};
