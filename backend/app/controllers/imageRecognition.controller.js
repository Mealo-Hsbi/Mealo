// backend/app/controllers/imageRecognition.controller.js (UNVERÄNDERT – zur Referenz)
// ... (bestehende Imports für express, router, imageRecognitionController)
const multer = require('multer'); // Sicherstellen, dass multer importiert ist
const upload = multer({ storage: multer.memoryStorage() }); // Wichtig: Bilder im Speicher halten

const imageRecognitionService = require('../services/imageRecognition.service'); // Dein Service

exports.recognizeImages = async (req, res) => {
    // multer.array('images') erwartet, dass die Frontend-Anfrage ein Feld namens 'images' hat
    // und dieses Feld mehrere Dateien enthalten kann.
    upload.array('images')(req, res, async (err) => {
        if (err instanceof multer.MulterError) {
            return res.status(400).json({ message: `File upload error: ${err.message}` });
        } else if (err) {
            return res.status(500).json({ message: `An unknown error occurred during file upload: ${err.message}` });
        }

        if (!req.files || req.files.length === 0) {
            return res.status(400).json({ message: 'No image files uploaded.' });
        }

        try {
            // Hier werden die geparsten Dateiobjekte an den Service übergeben
            const ingredients = await imageRecognitionService.processImages(req.files);
            console.log('Recognized ingredients:', ingredients);
            res.status(200).json(ingredients);
        } catch (error) {
            console.error('Error in image recognition controller:', error);
            if (error.name === 'NoModelResponseError') {
                return res.status(500).json({ message: 'Image analysis service did not return a valid response.', error: error.message });
            }
            res.status(500).json({ message: 'Failed to process images.', error: error.message || error });
        }
    });
};