'use strict';

const { Router } = require('express');
const grupoController = require('../controllers/grupo_controller');
const authenticate = require('../middlewares/authenticate');

const router = Router();

router.post('/grupos', authenticate, grupoController.criar);
router.get('/grupos', authenticate, grupoController.listar);

module.exports = router;
