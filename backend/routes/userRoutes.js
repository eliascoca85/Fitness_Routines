const express = require('express');
const router = express.Router();
const userController = require('../controllers/userController');

// Ruta de login
router.post('/login', userController.login);

// Ruta de registro
router.post('/register', userController.register);

module.exports = router;