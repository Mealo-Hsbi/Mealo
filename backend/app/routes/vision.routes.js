// backend/app/routes/vision.routes.js
const express = require('express');
const path    = require('path');
const { detectIngredients } = require('../services/vision.service');
const router = express.Router();

// GET /test
// Lädt test.png aus diesem Verzeichnis und gibt das Ergebnis zurück.
router.get('/test', async (req, res, next) => {
  try {
    // __dirname zeigt auf backend/app/routes
    const imgPath = path.join(__dirname, 'test.jpg');
    const result  = await detectIngredients(imgPath);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

module.exports = router;
