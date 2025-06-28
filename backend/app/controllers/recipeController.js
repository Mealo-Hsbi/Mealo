// controllers/recipeController.js
const { searchRecipesByQuery, searchRecipesByIngredients, getSpoonacularRecipeDetails } = require('../services/spoonacularService');
const recipeManagementService = require('../services/recipeManagementService');

const getRecipesByQuery = async (req, res) => {
    try {
        const { query, offset, number, sortBy, sortDirection } = req.query;
        const filters = {
            minCalories: req.query.minCalories,
            maxCalories: req.query.maxCalories,
            diet: req.query.diet,
            intolerances: req.query.intolerances,
        };

        const recipes = await searchRecipesByQuery({
            query,
            offset: parseInt(offset) || 0,
            number: parseInt(number) || 10,
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
        const { ingredients, offset, number, maxMissingIngredients } = req.query;
        const ingredientsArray = ingredients ? ingredients.split(',') : [];

        const recipes = await searchRecipesByIngredients({
            ingredients: ingredientsArray,
            offset: parseInt(offset) || 0,
            number: parseInt(number) || 10,
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
        const { id } = req.params; // Die ID kommt aus der URL (Spoonacular ID)
        const spoonacularId = parseInt(id); // Sicherstellen, dass es eine Zahl ist

        console.log(`[DEBUG - CONTROLLER] Incoming request for recipe details. Spoonacular ID param: ${id}, parsed: ${spoonacularId}`);

        if (isNaN(spoonacularId)) {
            console.warn('[BACKEND DEBUG - CONTROLLER] Invalid Spoonacular ID provided:', id);
            return res.status(400).json({ message: 'Invalid Spoonacular recipe ID provided.' });
        }

        // 1. Spoonacular Rezeptdetails abrufen
        const recipeDetails = await getSpoonacularRecipeDetails(spoonacularId);

        if (!recipeDetails) {
            console.warn('[BACKEND DEBUG - CONTROLLER] Recipe not found from Spoonacular for ID:', spoonacularId);
            return res.status(404).json({ message: 'Recipe not found from Spoonacular.' });
        }
        console.log('[DEBUG - CONTROLLER] Spoonacular recipe details fetched successfully.');
        // console.log('[DEBUG - CONTROLLER] Spoonacular recipeDetails:', JSON.stringify(recipeDetails, null, 2));


        // 2. userId aus der Authentifizierung holen (wenn vorhanden)
        const userId = req.user?.id; // Optionaler Chaining Operator für den Fall, dass req.user nicht existiert
        console.log('[DEBUG - CONTROLLER] User ID from authentication middleware (req.user?.id):', userId);

        let userRating = null;
        let averageRating = null;
        let ratingCount = 0;
        let internalRecipeId = null; // Für die interne ID des Rezepts in unserer DB

        // Dieser Block versucht, interne DB-Daten zu holen, wenn die Spoonacular-Details vorhanden sind
        // oder ein userId vorhanden ist (falls wir ein Rezept ohne Spoonacular-ID speichern wollten,
        // was hier aber nicht der Fall ist, da wir immer von Spoonacular-ID ausgehen)
        try {
            console.log('[DEBUG - CONTROLLER] Preparing data for getOrCreateRecipeInDb...');
            // Stelle sicher, dass recipeDetails.properties korrekt behandelt werden,
            // um an getOrCreateRecipeInDb übergeben zu werden, das die snake_case-Konvertierung
            // für Prisma vornimmt und nullable/default Werte handhabt.
            const recipeDataForDbUpsert = {
                title: recipeDetails.title,
                imageUrl: recipeDetails.imageUrl,
                servings: recipeDetails.servings,
                readyInMinutes: recipeDetails.readyInMinutes,
                isVegetarian: recipeDetails.vegetarian, // Mapping von Spoonacular zu unserem 'isVegetarian'
                isVegan: recipeDetails.vegan,
                isGlutenFree: recipeDetails.glutenFree,
                isDairyFree: recipeDetails.dairyFree,
                dishTypes: recipeDetails.dishTypes || [], // Sicherstellen, dass es ein Array ist
                summary: recipeDetails.summary,
                healthScore: recipeDetails.healthScore,
                // Füge hier weitere relevante Felder hinzu, die in deine Recipe-Tabelle passen
                // und die von Spoonacular verfügbar sind.
            };

            console.log('[DEBUG - CONTROLLER] Calling recipeManagementService.getOrCreateRecipeInDb with Spoonacular ID:', spoonacularId);
            console.log('[DEBUG - CONTROLLER] Data passed to getOrCreateRecipeInDb:', JSON.stringify(recipeDataForDbUpsert, null, 2));

            const internalRecipe = await recipeManagementService.getOrCreateRecipeInDb(
                spoonacularId,
                recipeDataForDbUpsert
            );

            // Crucial check: Was ist internalRecipe nach dem Aufruf?
            console.log('[DEBUG - CONTROLLER] Result from recipeManagementService.getOrCreateRecipeInDb:', JSON.stringify(internalRecipe, null, 2));

            // Optional Chaining, um Fehler zu vermeiden, falls internalRecipe null oder undefined ist
            internalRecipeId = internalRecipe?.id;

            console.log('[DEBUG - CONTROLLER] Derived internalRecipeId for DB operations:', internalRecipeId);


            // 4. Benutzerbewertung abrufen, falls angemeldet UND interne Rezept-ID vorhanden
            if (userId && internalRecipeId) {
                console.log(`[DEBUG - CONTROLLER] Attempting to fetch user rating for userId: ${userId}, internalRecipeId: ${internalRecipeId}`);
                userRating = await recipeManagementService.getUserRecipeRating(userId, internalRecipeId);
                console.log('[DEBUG - CONTROLLER] User rating fetched:', JSON.stringify(userRating, null, 2));
            } else {
                console.log(`[DEBUG - CONTROLLER] Skipping user rating fetch. userId: ${userId}, internalRecipeId: ${internalRecipeId}`);
            }

            // 5. Durchschnittliche Bewertung und Anzahl abrufen, falls interne Rezept-ID vorhanden
            if (internalRecipeId) {
                console.log(`[DEBUG - CONTROLLER] Attempting to fetch average rating for internalRecipeId: ${internalRecipeId}`);
                const avgData = await recipeManagementService.getAverageRecipeRating(internalRecipeId);
                averageRating = avgData.averageRating;
                ratingCount = avgData.ratingCount;
                console.log('[DEBUG - CONTROLLER] Average rating data fetched:', JSON.stringify(avgData, null, 2));
            } else {
                console.log(`[DEBUG - CONTROLLER] Skipping average rating fetch. internalRecipeId: ${internalRecipeId}`);
            }

        } catch (dbError) {
            console.error('[BACKEND DEBUG - CONTROLLER] ERROR in DB operations (getOrCreateRecipeInDb, getUserRecipeRating, getAverageRecipeRating):', dbError);
            // Re-throw the error if it's critical, otherwise just log and proceed with default null/0 values.
            // For now, we log and proceed to prevent breaking the entire request.
        }

        // 6. Alle Informationen zusammenführen und senden
        const fullRecipeDetails = {
            ...recipeDetails, // Spoonacular Details
            userRating: userRating, // Eigene Bewertung des Nutzers (oder null)
            averageRating: averageRating, // Durchschnittliche Bewertung (oder null)
            ratingCount: ratingCount, // Anzahl der Bewertungen (oder 0)
            internalRecipeId: internalRecipeId, // Die interne ID, falls Frontend sie benötigt
        };

        console.log('[DEBUG - CONTROLLER] Final response data being sent to frontend:', JSON.stringify(fullRecipeDetails, null, 2));

        return res.json(fullRecipeDetails);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] UNEXPECTED GLOBAL ERROR in getRecipeDetails controller:', error);
        // Anpassung der Fehlerantwort, um konsistent zu sein
        const statusCode = error.status || error.response?.status || 500;
        const errorMessage = error.message || error.response?.data?.message || 'Failed to fetch recipe details.';
        return res.status(statusCode).json({ message: errorMessage });
    }
};

const addFavoriteRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { spoonacularId, recipeData } = req.body;

        if (!userId || !spoonacularId || !recipeData) {
            return res.status(400).json({ message: 'Missing user ID, Spoonacular ID or recipe data.' });
        }
        
        const favorite = await recipeManagementService.addFavoriteRecipe(userId, spoonacularId, recipeData);
        return res.status(201).json(favorite);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in addFavoriteRecipe:', error);
        if (error.code === 'P2002') {
            return res.status(409).json({ message: 'Recipe already favorited by this user.' });
        }
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to add favorite recipe.';
        return res.status(statusCode).json({ message });
    }
};

const removeFavoriteRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { recipeId } = req.params;

        if (!userId || !recipeId) {
            return res.status(400).json({ message: 'Missing user ID or recipe ID.' });
        }

        await recipeManagementService.removeFavoriteRecipe(userId, recipeId);
        return res.status(204).send();

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in removeFavoriteRecipe:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to remove favorite recipe.';
        return res.status(statusCode).json({ message });
    }
};

