'use strict';

const { Router } = require('express');
const authController = require('../controllers/auth_controller');
const authenticate = require('../middlewares/authenticate');

const router = Router();

router.post('/auth/login', authController.login);
router.get('/auth/me', authenticate, authController.me);

module.exports = router;
