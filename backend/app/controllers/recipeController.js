// controllers/recipeController.js
const { searchSpoonacularRecipes, getSpoonacularRecipeDetails } = require('../services/spoonacularService');


const searchRecipes = async (req, res) => {
    // DIESER LOG MUSS ERSCHEINEN, WENN DIE ANFRAGE DIE CONTROLLER-FUNKTION ERREICHT!

    const { query, ingredients, offset, number, filters, sortBy, sortDirection } = req.body;

    try {
        const recipes = await searchSpoonacularRecipes({
            query,
            ingredients,
            offset,
            number,
            filters,
            sortBy,
            sortDirection
        });

        return res.json(recipes);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in controller:', error);
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
        const statusCode = error.response ? error.response.status : 500;
        const errorMessage = error.response && error.response.data ? error.response.data.message : 'Failed to fetch recipe details.';
        res.status(statusCode).json({ message: errorMessage });
    }
};

module.exports = {
    searchRecipes,
    getRecipeDetails, // NEU: Exportiere die Funktion
};