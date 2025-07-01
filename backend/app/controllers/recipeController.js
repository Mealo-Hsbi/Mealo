// controllers/recipeController.js
const { searchRecipesByQuery, searchRecipesByIngredients, getSpoonacularRecipeDetails } = require('../services/spoonacularService');
const recipeManagementService = require('../services/recipeManagementService');
const prisma = require('../prisma');
const mediaService = require('../services/media.service');

const getRecipesByQuery = async (req, res) => {
    try {
        const { query, offset, number, sortBy, sortDirection } = req.query;
        const filters = {
            minCalories: req.query.minCalories,
            maxCalories: req.query.maxCalories,
            diet: req.query.diet,
            intolerances: req.query.intolerances,
        };

        const userId = req.user?.id;

        const recipes = await searchRecipesByQuery({
            query,
            offset: parseInt(offset) || 0,
            number: parseInt(number) || 10,
            filters,
            sortBy,
            sortDirection,
            userId,
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


        // 2. userId aus der Authentifizierung holen (wenn vorhanden)
        const userId = req.user?.id; // Optionaler Chaining Operator für den Fall, dass req.user nicht existiert

        let userRating = null;
        let averageRating = null;
        let ratingCount = 0;
        let internalRecipeId = null; // Für die interne ID des Rezepts in unserer DB

        // Dieser Block versucht, interne DB-Daten zu holen, wenn die Spoonacular-Details vorhanden sind
        // oder ein userId vorhanden ist (falls wir ein Rezept ohne Spoonacular-ID speichern wollten,
        // was hier aber nicht der Fall ist, da wir immer von Spoonacular-ID ausgehen)
        try {
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

            const internalRecipe = await recipeManagementService.getOrCreateRecipeInDb(
                spoonacularId,
                recipeDataForDbUpsert
            );

            internalRecipeId = internalRecipe?.id;

            // 4. Benutzerbewertung abrufen, falls angemeldet UND interne Rezept-ID vorhanden
            if (userId && internalRecipeId) {
                userRating = await recipeManagementService.getUserRecipeRating(userId, internalRecipeId);
            } else {
            }

            // 5. Durchschnittliche Bewertung und Anzahl abrufen, falls interne Rezept-ID vorhanden
            if (internalRecipeId) {
                const avgData = await recipeManagementService.getAverageRecipeRating(internalRecipeId);
                averageRating = avgData.averageRating;
                ratingCount = avgData.ratingCount;
            } else {
            }

        } catch (dbError) {
            console.error('[BACKEND DEBUG - CONTROLLER] ERROR in DB operations (getOrCreateRecipeInDb, getUserRecipeRating, getAverageRecipeRating):', dbError);
        }

        // 6. Alle Informationen zusammenführen und senden
        const fullRecipeDetails = {
            ...recipeDetails, // Spoonacular Details
            userRating: userRating, // Eigene Bewertung des Nutzers (oder null)
            averageRating: averageRating, // Durchschnittliche Bewertung (oder null)
            ratingCount: ratingCount, // Anzahl der Bewertungen (oder 0)
            internalRecipeId: internalRecipeId, // Die interne ID, falls Frontend sie benötigt
        };


        return res.json(fullRecipeDetails);

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] UNEXPECTED GLOBAL ERROR in getRecipeDetails controller:', error);
        // Anpassung der Fehlerantwort, um konsistent zu sein
        const statusCode = error.status || error.response?.status || 500;
        const errorMessage = error.message || error.response?.data?.message || 'Failed to fetch recipe details.';
        return res.status(statusCode).json({ message: errorMessage });
    }
};

const getInternalRecipeDetails = async (req, res) => {
    try {
        const { id } = req.params;
        const userId = req.user?.id;
        
        const recipe = await recipeManagementService.getInternalRecipeDetails(id);
        if (!recipe) {
            return res.status(404).json({ message: 'Recipe not found' });
        }

        // Lade Benutzerbewertung, falls angemeldet
        let userRating = null;
        if (userId) {
            userRating = await recipeManagementService.getUserRecipeRating(userId, id);
        }

        // Füge Benutzerbewertung zum Rezept hinzu
        const fullRecipeDetails = {
            ...recipe,
            userRating: userRating,
        };

        return res.json(fullRecipeDetails);
    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getInternalRecipeDetails:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to fetch internal recipe details.';
        return res.status(statusCode).json({ message });
    }
};

const addFavoriteRecipe = async (req, res) => {
    try {
        const userId = req.user.id;
        const { spoonacularId, internalRecipeId, recipeData } = req.body;

        if (!userId || (!spoonacularId && !internalRecipeId) || !recipeData) {
            return res.status(400).json({ message: 'Missing user ID, Spoonacular ID, internal recipe ID or recipe data.' });
        }

        let recipeIdToUse = null;
        if (spoonacularId) {
            const recipe = await recipeManagementService.getOrCreateRecipeInDb(spoonacularId, recipeData);
            recipeIdToUse = recipe.id;
        } else if (internalRecipeId) {
            // Prüfe, ob das Rezept existiert
            const recipe = await prisma.recipes.findUnique({ where: { id: internalRecipeId } });
            if (!recipe) {
                return res.status(404).json({ message: 'Internal recipe not found.' });
            }
            recipeIdToUse = internalRecipeId;
        }

        const favorite = await recipeManagementService.addFavoriteRecipeByRecipeId(userId, recipeIdToUse);
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
        const { favoriteId } = req.params; // Verwende die ID des Favoriten-Eintrags
        if (!userId || !favoriteId) {
            return res.status(400).json({ message: 'Missing user ID or favorite ID.' });
        }

        await recipeManagementService.removeFavoriteRecipe(userId, favoriteId);
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

        // Rufe den Service auf; er gibt jetzt das Favoriten-Objekt oder null zurück
        const favorite = await recipeManagementService.isRecipeFavoritedByUser(userId, recipeId);

        if (favorite) {
            // Wenn favorisiert, sende HTTP 200 OK und das Favoriten-Objekt
            return res.status(200).json(favorite);
        } else {
            // Wenn nicht favorisiert, sende HTTP 404 Not Found
            return res.status(404).json({ message: 'Recipe not favorited by this user.' });
        }

    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Error in getRecipeIsFavorited:', error);
        const statusCode = error.status || 500;
        const message = error.message || 'Failed to check favorite status.';
        return res.status(statusCode).json({ message });
    }
};

const addOrUpdateRecipeRating = async (req, res) => {
    try {
        const userId = req.user.id;
        const { spoonacularId, internalRecipeId, rating, comment, recipeData } = req.body;

        if (!userId || (!spoonacularId && !internalRecipeId) || typeof rating !== 'number' || rating < 1 || rating > 5 || !recipeData) {
            return res.status(400).json({ message: 'Missing user ID, Spoonacular ID or internal recipe ID, valid rating (1-5), or recipe data.' });
        }

        // Rufe den Service auf, der jetzt die aggregierten Daten zurückgibt
        const { userRating, averageRating, ratingCount } = await recipeManagementService.addOrUpdateRecipeRating(
            userId,
            spoonacularId,
            internalRecipeId,
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

const getOwnRecipesForUser = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) {
            return res.status(401).json({ message: 'Nicht authentifiziert.' });
        }
        const recipes = await recipeManagementService.getOwnRecipesForUser(userId);
        // Für jedes Rezept ggf. signed URL erzeugen
        const recipesWithImageUrls = await Promise.all(recipes.map(async (recipe) => {
            let imageUrl = recipe.image_url;
            if (imageUrl && !imageUrl.startsWith('http')) {
                imageUrl = await mediaService.getSignedDownloadUrl(imageUrl);
            }
            return { ...recipe, imageUrl };
        }));
        return res.json(recipesWithImageUrls);
    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Fehler in getOwnRecipesForUser:', error);
        return res.status(500).json({ message: 'Fehler beim Laden der eigenen Rezepte.' });
    }
};

const addOwnRecipe = async (req, res) => {
    try {
        const userId = req.user?.id;
        if (!userId) {
            return res.status(401).json({ message: 'Nicht authentifiziert.' });
        }
        const { title, servings, readyInMinutes, summary, ingredients, steps, imageUrl } = req.body;
        if (!title || !ingredients || !steps) {
            return res.status(400).json({ message: 'Pflichtfelder fehlen.' });
        }
        const recipe = await recipeManagementService.createOwnRecipe({
            userId,
            title,
            servings,
            readyInMinutes,
            summary,
            ingredients,
            steps,
            imageUrl
        });
        return res.status(201).json(recipe);
    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Fehler in addOwnRecipe:', error);
        return res.status(500).json({ message: 'Fehler beim Anlegen des Rezepts.' });
    }
};

const addRecipeImageUploadUrl = async (req, res) => {
    try {
        const { filename, contentType } = req.body;
        if (!filename || !contentType) {
            return res.status(400).json({ message: 'filename und contentType sind erforderlich.' });
        }
        const objectKey = `recipe-pictures/${filename}`;
        const uploadInfo = await mediaService.getSignedUploadUrl(objectKey, contentType);
        return res.json({ ...uploadInfo, objectKey });
    } catch (error) {
        console.error('[BACKEND DEBUG - CONTROLLER] Fehler in addRecipeImageUploadUrl:', error);
        return res.status(500).json({ message: 'Fehler beim Erstellen der Upload-URL.' });
    }
};

module.exports = {
    getRecipesByQuery,
    getRecipesByIngredients,
    getRecipeDetails,
    getInternalRecipeDetails,
    addFavoriteRecipe,
    removeFavoriteRecipe,
    getFavoriteRecipes,
    getRecipeIsFavorited,
    addOrUpdateRecipeRating,
    getUserRecipeRating,
    getOwnRecipesForUser,
    addOwnRecipe,
    addRecipeImageUploadUrl,
};
