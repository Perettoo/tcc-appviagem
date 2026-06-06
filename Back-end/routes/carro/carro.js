'use strict';

const { Router } = require('express');
const carroController = require('../../controllers/carro/carro_controller');
const authenticate = require('../../middlewares/authenticate');

const router = Router();

router.get('/carros', authenticate, carroController.listar);
router.post('/carros', authenticate, carroController.criar);
router.patch('/carros/:idCarro', authenticate, carroController.atualizar);
router.delete('/carros/:idCarro', authenticate, carroController.excluir);
router.patch('/carros/:idCarro/ativar', authenticate, carroController.ativar);

module.exports = router;
