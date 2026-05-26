'use strict';

module.exports = (sequelize, DataTypes) => {
  const GrupoUsuario = sequelize.define(
    'GrupoUsuario',
    {
      idGrupoUsuario: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idUsuario: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      idGrupo: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      isAdm: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    },
    {
      tableName: 'grupo_usuario',
      timestamps: false,
    },
  );

  GrupoUsuario.associate = (models) => {
    GrupoUsuario.belongsTo(models.Grupo, { foreignKey: 'idGrupo', as: 'grupo' });
    GrupoUsuario.belongsTo(models.Usuario, {
      foreignKey: 'idUsuario',
      as: 'usuario',
    });
  };

  return GrupoUsuario;
};
