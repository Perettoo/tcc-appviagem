'use strict';

const { Router } = require('express');
const caronaController = require('../../controllers/carona/carona_controller');
const authenticate = require('../../middlewares/authenticate');

const router = Router();

router.post('/grupos/:idGrupo/caronas', authenticate, caronaController.solicitar);
router.get('/caronas', authenticate, caronaController.listar);
router.get('/caronas/:idCarona', authenticate, caronaController.detalhe);
router.patch('/caronas/:idCarona/aceitar', authenticate, caronaController.aceitar);
router.patch('/caronas/:idCarona/concluir', authenticate, caronaController.concluir);
router.patch('/caronas/:idCarona/cancelar', authenticate, caronaController.cancelar);

module.exports = router;
