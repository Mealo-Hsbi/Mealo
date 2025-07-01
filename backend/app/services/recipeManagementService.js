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
    // Lazy require, um Circular Dependency zu vermeiden
    const { getSpoonacularRecipeDetails } = require('./spoonacularService');

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
        } else if (internalRecipeIdFromFrontend && typeof internalRecipeIdFromFrontend === 'string') {
            // Fall 2: Nur wenn die interne ID ein String (UUID) ist
            recipe = await prisma.recipes.upsert({
                where: { id: internalRecipeIdFromFrontend }, // Suche über interne ID
                update: {
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

        // --- NEU: Zutaten prüfen und ggf. nachziehen ---
        const recipeWithIngredients = await prisma.recipes.findUnique({
            where: { id: recipe.id },
            include: { recipe_ingredients: true }
        });

        if (!recipeWithIngredients.recipe_ingredients || recipeWithIngredients.recipe_ingredients.length === 0) {
            console.log(`[RECIPE-IMPORT] Recipe ${recipe.id} has no ingredients. Fetching from Spoonacular...`);
            if (spoonacularId) {
                const details = await getSpoonacularRecipeDetails(spoonacularId);
                if (details.extendedIngredients && details.extendedIngredients.length > 0) {
                    for (const ing of details.extendedIngredients) {
                        // Ingredient anlegen (falls noch nicht vorhanden)
                        let dbIngredient = await prisma.ingredients.findUnique({ where: { name: ing.name } });
                        if (!dbIngredient) {
                            dbIngredient = await prisma.ingredients.create({
                                data: {
                                    name: ing.name,
                                    // Optional: weitere Felder wie image, category, etc.
                                }
                            });
                            console.log(`[RECIPE-IMPORT] Created new ingredient: ${ing.name}`);
                        }
                        // recipe_ingredients-Eintrag anlegen
                        await prisma.recipe_ingredients.create({
                            data: {
                                recipe_id: recipe.id,
                                ingredient_id: dbIngredient.id,
                                amount: ing.amount || 1,
                                unit: ing.unit || '',
                                original: ing.original || '',
                            }
                        });
                        console.log(`[RECIPE-IMPORT] Linked ingredient ${ing.name} to recipe ${recipe.id}`);
                    }
                } else {
                    console.warn(`[RECIPE-IMPORT] No ingredients found from Spoonacular for recipe ${spoonacularId}`);
                }
            } else {
                console.warn(`[RECIPE-IMPORT] No Spoonacular ID for recipe ${recipe.id}, cannot fetch ingredients.`);
            }
        } else {
            console.log(`[RECIPE-IMPORT] Recipe ${recipe.id} already has ingredients.`);
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
    // Hole das Rezept anhand der internen UUID
    const recipe = await prisma.recipes.findUnique({
        where: { id },
        // Hier ggf. weitere Relationen einbinden (z.B. Zutaten, Schritte)
    });
    if (!recipe) return null;
    // Passe das Mapping ggf. an die Felder im Frontend an
    return {
        id: recipe.id,
        title: recipe.title,
        imageUrl: recipe.image_url,
        servings: recipe.servings,
        readyInMinutes: recipe.ready_in_minutes,
        summary: recipe.summary,
        // ... weitere Felder nach Bedarf
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
    return prisma.recipes.findMany({
        where: { created_by_id: userId },
        orderBy: { created_at: 'desc' },
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
