const express = require('express');
const router = express.Router();
const imageRecognitionController = require('../controllers/imageRecognition.controller'); // Importiere den Controller

// Der Pfad ist '/api/image-recognition'
router.post('/recognize', imageRecognitionController.recognizeImages);

module.exports = router;