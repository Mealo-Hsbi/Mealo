// routes/recipeSearch.js
const express = require('express');
const auth = require('../middleware/auth.middleware'); // <-- Authentifizierungs-Middleware
const router = express.Router();

// Importiere alle relevanten Controller-Funktionen, auch die neuen
const {
    getRecipesByQuery,
    getRecipesByIngredients,
    getRecipeDetails,
    addFavoriteRecipe,         // NEU: Controller für Favoriten hinzufügen
    removeFavoriteRecipe,      // NEU: Controller für Favoriten entfernen
    getFavoriteRecipes,        // NEU: Controller für Favoriten abrufen
    getRecipeIsFavorited,      // NEU: Controller für Favoritenstatus prüfen
    addOrUpdateRecipeRating,   // NEU: Controller für Bewertungen hinzufügen/aktualisieren
    getUserRecipeRating,       // NEU: Controller für Bewertungen abrufen
} = require('../controllers/recipeController');


// Route zum Abrufen aller Favoriten eines Benutzers
// Methode: GET
// URL: /api/recipes/favorites
// Benötigt: Authentifizierung (userId)
router.get('/favorites', auth, getFavoriteRecipes);

// Route zum Abrufen des Favoritenstatus eines spezifischen Rezepts für den aktuellen Benutzer
// Methode: GET
// URL: /api/recipes/:recipeId/isFavorited
// Benötigt: Authentifizierung (userId), in Params: recipeId (Ihre interne DB-UUID des Rezepts)
router.get('/:recipeId/isFavorited', auth, getRecipeIsFavorited);

// Route zum Abrufen der Bewertung eines spezifischen Rezepts durch den aktuellen Benutzer
// Methode: GET
// URL: /api/recipes/:recipeId/rating
// Benötigt: Authentifizierung (userId), in Params: recipeId (Ihre interne DB-UUID des Rezepts)
router.get('/:recipeId/rating', auth, getUserRecipeRating);

// Route für die Textsuche (GET-Anfrage)
// Beispiel-URL: GET /api/recipes/search/query?query=pasta&number=10
router.get('/search/query', auth, getRecipesByQuery);

// Route für die Zutatensuche (GET-Anfrage)
// Beispiel-URL: GET /api/recipes/search/ingredients?ingredients=chicken,rice&maxMissingIngredients=2
router.get('/search/ingredients', auth, getRecipesByIngredients);

// Route für Rezeptdetails (bleibt unverändert)
// Beispiel-URL: GET /api/recipes/12345 (hier ist es die Spoonacular ID)
router.get('/:id', auth, getRecipeDetails);

// Route zum Hinzufügen oder Aktualisieren einer Bewertung für ein Rezept
// Methode: POST (oder PUT, beides ist üblich für Upsert-Operationen)
// URL: /api/recipes/ratings
// Benötigt: Authentifizierung (userId), im Body: spoonacularId, rating (Score), recipeData
router.post('/ratings', auth, addOrUpdateRecipeRating);

// Route zum Hinzufügen eines Rezepts zu den Favoriten
// Methode: POST
// URL: /api/recipes/favorites
// Benötigt: Authentifizierung (userId), im Body: spoonacularId, recipeData (Grundinfos des Rezepts)
router.post('/favorites', auth, addFavoriteRecipe);

// Route zum Entfernen eines Rezepts aus den Favoriten
// Methode: DELETE
// URL: /api/recipes/favorites/:recipeId
// Benötigt: Authentifizierung (userId), in Params: recipeId (Ihre interne DB-UUID des Rezepts)
router.delete('/favorites/:favoriteId', auth, removeFavoriteRecipe);

module.exports = router;