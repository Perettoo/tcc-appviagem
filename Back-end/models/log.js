'use strict';

module.exports = (sequelize, DataTypes) => {
  const Log = sequelize.define(
    'Log',
    {
      idLog: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idUsuario: {
        type: DataTypes.INTEGER,
        allowNull: true,
        references: {
          model: 'usuario',
          key: 'idUsuario',
        },
        onUpdate: 'CASCADE',
        onDelete: 'SET NULL',
      },
      tabela: {
        type: DataTypes.STRING(60),
        allowNull: false,
      },
      metodo: {
        type: DataTypes.ENUM('get', 'post', 'put', 'delete'),
        allowNull: false,
      },
      status: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      mensagem: {
        type: DataTypes.TEXT,
        allowNull: true,
      },
      createdAt: {
        type: DataTypes.DATE,
        allowNull: false,
        defaultValue: DataTypes.NOW,
      },
    },
    {
      tableName: 'log',
      timestamps: true,
      updatedAt: false,
    },
  );

  Log.associate = (models) => {
    Log.belongsTo(models.Usuario, { foreignKey: 'idUsuario', as: 'usuario' });
  };

  return Log;
};
