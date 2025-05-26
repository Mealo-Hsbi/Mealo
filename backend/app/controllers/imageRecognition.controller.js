const imageRecognitionService = require('../services/imageRecognition.service');
const multer = require('multer');
const upload = multer();

exports.recognizeImages = async (req, res) => {
  upload.array('images')(req, res, async (err) => {
    if (err instanceof multer.MulterError) {
        // In case of a Multer error, we return a 400 status with the error message
        return res.status(400).json({ message: `File upload error: ${err.message}` });
    } else if (err) {
        // For any other error, we return a 500 status with the error message
        return res.status(500).json({ message: `An unknown error occurred during file upload: ${err.message}` });
    }

    if (!req.files || req.files.length === 0) {
      return res.status(400).json({ message: 'No image files uploaded.' });
    }

    try {
      const ingredients = await imageRecognitionService.processImages(req.files);

      res.status(200).json(ingredients);
    } catch (error) {
      console.error('Error in image recognition controller:', error);

      if (error.name === 'NoModelResponseError') { // Beispiel für einen benutzerdefinierten Fehler vom Service
        return res.status(500).json({ message: 'Image analysis service did not return a valid response.', error: error.message });
      }

      res.status(500).json({ message: 'Failed to process images.', error: error.message || error });
    }
  });
};