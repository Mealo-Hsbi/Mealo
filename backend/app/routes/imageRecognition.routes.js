const express = require('express');
const auth = require('../middleware/auth.middleware');
const router = express.Router();
const imageRecognitionController = require('../controllers/imageRecognition.controller'); // Importiere den Controller

// Der Pfad ist '/api/image-recognition'
router.post('/recognize', auth, imageRecognitionController.recognizeImages);

module.exports = router;