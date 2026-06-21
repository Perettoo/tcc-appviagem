'use strict';

module.exports = (sequelize, DataTypes) => {
  const Carro = sequelize.define(
    'Carro',
    {
      idCarro: {
        type: DataTypes.INTEGER,
        autoIncrement: true,
        primaryKey: true,
      },
      idUsuario: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      marca: {
        type: DataTypes.STRING(60),
        allowNull: false,
      },
      modelo: {
        type: DataTypes.STRING(60),
        allowNull: false,
      },
      anoFabricacao: {
        type: DataTypes.INTEGER,
        allowNull: false,
      },
      cor: {
        type: DataTypes.STRING(30),
        allowNull: false,
      },
      placa: {
        type: DataTypes.STRING(7),
        allowNull: false,
      },
      // Capacidade total (motorista incluso). Limite de passageiros = cap - 1.
      capacidade: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 5,
      },
      // Carro selecionado (atrelado a carona ao anunciar). No maximo um por
      // usuario; garantido no controller (selecionar zera os demais).
      ativo: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
      },
    },
    {
      tableName: 'carro',
      timestamps: false,
    },
  );

  Carro.associate = (models) => {
    Carro.belongsTo(models.Usuario, { foreignKey: 'idUsuario', as: 'dono' });
    Carro.hasMany(models.Carona, { foreignKey: 'idCarro', as: 'caronas' });
  };

  return Carro;
};
