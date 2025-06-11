// routes/recipeSearch.js
const express = require('express');
const auth = require('../middleware/auth.middleware');
const router = express.Router();
// Importiere die neuen, spezifischen Controller-Funktionen
const { getRecipesByQuery, getRecipesByIngredients, getRecipeDetails } = require('../controllers/recipeController');


// Route für die Textsuche (GET-Anfrage)
// Beispiel-URL: GET /api/recipes/search/query?query=pasta&number=10
router.get('/search/query', auth, getRecipesByQuery);

// Route für die Zutatensuche (GET-Anfrage)
// Beispiel-URL: GET /api/recipes/search/ingredients?ingredients=chicken,rice&maxMissingIngredients=2
router.get('/search/ingredients', auth, getRecipesByIngredients);

// Route für Rezeptdetails (bleibt unverändert)
// Beispiel-URL: GET /api/recipes/12345
router.get('/:id', auth, getRecipeDetails);

module.exports = router;