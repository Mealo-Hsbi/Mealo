// app/routes/index.js
const express = require('express');
const router = express.Router();

const userRoutes = require('./user.routes');
const imageRecognitionRoutes = require('./imageRecognition.routes');
const visionRoutes = require('./vision.routes');
const recipeRoutes = require('./recipe.routes');

// Mount individual route files
router.use('/users', userRoutes);
router.use('/image-recognition', imageRecognitionRoutes);
router.use('/vision', visionRoutes);
router.use('/recipes', recipeRoutes);

module.exports = router;