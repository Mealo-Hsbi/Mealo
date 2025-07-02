// app/routes/index.js
const express = require('express');
const router = express.Router();
const userRoutes = require('./user.routes');
const imageRecognitionRoutes = require('./imageRecognition.routes');
const visionRoutes = require('./vision.routes');
const recipeRoutes = require('./recipe.routes');
const profileRoutes = require('./profile.routes');
const mediaRoutes   = require('./media.routes');
const preferenceRoutes = require('./preference.routes');
const achievementRoutes = require('./achievement.route');
const mealplanRoutes = require('./mealplan.routes');

// Mount individual route files
router.use('/users', userRoutes);
router.use('/image-recognition', imageRecognitionRoutes);
router.use('/vision', visionRoutes);
router.use('/recipes', recipeRoutes);
router.use('/media', mediaRoutes);
router.use('/preferences', preferenceRoutes);
router.use(profileRoutes);
router.use('/achievements', achievementRoutes);
router.use('/mealplan', mealplanRoutes);

module.exports = router;