const express = require('express');
const router = express.Router();
const mealplanController = require('../controllers/mealplan.controller');
const authMiddleware = require('../middleware/auth.middleware');

router.use(authMiddleware);

// Get current mealplan for the logged-in user (current week)
router.get('/current', mealplanController.getCurrentMealplan);

// Update (replace) current mealplan for the logged-in user
router.put('/current', mealplanController.updateCurrentMealplan);

// Generate mealplan using Spoonacular API
router.post('/generate', mealplanController.generateMealplan);

module.exports = router; 