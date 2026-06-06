'use strict';

const { Router } = require('express');
const usuarioController = require('../controllers/usuario_controller');
const authenticate = require('../middlewares/authenticate');

const router = Router();

router.get('/usuarios', authenticate, usuarioController.buscar);
router.post('/usuarios', usuarioController.registrar);
router.patch('/usuarios/me', authenticate, usuarioController.atualizarMe);

module.exports = router;
