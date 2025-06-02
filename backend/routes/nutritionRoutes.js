const express = require('express');
const router = express.Router();
const nutritionController = require('../controllers/nutritionController');

// Rutas para alergias
router.get('/alergias/:userId', nutritionController.getUserAllergies);
router.put('/alergias/:userId', nutritionController.updateUserAllergies);

// Rutas para condiciones médicas
router.get('/condiciones/:userId', nutritionController.getUserConditions);
router.put('/condiciones/:userId', nutritionController.updateUserConditions);

module.exports = router;
