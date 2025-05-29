// routes/recipeSearch.js
const express = require('express');
const router = express.Router();
const axios = require('axios'); // Für HTTP-Anfragen zu Spoonacular

// Sicherstellen, dass dein Spoonacular API Key in den Umgebungsvariablen ist
const SPOONACULAR_API_KEY = process.env.SPOONACULAR_API_KEY;
const SPOONACULAR_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';

router.post('/search', async (req, res) => {
    const { query, ingredients, filters, sortBy, sortDirection } = req.body;

    if (!SPOONACULAR_API_KEY) {
        console.error('SPOONACULAR_API_KEY is not set in environment variables.');
        return res.status(500).json({ message: 'Server configuration error.' });
    }

    try {
        const spoonacularParams = {
            apiKey: SPOONACULAR_API_KEY,
            query: query,
            // Umwandlung der Zutatenliste in einen kommaseparierten String
            // 'includeIngredients': ingredients ? ingredients.join(',') : undefined,
            // Besser für "has ingredients" anstatt "include in search term":
            // Spoonacular hat 'includeIngredients' für spezifische Zutaten und 'query' für allgemeine Suchbegriffe.
            // Wir nutzen 'query' für den Hauptsuchbegriff und 'includeIngredients' für die Filter-Zutaten.
            includeIngredients: ingredients && ingredients.length > 0 ? ingredients.join(',') : undefined,
            number: 10, // Anzahl der Ergebnisse pro Anfrage
            addRecipeInformation: true, // Wichtiger Parameter, um Details wie Image URL zu bekommen
            fillIngredients: true, // Um Ingredients-Details zu bekommen (ggf. optional)
            // Hinzufügen von Filtern basierend auf zukünftigen Anforderungen
            minCalories: filters?.minCalories,
            maxCalories: filters?.maxCalories,
            diet: filters?.diet, // z.B. "vegetarian", "vegan", "gluten free"
            intolerances: filters?.intolerances, // z.B. "gluten", "dairy"
            sort: sortBy, // z.B. "calories", "protein", "carbs"
            sortDirection: sortDirection, // "asc" oder "desc"
            // Füge weitere Spoonacular-Parameter nach Bedarf hinzu
        };

        // Entferne undefined-Werte, um sie nicht in die URL zu packen
        Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

        const response = await axios.get(SPOONACULAR_BASE_URL, {
            params: spoonacularParams
        });

        // Hier kannst du die Daten von Spoonacular anpassen, falls nötig
        // Zum Beispiel, um ein eigenes, schlankeres Rezept-Model zu erstellen
        const recipes = response.data.results.map(recipe => ({
            id: recipe.id,
            title: recipe.title,
            image: recipe.image,
            imageType: recipe.imageType,
            servings: recipe.servings,
            readyInMinutes: recipe.readyInMinutes,
            // Füge weitere relevante Felder hinzu
            // z.B. spoonacularScore, healthScore, dishTypes, diets, intolerances
            // nutrients: recipe.nutrition?.nutrients // Falls fillIngredients=true und es diese Daten gibt
        }));

        res.json(recipes);

    } catch (error) {
        console.error('Error searching recipes from Spoonacular:', error.message);
        // Spoonacular Fehler Details weitergeben
        if (error.response) {
            console.error('Spoonacular response data:', error.response.data);
            console.error('Spoonacular response status:', error.response.status);
            res.status(error.response.status).json({ message: 'Error from Spoonacular API', details: error.response.data });
        } else {
            res.status(500).json({ message: 'Failed to search recipes', error: error.message });
        }
    }
});

module.exports = router;