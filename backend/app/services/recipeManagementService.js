// services/recipeManagementService.js

const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();

if (prisma && !prisma.recipes) {
    console.warn('[DEBUG] prisma.recipes is undefined. Is the Prisma schema correct and client regenerated? (Expected: "model recipes")');
}
if (prisma && !prisma.ratings) {
    console.warn('[DEBUG] prisma.ratings is undefined. Is the Prisma schema correct and client regenerated? (Expected: "model ratings")');
}

async function getOrCreateRecipeInDb(spoonacularId, recipeDataFromFrontend) {
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

        return recipe;
    } catch (error) {
        console.error('[ERROR - Prisma Recipe Operation] Fehler beim Erstellen oder Aktualisieren des Rezepts:', error);
        throw error;
    }
}

async function addFavoriteRecipe(userId, spoonacularId, recipeDetailsFromSpoonacular) {
    const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular);
    
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
    return prisma.favorites.findMany({
        where: { user_id: userId },
        include: { recipes: true },
    });
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
 * @param {number} ratingScore - Der Bewertungswert (1-5).
 * @param {object} recipeDetailsFromSpoonacular - Die Rezeptdetails von Spoonacular (für getOrCreateRecipeInDb).
 * @param {string} [comment=''] - Optionaler Kommentar zur Bewertung.
 * @returns {Promise<{userRating: object, averageRating: number | null, ratingCount: number}>} - Das Bewertungsobjekt des Benutzers und die aggregierten Werte.
 */
async function addOrUpdateRecipeRating(userId, spoonacularId, ratingScore, recipeDetailsFromSpoonacular, comment = '') {
    // Stellen Sie sicher, dass das Rezept in unserer Datenbank existiert
    const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular);

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


module.exports = {
    getOrCreateRecipeInDb,
    addFavoriteRecipe,
    removeFavoriteRecipe,
    getFavoriteRecipesForUser,
    isRecipeFavoritedByUser,
    addOrUpdateRecipeRating,
    getUserRecipeRating,
    getAverageRecipeRating,
};
