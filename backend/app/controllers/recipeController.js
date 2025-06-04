// controllers/recipeController.js
const spoonacularService = require('../services/spoonacularService');

const searchRecipes = async (req, res) => {
    // DIESER LOG MUSS ERSCHEINEN, WENN DIE ANFRAGE DIE CONTROLLER-FUNKTION ERREICHT!

    const { query, ingredients, offset, number, filters, sortBy, sortDirection } = req.body;

    try {
        const recipes = await spoonacularService.searchSpoonacularRecipes({
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

module.exports = {
    searchRecipes,
};