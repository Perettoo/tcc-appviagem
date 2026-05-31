'use strict';

const fs = require('fs');
const path = require('path');
const Sequelize = require('sequelize');
const process = require('process');
const env = process.env.NODE_ENV || 'development';
const config = require(path.resolve(__dirname, '..', 'config', 'config.js'))[env];
const db = {};

let sequelize;
if (config.use_env_variable) {
  sequelize = new Sequelize(process.env[config.use_env_variable], config);
} else {
  sequelize = new Sequelize(config.database, config.username, config.password, config);
}

// Coleta os arquivos de model recursivamente, para suportar models
// organizados em subpastas (ex: models/grupo/grupo.js).
function collectModelFiles(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((entry) => {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      return collectModelFiles(full);
    }
    const ehModelValido =
      entry.name.indexOf('.') !== 0 &&
      full !== __filename &&
      entry.name.slice(-3) === '.js' &&
      entry.name.indexOf('.test.js') === -1;
    return ehModelValido ? [full] : [];
  });
}

collectModelFiles(__dirname).forEach((file) => {
  const model = require(file)(sequelize, Sequelize.DataTypes);
  db[model.name] = model;
});

Object.keys(db).forEach(modelName => {
  if (db[modelName].associate) {
    db[modelName].associate(db);
  }
});

db.sequelize = sequelize;
db.Sequelize = Sequelize;

module.exports = db;
