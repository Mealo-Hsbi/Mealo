// services/recipeManagementService.js

const prisma = require('../prisma');
const { unlockAchievementIfNeeded } = require('./achievement.service');

if (prisma && !prisma.recipes) {
    console.warn('[DEBUG] prisma.recipes is undefined. Is the Prisma schema correct and client regenerated? (Expected: "model recipes")');
}
if (prisma && !prisma.ratings) {
    console.warn('[DEBUG] prisma.ratings is undefined. Is the Prisma schema correct and client regenerated? (Expected: "model ratings")');
}

async function getOrCreateRecipeInDb(spoonacularId, recipeDataFromFrontend, userId) {
    if (!prisma || !prisma.recipes || typeof prisma.recipes.upsert !== 'function') {
        console.error('[ERROR] Prisma client or prisma.recipes.upsert is not available. Check Prisma setup and "npx prisma generate".');
        throw new Error('Prisma client not properly initialized or "recipes" model is missing.');
    }

    const internalRecipeIdFromFrontend = recipeDataFromFrontend.id; // Die interne ID des Rezepts in Ihrer Datenbank

    const prismaRecipeData = {
        title: recipeDataFromFrontend.title,
        image_url: recipeDataFromFrontend.imageUrl || null,
        servings: recipeDataFromFrontend.servings || null,
        ready_in_minutes: recipeDataFromFrontend.readyInMinutes || null,
        vegetarian: recipeDataFromFrontend.isVegetarian || false,
        vegan: recipeDataFromFrontend.isVegan || false,
        gluten_free: recipeDataFromFrontend.isGlutenFree || false,
        dairy_free: recipeDataFromFrontend.isDairyFree || false,
        dish_types: recipeDataFromFrontend.dishTypes || [],
        summary: recipeDataFromFrontend.summary || null,
        health_score: recipeDataFromFrontend.healthScore || null,
        spoonacular_id: spoonacularId || null, // Die Spoonacular ID des Rezepts
    };

    try {
        let recipe;
        if (spoonacularId) {
            // Fall 1: Spoonacular ID ist vorhanden (wie bisher)
            recipe = await prisma.recipes.upsert({
                where: { spoonacular_id: spoonacularId },
                update: prismaRecipeData,
                create: {
                    spoonacular_id: spoonacularId,
                    ...prismaRecipeData,
                },
            });
        } else if (internalRecipeIdFromFrontend) {
            // Fall 2: Keine Spoonacular ID, aber interne ID vom Frontend vorhanden
            // Dies ist der Fall für bereits existierende, selbst erstellte Rezepte,
            // oder importierte Spoonacular-Rezepte, deren interne ID das Frontend kennt.
            recipe = await prisma.recipes.upsert({
                where: { id: internalRecipeIdFromFrontend }, // Suche über interne ID
                update: {
                    // Keine spoonacular_id im Update setzen, wenn sie null ist
                    ...prismaRecipeData,
                },
                create: {
                    id: internalRecipeIdFromFrontend, // Interne ID beim Erstellen setzen
                    ...prismaRecipeData,
                },
            });
        } else {
            // Fall 3: Weder Spoonacular ID noch interne ID vom Frontend vorhanden
            // Dies ist der Fall für ein **brandneues, selbst erstelltes Rezept**,
            // das zum ersten Mal gespeichert wird. Hier muss die DB die UUID generieren.
            recipe = await prisma.recipes.create({
                data: prismaRecipeData, // Prisma generiert die UUID für 'id'
            });
        }

        // Achievement: first_recipe
        if (userId) {
            const userRecipeCount = await prisma.recipes.count({ where: { created_by_id: userId } });
            if (userRecipeCount === 1) {
                await unlockAchievementIfNeeded(userId, 'first_recipe');
            }
            if (userRecipeCount === 10) {
                await unlockAchievementIfNeeded(userId, '10_recipes');
            }
        }

        return recipe;
    } catch (error) {
        console.error('[ERROR - Prisma Recipe Operation] Fehler beim Erstellen oder Aktualisieren des Rezepts:', error);
        throw error;
    }
}

