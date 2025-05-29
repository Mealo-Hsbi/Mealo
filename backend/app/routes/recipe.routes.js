// routes/recipeSearch.js
const express = require('express');
const router = express.Router();
const axios = require('axios'); // Für HTTP-Anfragen zu Spoonacular
const { spoonacularKeys } = require('../config/apiKeys'); // Wichtig: Stelle sicher, dass dies der korrekte Pfad zu deinem Array mit Keys ist.

// const SPOONACULAR_API_KEY = process.env.SPOONACULAR_API_KEY; // Diese Zeile kann entfernt werden, da wir spoonacularKeys verwenden
const SPOONACULAR_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';

let currentKeyIndex = 0; // Index für den aktuell verwendeten API-Key

router.post('/search', async (req, res) => {
    const { query, ingredients, filters, sortBy, sortDirection } = req.body;

    // Überprüfen, ob überhaupt Keys vorhanden sind
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        console.error('No Spoonacular API keys found in config/apiKeys.js.');
        return res.status(500).json({ message: 'Server configuration error: API keys are missing.' });
    }

    let retries = 0;
    const maxRetries = spoonacularKeys.length; // Max. Versuche: so viele wie Keys vorhanden sind

    while (retries < maxRetries) {
        // Sicherstellen, dass der currentKeyIndex im gültigen Bereich bleibt
        currentKeyIndex = currentKeyIndex % spoonacularKeys.length;
        const currentKey = spoonacularKeys[currentKeyIndex];

        try {
            const spoonacularParams = {
                apiKey: currentKey, // Verwende den aktuell ausgewählten Key
                query: query,
                includeIngredients: ingredients && ingredients.length > 0 ? ingredients.join(',') : undefined,
                number: 10,
                addRecipeInformation: true,
                fillIngredients: true,
                minCalories: filters?.minCalories,
                maxCalories: filters?.maxCalories,
                diet: filters?.diet,
                intolerances: filters?.intolerances,
                sort: sortBy,
                sortDirection: sortDirection,
            };

            // Entferne undefined-Werte
            Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

            const response = await axios.get(SPOONACULAR_BASE_URL, {
                params: spoonacularParams
            });

            const recipes = response.data.results.map(recipe => ({
                id: recipe.id,
                title: recipe.title,
                image: recipe.image,
                imageType: recipe.imageType,
                servings: recipe.servings,
                readyInMinutes: recipe.readyInMinutes,
            }));

            return res.json(recipes); // Erfolgreiche Antwort, beende die Funktion hier

        } catch (error) {
            console.error(`Error searching recipes with key ${currentKey}:`, error.message);

            if (error.response && (error.response.status === 402 || error.response.status === 429)) {
                // Key-Quota erschöpft oder Rate Limit erreicht
                console.warn(`Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`);
                currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length; // Zum nächsten Key wechseln
                retries++; // Versuchszähler erhöhen
            } else {
                // Bei anderen Fehlern (z.B. Netzwerk, ungültiger Request) nicht den Key wechseln
                console.error('Non-quota related Spoonacular API error:', error.message);
                const statusCode = error.response ? error.response.status : 500;
                const errorMessage = error.response ? error.response.data : { message: 'Failed to search recipes', error: error.message };
                return res.status(statusCode).json(errorMessage); // Fehler zurückgeben und Funktion beenden
            }
        }
    }

    // Wenn alle Keys versucht wurden und keiner funktioniert hat
    console.error('All Spoonacular API keys attempted and failed for this request.');
    return res.status(503).json({ message: 'All Spoonacular API keys are currently unavailable or exhausted.' });
});

module.exports = router;