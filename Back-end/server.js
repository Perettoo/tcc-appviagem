require('dotenv').config();

const http = require('http');
const express = require('express');
const cors = require('cors');

const { sequelize } = require('./config/database');
const { initSocket } = require('./realtime/socket_server');
const healthRoutes = require('./routes/health');
const usuarioRoutes = require('./routes/usuario');
const authRoutes = require('./routes/auth');
const grupoRoutes = require('./routes/grupo/grupo');
const caronaRoutes = require('./routes/carona/carona');
const carroRoutes = require('./routes/carro/carro');

const app = express();

app.use(cors());
app.use(express.json());

app.use(healthRoutes);
app.use(usuarioRoutes);
app.use(authRoutes);
app.use(grupoRoutes);
app.use(caronaRoutes);
app.use(carroRoutes);

// Servidor HTTP compartilhado entre Express e Socket.IO.
const httpServer = http.createServer(app);
const io = initSocket(httpServer);
// Disponibiliza o io para os controllers (ex: broadcast de mensagem nova).
app.set('io', io);

const port = Number(process.env.PORT) || 3000;

sequelize.authenticate()
  .then(() => {
    console.log(`Banco conectado: ${process.env.DB_NAME}`);
    httpServer.listen(port, () => {
      console.log(`API rodando em http://localhost:${port}`);
    });
  })
  .catch((err) => {
    console.error('Falha ao conectar no banco:', err.message);
    process.exit(1);
  });
