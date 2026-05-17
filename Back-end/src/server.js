require('dotenv').config();

const express = require('express');
const cors = require('cors');

const { sequelize } = require('./config/database');
const healthRoutes = require('./presentation/routes/health');

const app = express();

app.use(cors());
app.use(express.json());

app.use(healthRoutes);

const port = Number(process.env.PORT) || 3000;

sequelize.authenticate()
  .then(() => {
    console.log(`Banco conectado: ${process.env.DB_NAME}`);
    app.listen(port, () => {
      console.log(`API rodando em http://localhost:${port}`);
    });
  })
  .catch((err) => {
    console.error('Falha ao conectar no banco:', err.message);
    process.exit(1);
  });
