require('dotenv').config();

const express = require('express');
const cors = require('cors');

const healthRoutes = require('./presentation/routes/health');

const app = express();

app.use(cors());
app.use(express.json());

app.use(healthRoutes);

const port = Number(process.env.PORT) || 3000;
app.listen(port, () => {
  console.log(`API rodando em http://localhost:${port}`);
});