async function addFavoriteRecipe(userId, spoonacularId, recipeDetailsFromSpoonacular) {
    const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular, userId);
    
    try {
        const newFavorite = await prisma.favorites.create({
            data: {
                user_id: userId,
                recipe_id: recipe.id,
            },
            include: {
                recipes: true,
            },
        });
        
        // Achievement: first_favorite, 5_favorites
        const favCount = await prisma.favorites.count({ where: { user_id: userId } });
        console.log('favCount', favCount);
        if (favCount > 0) {
            await unlockAchievementIfNeeded(userId, 'first_favorite');
        }
        if (favCount >= 5) {
            await unlockAchievementIfNeeded(userId, '5_favorites');
        }
        
        return newFavorite;
    } catch (error) {
        console.error('[Backend Service] Error adding favorite:', error);
        throw error;
    }
}

async function removeFavoriteRecipe(userId, favoriteId) {
    try {
        const result = await prisma.favorites.delete({ // delete statt deleteMany, da es eine einzelne ID ist
            where: {
                id: favoriteId, // Lösche nach der ID des Favoriten-Eintrags
            },
        });

        return result;
    } catch (error) {
        console.error(`[Backend Service] Error removing favorite for userId: ${userId}, recipeId: ${recipeId}:`, error);
        throw error;
    }
}

async function getFavoriteRecipesForUser(userId) {
    const favoriteRecipes = await prisma.favorites.findMany({
        where: { user_id: userId },
        include: { recipes: true },
    });

    return favoriteRecipes;
}

async function isRecipeFavoritedByUser(userId, recipeId) {
    const favorite = await prisma.favorites.findUnique({
        where: {
            user_id_recipe_id: {
                user_id: userId,
                recipe_id: recipeId,
            },
        },
        // Optional: Include the recipe details if the frontend expects them as part of the FavoriteModel
        // include: {
        //     recipes: true,
        // },
    });
    // Gibt das Favorite-Objekt oder null zurück
    return favorite;
}

/**
 * Fügt eine Rezeptbewertung hinzu oder aktualisiert sie und gibt die aktualisierten
 * aggregierten Bewertungen für das Rezept zurück.
 * @param {string} userId - Die ID des Benutzers.
 * @param {number} spoonacularId - Die Spoonacular ID des Rezepts.
 * @param {number} internalRecipeId - Die interne ID des Rezepts.
 * @param {number} ratingScore - Der Bewertungswert (1-5).
 * @param {object} recipeDetailsFromFrontend - Die Rezeptdetails von Spoonacular (für getOrCreateRecipeInDb).
 * @param {string} [comment=''] - Optionaler Kommentar zur Bewertung.
 * @returns {Promise<{userRating: object, averageRating: number | null, ratingCount: number}>} - Das Bewertungsobjekt des Benutzers und die aggregierten Werte.
 */
async function addOrUpdateRecipeRating(userId, spoonacularId, internalRecipeId, ratingScore, recipeDetailsFromFrontend, comment = '') {
    let recipe;
    if (spoonacularId) {
        recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromFrontend);
    } else if (internalRecipeId) {
        recipe = await prisma.recipes.findUnique({ where: { id: internalRecipeId } });
        if (!recipe) {
            throw new Error('Internal recipe not found.');
        }
    } else {
        throw new Error('No valid recipe identifier provided.');
    }

    const ratingDataForPrisma = {
        user_id: userId,
        recipe_id: recipe.id, // Verwende die interne ID des Rezepts
        score: ratingScore,
        comment: comment, // Den Kommentar übergeben
    };

    try {
        const userRatingResult = await prisma.ratings.upsert({
            where: {
                user_id_recipe_id: {
                    user_id: ratingDataForPrisma.user_id,
                    recipe_id: ratingDataForPrisma.recipe_id,
                },
            },
            update: {
                score: ratingDataForPrisma.score,
                comment: ratingDataForPrisma.comment,
            },
            create: {
                user_id: ratingDataForPrisma.user_id,
                recipe_id: ratingDataForPrisma.recipe_id,
                score: ratingDataForPrisma.score,
                comment: ratingDataForPrisma.comment,
            },
        });

        const frontendFriendlyUserRating = {
            ...userRatingResult,
            comment: userRatingResult.comment || '',
        };

        // Nach dem Speichern/Aktualisieren der Bewertung die aggregierten Werte abrufen
        const { averageRating, ratingCount } = await getAverageRecipeRating(recipe.id); // Verwende die interne ID

        // Gib beide Informationen zurück: die spezifische Nutzerbewertung und die aggregierten Werte
        return {
            userRating: frontendFriendlyUserRating,
            averageRating: averageRating,
            ratingCount: ratingCount,
        };
    } catch (error) {
        console.error('[ERROR - Prisma Ratings Upsert] Fehler beim Erstellen oder Aktualisieren der Bewertung:', error);
        throw error;
    }
}