const getFavoriteRecipes = async (req, res) => {
    try {
        const userId = req.user.id;

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

const getRecipeIsFavorited = async (req, res) => {
    try {
        const userId = req.user.id;
        const { recipeId } = req.params;

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
    console.log('[DEBUG - CONTROLLER] Received rating request body:', req.body);

    try {
        const userId = req.user.id;
        const { spoonacularId, rating, comment, recipeData } = req.body;

        if (!userId || !spoonacularId || typeof rating !== 'number' || rating < 1 || rating > 5 || !recipeData) {
            return res.status(400).json({ message: 'Missing user ID, Spoonacular ID, valid rating (1-5), or recipe data.' });
        }

        // Rufe den Service auf, der jetzt die aggregierten Daten zurückgibt
        const { userRating, averageRating, ratingCount } = await recipeManagementService.addOrUpdateRecipeRating(
            userId,
            spoonacularId,
            rating,
            recipeData,
            comment // Kommentar übergeben
        );

        // Sende die spezifische Nutzerbewertung und die aggregierten Werte im Response
        return res.status(200).json({
            userRating: userRating,
            averageRating: averageRating,
            ratingCount: ratingCount,
        });

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in addOrUpdateRecipeRating:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to add or update recipe rating.';
        return res.status(statusCode).json({ message });
    }
};

const getUserRecipeRating = async (req, res) => {
    try {
        const userId = req.user.id;
        const { recipeId } = req.params;

        if (!userId || !recipeId) {
            return res.status(400).json({ message: 'Missing user ID or recipe ID.' });
        }

        const userRating = await recipeManagementService.getUserRecipeRating(userId, recipeId);
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
    addFavoriteRecipe,
    removeFavoriteRecipe,
    getFavoriteRecipes,
    getRecipeIsFavorited,
    addOrUpdateRecipeRating,
    getUserRecipeRating,
};
