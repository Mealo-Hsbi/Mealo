// controllers/recipeController.js
const spoonacularService = require('../services/spoonacularService'); // Import the new service

const searchRecipes = async (req, res) => {
    const { query, ingredients, offset, number, filters, sortBy, sortDirection } = req.body;

    try {
        // Delegate the actual API call and processing to the service
        const recipes = await spoonacularService.searchSpoonacularRecipes({
            query,
            ingredients,
            offset,
            number,
            filters,
            sortBy,
            sortDirection
        });

        return res.json(recipes); // Send the successful response

    } catch (error) {
        // Catch errors thrown by the service and send appropriate HTTP responses
        console.error('Error in recipeController.searchRecipes:', error.message || error);
        const statusCode = error.status || 500; // Use status from service error if available, else 500
        const message = error.message || 'Internal server error';
        return res.status(statusCode).json({ message });
    }
};

module.exports = {
    searchRecipes,
};