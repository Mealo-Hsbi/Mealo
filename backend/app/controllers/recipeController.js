// controllers/recipeController.js
const { searchRecipesByQuery, searchRecipesByIngredients, getSpoonacularRecipeDetails } = require('../services/spoonacularService');
const recipeManagementService = require('../services/recipeManagementService');

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

const addFavoriteRecipe = async (req, res) => {
    try {
        const userId = req.user.id; // ANNAHME: User-ID kommt von der Authentifizierung Middleware
        const { spoonacularId, recipeData } = req.body; // recipeData sind die Grundinfos vom Frontend

        if (!userId || !spoonacularId || !recipeData) {
            return res.status(400).json({ message: 'Missing user ID, Spoonacular ID or recipe data.' });
        }
        
        // Stellen Sie sicher, dass recipeData alle benötigten Felder für das Recipe-Modell enthält
        const favorite = await recipeManagementService.addFavoriteRecipe(userId, spoonacularId, recipeData);
        return res.status(201).json(favorite); // 201 Created ist Standard für neue Ressourcen

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in addFavoriteRecipe:', error);
        // Anpassung der Fehlerantwort: Wenn der unique-Constraint verletzt wird (bereits favorisiert)
        if (error.code === 'P2002') { // Prisma unique constraint violation error code
            return res.status(409).json({ message: 'Recipe already favorited by this user.' });
        }
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to add favorite recipe.';
        return res.status(statusCode).json({ message });
    }
};

const removeFavoriteRecipe = async (req, res) => {
    try {
        const userId = req.user.id; // ANNAHME: User-ID kommt von der Authentifizierung Middleware
        const { recipeId } = req.params; // recipeId ist die UUID des Rezepts aus IHRER DB

        if (!userId || !recipeId) {
            return res.status(400).json({ message: 'Missing user ID or recipe ID.' });
        }

        await recipeManagementService.removeFavoriteRecipe(userId, recipeId);
        return res.status(204).send(); // 204 No Content ist Standard für erfolgreiches Löschen

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in removeFavoriteRecipe:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to remove favorite recipe.';
        return res.status(statusCode).json({ message });
    }
};

const getFavoriteRecipes = async (req, res) => {
    try {
        const userId = req.user.id; // ANNAHME: User-ID kommt von der Authentifizierung Middleware

        if (!userId) {
            return res.status(400).json({ message: 'Missing user ID.' });
        }

        const favoriteRecipes = await recipeManagementService.getFavoriteRecipesForUser(userId);
        return res.status(200).json(favoriteRecipes);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getFavoriteRecipes:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to retrieve favorite recipes.';
        return res.status(statusCode).json({ message });
    }
};

// Diese Funktion ist nützlich, um den Favoritenstatus eines bestimmten Rezepts für den aktuellen Benutzer zu überprüfen
const getRecipeIsFavorited = async (req, res) => {
    try {
        const userId = req.user.id; // ANNAHME: User-ID kommt von der Authentifizierung Middleware
        const { recipeId } = req.params; // recipeId ist die UUID des Rezepts aus IHRER DB

        if (!userId || !recipeId) {
            return res.status(400).json({ message: 'Missing user ID or recipe ID.' });
        }

        const isFavorited = await recipeManagementService.isRecipeFavoritedByUser(userId, recipeId);
        return res.status(200).json({ isFavorited });

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getRecipeIsFavorited:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to check favorite status.';
        return res.status(statusCode).json({ message });
    }
};


const addOrUpdateRecipeRating = async (req, res) => {
    try {
        const userId = req.user.id; // ANNAHME: User-ID kommt von der Authentifizierung Middleware
        const { spoonacularId, rating, recipeData } = req.body; // rating ist der Score, recipeData die Grundinfos

        if (!userId || !spoonacularId || typeof rating !== 'number' || rating < 1 || rating > 5 || !recipeData) {
            return res.status(400).json({ message: 'Missing user ID, Spoonacular ID, valid rating (1-5), or recipe data.' });
        }

        const recipeRating = await recipeManagementService.addOrUpdateRecipeRating(userId, spoonacularId, rating, recipeData);
        return res.status(200).json(recipeRating); // 200 OK für Erstellung oder Update

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in addOrUpdateRecipeRating:', error);
        // Bei einem Fehler beim Upsert (z.B. Datenbankproblem)
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to add or update recipe rating.';
        return res.status(statusCode).json({ message });
    }
};

const getUserRecipeRating = async (req, res) => {
    try {
        const userId = req.user.id; // ANNAHME: User-ID kommt von der Authentifizierung Middleware
        const { recipeId } = req.params; // recipeId ist die UUID des Rezepts aus IHRER DB

        if (!userId || !recipeId) {
            return res.status(400).json({ message: 'Missing user ID or recipe ID.' });
        }

        const userRating = await recipeManagementService.getUserRecipeRating(userId, recipeId);
        // Wenn keine Bewertung gefunden, wird userRating null sein.
        // Frontend kann dann prüfen und entsprechend "nicht bewertet" anzeigen.
        return res.status(200).json(userRating);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getUserRecipeRating:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to retrieve user recipe rating.';
        return res.status(statusCode).json({ message });
    }
};

module.exports = {
    getRecipesByQuery,
    getRecipesByIngredients,
    getRecipeDetails,
    addFavoriteRecipe,       // NEU
    removeFavoriteRecipe,    // NEU
    getFavoriteRecipes,      // NEU
    getRecipeIsFavorited,    // NEU
    addOrUpdateRecipeRating, // NEU
    getUserRecipeRating,     // NEU
};