const express = require('express');
const router = express.Router();
const routineController = require('../controllers/routineController');

// Obtener todas las rutinas de un usuario
router.get('/user/:userId', routineController.getUserRoutines);

// Obtener detalles de una rutina específica
router.get('/:routineId', routineController.getRoutineDetail);

// Generar una rutina personalizada para un usuario
router.post('/generate/:userId', routineController.generateRoutine);

// Obtener todas las categorías de rutina
router.get('/categories/all', routineController.getCategories);

module.exports = router;
