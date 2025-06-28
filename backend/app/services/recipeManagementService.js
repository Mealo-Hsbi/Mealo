// services/recipeManagementService.js

const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();

console.log('[DEBUG] PrismaClient:', PrismaClient ? 'Loaded' : 'NOT Loaded');
console.log('[DEBUG] Prisma instance:', prisma ? 'Initialized' : 'NOT Initialized');
if (prisma && !prisma.recipes) {
    console.warn('[DEBUG] prisma.recipes is undefined. Is the Prisma schema correct and client regenerated? (Expected: "model recipes")');
}
if (prisma && !prisma.ratings) {
    console.warn('[DEBUG] prisma.ratings is undefined. Is the Prisma schema correct and client regenerated? (Expected: "model ratings")');
}

async function getOrCreateRecipeInDb(spoonacularId, recipeDataFromFrontend) {
    console.log('[DEBUG - SERVICE] getOrCreateRecipeInDb called with:');
    console.log('   spoonacularId:', spoonacularId);
    console.log('   recipeDataFromFrontend (received from Flutter):', recipeDataFromFrontend);

    if (!prisma || !prisma.recipes || typeof prisma.recipes.upsert !== 'function') {
        console.error('[ERROR] Prisma client or prisma.recipes.upsert is not available. Check Prisma setup and "npx prisma generate".');
        throw new Error('Prisma client not properly initialized or "recipes" model is missing.');
    }

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
    };

    try {
        return await prisma.recipes.upsert({
            where: { spoonacular_id: spoonacularId },
            update: {
                ...prismaRecipeData,
            },
            create: {
                spoonacular_id: spoonacularId,
                ...prismaRecipeData,
            },
        });
    } catch (error) {
        console.error('[ERROR - Prisma Upsert] Fehler beim Erstellen oder Aktualisieren des Rezepts:', error);
        throw error;
    }
}

async function addFavoriteRecipe(userId, spoonacularId, recipeDetailsFromSpoonacular) {
    const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular);
    return prisma.favorites.create({
        data: {
            user_id: userId,
            recipe_id: recipe.id,
        },
    });
}

async function removeFavoriteRecipe(userId, recipeId) {
    return prisma.favorites.deleteMany({
        where: {
            user_id: userId,
            recipe_id: recipeId,
        },
    });
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
    });
    return !!favorite;
}

async function addOrUpdateRecipeRating(userId, spoonacularId, ratingScore, recipeDetailsFromSpoonacular) {
    const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular);

    const ratingDataForPrisma = {
        user_id: userId,
        recipe_id: recipe.id,
        score: ratingScore,
        comment: recipeDetailsFromSpoonacular.comment || '',
    };

    console.log('[DEBUG - SERVICE] Attempting to upsert rating with data:', ratingDataForPrisma);

    try {
        const result = await prisma.ratings.upsert({
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

        const frontendFriendlyResult = {
            ...result,
            comment: result.comment || '',
        };

        console.log('[DEBUG - SERVICE] Prisma ratings.upsert successful. Returned (frontend-friendly) result:', frontendFriendlyResult);
        return frontendFriendlyResult;
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
                score: true,
                _all: true,
            },
            where: {
                recipe_id: recipeId,
            },
        });

        const averageRating = result._avg.score || null;
        const ratingCount = result._count._all || 0;

        console.log(`[DEBUG - SERVICE] Average rating for recipe ${recipeId}: ${averageRating}, count: ${ratingCount}`);
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
    getAverageRecipeRating, // SICHERSTELLEN, dass dies hier EXPORTIERT IST!
};
