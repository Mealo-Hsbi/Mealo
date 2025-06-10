// controllers/recipeController.js
const { searchRecipesByQuery, searchRecipesByIngredients, getSpoonacularRecipeDetails } = require('../services/spoonacularService');


const getRecipesByQuery = async (req, res) => {
    try {
        // Parameter für die Textsuche kommen aus req.query
        const { query, offset, number, sortBy, sortDirection } = req.query;
        const filters = {
            minCalories: req.query.minCalories,
            maxCalories: req.query.maxCalories,
            diet: req.query.diet,
            intolerances: req.query.intolerances,
        };

        const recipes = await searchRecipesByQuery({
            query,
            offset: parseInt(offset) || 0, // Standardwert 0, falls nicht gesetzt
            number: parseInt(number) || 10, // Standardwert 10, falls nicht gesetzt
            filters,
            sortBy,
            sortDirection,
        });

        return res.json(recipes);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getRecipesByQuery controller:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Internal server error';
        return res.status(statusCode).json({ message });
    }
};

const getRecipesByIngredients = async (req, res) => {
    try {
        // Parameter für die Zutatensuche kommen aus req.query
        const { ingredients, offset, number, maxMissingIngredients } = req.query;

        // Zutaten kommen als kommaseparierter String, hier als Array splitten
        // Nur splitten, wenn ingredients vorhanden ist, sonst bleibt es ein leeres Array
        const ingredientsArray = ingredients ? ingredients.split(',') : [];

        const recipes = await searchRecipesByIngredients({
            ingredients: ingredientsArray,
            offset: parseInt(offset) || 0, // Standardwert 0, falls nicht gesetzt
            number: parseInt(number) || 10, // Standardwert 10, falls nicht gesetzt
            // maxMissingIngredients als Zahl parsen. undefined, wenn nicht gesetzt, damit der Service-Standard greift.
            maxMissingIngredients: maxMissingIngredients !== undefined ? parseInt(maxMissingIngredients) : undefined,
        });

        return res.json(recipes);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getRecipesByIngredients controller:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Internal server error';
        return res.status(statusCode).json({ message });
    }
};

const getRecipeDetails = async (req, res) => {
    try {
        const { id } = req.params; // Die ID kommt aus der URL (z.B. /api/recipes/123)
        const recipeId = parseInt(id); // Sicherstellen, dass es eine Zahl ist

        if (isNaN(recipeId)) {
            return res.status(400).json({ message: 'Invalid recipe ID provided.' });
        }

        const recipeDetails = await getSpoonacularRecipeDetails(recipeId);

        if (!recipeDetails) {
            return res.status(404).json({ message: 'Recipe not found.' });
        }

        res.json(recipeDetails);
    } catch (error) {
        console.error('Error in getRecipeDetails controller:', error.message);
        // Anpassung der Fehlerantwort, um konsistent zu sein
        const statusCode = error.status || error.response?.status || 500;
        const errorMessage = error.message || error.response?.data?.message || 'Failed to fetch recipe details.';
        res.status(statusCode).json({ message: errorMessage });
    }
};

module.exports = {
    getRecipesByQuery,      // Exportiere die neue Funktion für Query-Suche
    getRecipesByIngredients, // Exportiere die neue Funktion für Zutatensuche
    getRecipeDetails,
};