async function getUserRecipeRating(userId, recipeId) {
    const result = await prisma.ratings.findUnique({
        where: {
            user_id_recipe_id: {
                user_id: userId,
                recipe_id: recipeId,
            },
        },
    });

    if (result) {
        return {
            ...result,
            comment: result.comment || '',
        };
    }
    return null;
}

/**
 * Holt die durchschnittliche Bewertung und die Anzahl der Bewertungen für ein Rezept.
 * @param {string} recipeId - Die interne UUID des Rezepts aus Ihrer Datenbank.
 * @returns {Promise<{averageRating: number | null, ratingCount: number}>}
 */
async function getAverageRecipeRating(recipeId) {
    try {
        const result = await prisma.ratings.aggregate({
            _avg: {
                score: true,
            },
            _count: {
                score: true, // Zähle non-null Scores
                _all: true,  // Gesamtzahl der Einträge
            },
            where: {
                recipe_id: recipeId,
            },
        });

        // Prüfe auf 0 Bewertungen, um Division durch Null zu vermeiden und korrekte Werte zu liefern
        const averageRating = result._avg.score !== null ? parseFloat(result._avg.score.toFixed(1)) : null;
        const ratingCount = result._count.score || 0; // Oder result._count._all, je nachdem was du zählen willst (nur Ratings mit Score vs. alle Ratings)

        return { averageRating, ratingCount };
    } catch (error) {
        console.error('[ERROR - Prisma Ratings Aggregate] Fehler beim Abrufen der durchschnittlichen Bewertung:', error);
        return { averageRating: null, ratingCount: 0 };
    }
}

async function getInternalRecipeDetails(id) {
    // Hole das Rezept mit allen Relationen
    const recipe = await prisma.recipes.findUnique({
        where: { id },
        include: {
            recipe_ingredients: {
                include: {
                    ingredients: true
                }
            },
            recipe_steps: {
                orderBy: {
                    step_number: 'asc'
                }
            },
            ratings: true,
            users: true // Für den Ersteller
        }
    });
    
    if (!recipe) return null;

    // Berechne durchschnittliche Bewertung
    const avgRating = recipe.ratings.length > 0 
        ? recipe.ratings.reduce((sum, rating) => sum + rating.score, 0) / recipe.ratings.length
        : null;

    // Mappe Zutaten in Spoonacular-Format
    const extendedIngredients = recipe.recipe_ingredients.map(ri => ({
        id: parseInt(ri.ingredients.id.replace(/-/g, '').substring(0, 8), 16), // Konvertiere UUID zu Integer
        aisle: null, // Eigene Rezepte haben keine Aisle-Information
        image: null, // Eigene Rezepte haben keine Zutatenbilder
        consistency: null,
        name: ri.ingredients.name,
        original: `${ri.amount} ${ri.unit} ${ri.ingredients.name}`,
        originalName: ri.original || `${ri.amount} ${ri.unit} ${ri.ingredients.name}`,
        amount: parseFloat(ri.amount),
        unit: ri.unit,
        meta: [],
        measures: null
    }));

    // Mappe Schritte in Spoonacular-Format
    const analyzedInstructions = [{
        name: null,
        steps: recipe.recipe_steps.map((step, index) => ({
            number: step.step_number,
            step: step.description,
            ingredients: [], // Könnte später durch NLP erweitert werden
            equipment: [],
            length: step.duration_minutes ? {
                number: step.duration_minutes,
                unit: 'minutes'
            } : null
        }))
    }];

    // Erstelle Diets-Array basierend auf den Rezept-Eigenschaften
    const diets = [];
    if (recipe.vegan) diets.push('vegan');
    if (recipe.vegetarian) diets.push('vegetarian');
    if (recipe.gluten_free) diets.push('gluten-free');
    if (recipe.dairy_free) diets.push('dairy-free');

    // Mappe in Spoonacular-Format
    return {
        spoonacularId: null, // Eigene Rezepte haben keine Spoonacular ID
        internalRecipeId: recipe.id,
        title: recipe.title,
        image: recipe.image_url,
        imageType: null,
        servings: recipe.servings,
        readyInMinutes: recipe.ready_in_minutes,
        sourceUrl: null, // Eigene Rezepte haben keine externe Quelle
        sourceName: null,
        summary: recipe.summary,
        aggregateLikes: null, // Eigene Rezepte haben keine Likes
        healthScore: recipe.health_score,
        pricePerServing: null, // Eigene Rezepte haben keine Preisinformation
        dishTypes: recipe.dish_types || [],
        diets: diets,
        intolerances: [], // Könnte später erweitert werden
        extendedIngredients: extendedIngredients,
        analyzedInstructions: analyzedInstructions,
        calories: null, // Könnte später berechnet werden
        protein: null,
        fat: null,
        carbs: null,
        sugar: null,
        nutrition: null, // Könnte später berechnet werden
        userRating: null, // Wird separat geladen
        averageRating: avgRating,
        ratingCount: recipe.ratings.length,
        // Zusätzliche Felder für eigene Rezepte
        createdBy: recipe.users ? {
            id: recipe.users.id,
            name: recipe.users.name,
            email: recipe.users.email
        } : null,
        createdAt: recipe.created_at
    };
}

