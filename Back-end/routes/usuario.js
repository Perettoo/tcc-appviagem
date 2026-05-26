'use strict';

const { Router } = require('express');
const usuarioController = require('../controllers/usuario_controller');

const router = Router();

router.post('/usuarios', usuarioController.registrar);

module.exports = router;
