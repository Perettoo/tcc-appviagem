'use strict';

const { Router } = require('express');
const caronaController = require('../../controllers/carona/carona_controller');
const authenticate = require('../../middlewares/authenticate');

const router = Router();

// Motorista anuncia uma carona no grupo.
router.post('/grupos/:idGrupo/caronas', authenticate, caronaController.anunciar);

router.get('/caronas', authenticate, caronaController.listar);
router.get('/caronas/:idCarona', authenticate, caronaController.detalhe);

// Passageiro pede para entrar / cancela o proprio pedido.
router.post('/caronas/:idCarona/pedir', authenticate, caronaController.pedir);
router.delete('/caronas/:idCarona/pedir', authenticate, caronaController.cancelarPedido);

// Motorista decide um pedido (aprovar/recusar).
router.patch(
  '/caronas/:idCarona/passageiros/:idPassageiro',
  authenticate,
  caronaController.decidir,
);

// Motorista conclui/cancela a carona.
router.patch('/caronas/:idCarona/concluir', authenticate, caronaController.concluir);
router.patch('/caronas/:idCarona/cancelar', authenticate, caronaController.cancelar);

module.exports = router;