async function addFavoriteRecipeByRecipeId(userId, recipeId) {
    try {
        const newFavorite = await prisma.favorites.create({
            data: {
                user_id: userId,
                recipe_id: recipeId,
            },
            include: {
                recipes: true,
            },
        });
        // Achievement: first_favorite, 5_favorites
        const favCount = await prisma.favorites.count({ where: { user_id: userId } });
        console.log('[AchievementTrigger] favCount', favCount);
        if (favCount === 1) {
            console.log('[AchievementTrigger] Unlock first_favorite');
            await unlockAchievementIfNeeded(userId, 'first_favorite');
        }
        if (favCount === 5) {
            console.log('[AchievementTrigger] Unlock 5_favorites');
            await unlockAchievementIfNeeded(userId, '5_favorites');
        }
        return newFavorite;
    } catch (error) {
        console.error('[Backend Service] Error adding favorite by recipeId:', error);
        throw error;
    }
}

/**
 * Gibt alle eigenen Rezepte eines Nutzers zurück
 * @param {string} userId - Die ID des Benutzers
 * @returns {Promise<Array>} - Liste der eigenen Rezepte
 */
async function getOwnRecipesForUser(userId) {
    if (!userId) throw new Error('userId ist erforderlich');
    
    const recipes = await prisma.recipes.findMany({
        where: { created_by_id: userId },
        include: {
            ratings: true,
            recipe_ingredients: {
                include: {
                    ingredients: true
                }
            }
        },
        orderBy: { created_at: 'desc' },
    });

    // Mappe die Rezepte in das erwartete Format
    return recipes.map(recipe => {
        // Berechne durchschnittliche Bewertung
        const avgRating = recipe.ratings.length > 0 
            ? recipe.ratings.reduce((sum, rating) => sum + rating.score, 0) / recipe.ratings.length
            : null;

        return {
            id: null, // Keine Spoonacular ID
            internalId: recipe.id,
            isInternal: true,
            name: recipe.title,
            title: recipe.title,
            imageUrl: recipe.image_url,
            place: null, // Eigene Rezepte haben keinen Ort
            readyInMinutes: recipe.ready_in_minutes,
            servings: recipe.servings,
            calories: null, // Könnte später berechnet werden
            protein: null,
            fat: null,
            carbs: null,
            sugar: null,
            healthScore: recipe.health_score,
            usedIngredientCount: recipe.recipe_ingredients.length,
            missedIngredientCount: 0, // Eigene Rezepte haben keine fehlenden Zutaten
            usedIngredients: recipe.recipe_ingredients.map(ri => ({
                id: parseInt(ri.ingredients.id.replace(/-/g, '').substring(0, 8), 16), // Konvertiere UUID zu Integer
                name: ri.ingredients.name,
                amount: parseFloat(ri.amount),
                unit: ri.unit,
                original: `${ri.amount} ${ri.unit} ${ri.ingredients.name}`,
                aisle: null,
                image: null,
                consistency: null,
                originalName: `${ri.amount} ${ri.unit} ${ri.ingredients.name}`,
                meta: [],
                measures: null
            })),
            missedIngredients: [],
            averageRating: avgRating,
            ratingCount: recipe.ratings.length,
            containsUserAllergens: false, // Könnte später berechnet werden
            matchedAllergens: [],
            createdAt: recipe.created_at
        };
    });
}

module.exports = {
    getOrCreateRecipeInDb,
    addFavoriteRecipe,
    removeFavoriteRecipe,
    getFavoriteRecipesForUser,
    isRecipeFavoritedByUser,
    addOrUpdateRecipeRating,
    getUserRecipeRating,
    getAverageRecipeRating,
    getInternalRecipeDetails,
    addFavoriteRecipeByRecipeId,
    getOwnRecipesForUser,
};
