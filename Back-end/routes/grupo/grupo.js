'use strict';

const { Router } = require('express');
const grupoController = require('../../controllers/grupo/grupo_controller');
const mensagemController = require('../../controllers/grupo/mensagem_controller');
const authenticate = require('../../middlewares/authenticate');

const router = Router();

router.post('/grupos', authenticate, grupoController.criar);
router.get('/grupos', authenticate, grupoController.listar);
router.get('/grupos/:idGrupo/membros', authenticate, grupoController.listarMembros);
router.post('/grupos/:idGrupo/membros', authenticate, grupoController.adicionarMembro);
router.get('/grupos/:idGrupo/mensagens', authenticate, mensagemController.listar);
router.post('/grupos/:idGrupo/mensagens', authenticate, mensagemController.enviar);

module.exports = router;
