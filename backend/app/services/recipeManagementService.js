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
    // Hole das Rezept samt Zutaten und Schritten anhand der internen UUID
    const recipe = await prisma.recipes.findUnique({
        where: { id },
        include: {
            recipe_ingredients: {
                include: { ingredients: true }
            },
            recipe_steps: true
        }
    });
    if (!recipe) return null;

    // Zutaten mappen (wie Spoonacular extendedIngredients)
    const extendedIngredients = (recipe.recipe_ingredients || []).map((ri, idx) => ({
        id: idx + 1, // Eindeutige int-ID pro Zutat (Frontend erwartet int)
        name: ri.ingredients?.name || '',
        amount: ri.amount !== undefined && ri.amount !== null ? Number(ri.amount) : null,
        unit: ri.unit,
        original: ri.original || `${ri.amount || ''} ${ri.unit || ''} ${ri.ingredients?.name || ''}`.trim(),
        originalName: ri.ingredients?.name || '',
        consistency: null, // Kann ggf. ergänzt werden
        image: null, // Kann ggf. ergänzt werden
        measures: null, // Kann ggf. ergänzt werden
        meta: [], // Leeres Array wie bei Spoonacular
    }));

    // Schritte mappen (wie Spoonacular analyzedInstructions)
    const analyzedInstructions = [
        {
            name: '',
            steps: (recipe.recipe_steps || []).map(step => ({
                number: step.step_number,
                step: step.description,
                ingredients: [],
                equipment: [],
                length: step.duration_minutes != null && step.duration_minutes !== undefined
                    ? { number: step.duration_minutes, unit: 'minutes' }
                    : null,
            }))
        }
    ];

    return {
        id: recipe.id,
        title: recipe.title,
        image: recipe.image_url,
        imageUrl: recipe.image_url,
        imageType: null,
        servings: recipe.servings,
        readyInMinutes: recipe.ready_in_minutes,
        sourceUrl: null,
        sourceName: null,
        summary: recipe.summary,
        aggregateLikes: null,
        healthScore: recipe.health_score,
        pricePerServing: recipe.price_per_serving,
        dishTypes: recipe.dish_types,
        diets: null,
        intolerances: null,
        extendedIngredients,
        analyzedInstructions,
        calories: recipe.calories,
        protein: recipe.protein_gram,
        fat: recipe.fat_gram,
        carbs: recipe.carbs_gram,
        sugar: null,
        nutrition: null,
        userRating: null,
        averageRating: null,
        ratingCount: null,
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

/**
 * Erstellt ein neues Rezept mit allen zugehörigen Daten
 * @param {object} recipeData - Die Rezeptdaten
 * @returns {Promise<object>} - Das erstellte Rezept
 */
async function createRecipe(recipeData) {
    const {
        userId,
        title,
        imageUrl,
        servings,
        readyInMinutes,
        cookingMinutes,
        preparationMinutes,
        dishTypes,
        summary,
        instructions,
        healthScore,
        pricePerServing,
        vegan,
        vegetarian,
        glutenFree,
        dairyFree,
        weightWatcherPoints,
        ingredients,
        steps
    } = recipeData;

    try {
        // Erstelle das Hauptrezept
        const recipe = await prisma.recipes.create({
            data: {
                created_by_id: userId,
                title,
                image_url: imageUrl,
                servings,
                ready_in_minutes: readyInMinutes,
                cooking_minutes: cookingMinutes,
                preparation_minutes: preparationMinutes,
                dish_types: dishTypes,
                summary,
                instructions,
                health_score: healthScore,
                price_per_serving: pricePerServing,
                vegan,
                vegetarian,
                gluten_free: glutenFree,
                dairy_free: dairyFree,
                weight_watcher_points: weightWatcherPoints,
                calories: recipeData.calories,
                protein_gram: recipeData.proteinGram,
                fat_gram: recipeData.fatGram,
                carbs_gram: recipeData.carbsGram,
            },
        });

        // Erstelle die Zutaten, falls vorhanden
        if (ingredients && ingredients.length > 0) {
            for (const ingredientData of ingredients) {
                // Prüfe, ob die Zutat bereits existiert
                let ingredient = await prisma.ingredients.findUnique({
                    where: { name: ingredientData.name }
                });

                // Erstelle die Zutat, falls sie nicht existiert
                if (!ingredient) {
                    ingredient = await prisma.ingredients.create({
                        data: {
                            name: ingredientData.name,
                            category: ingredientData.category,
                            shelf_life_days: ingredientData.shelfLifeDays,
                            calories: ingredientData.calories,
                            protein_gram: ingredientData.proteinGram,
                            carbs_gram: ingredientData.carbsGram,
                            fat_gram: ingredientData.fatGram,
                        }
                    });
                }

                // Verknüpfe die Zutat mit dem Rezept
                await prisma.recipe_ingredients.create({
                    data: {
                        recipe_id: recipe.id,
                        ingredient_id: ingredient.id,
                        amount: ingredientData.amount,
                        unit: ingredientData.unit,
                        original: ingredientData.original,
                    }
                });
            }
        }

        // Erstelle die Schritte, falls vorhanden
        if (steps && steps.length > 0) {
            for (let i = 0; i < steps.length; i++) {
                const step = steps[i];
                await prisma.recipe_steps.create({
                    data: {
                        recipe_id: recipe.id,
                        step_number: i + 1,
                        description: step.description,
                        duration_minutes: step.durationMinutes != null
                            ? Number(step.durationMinutes)
                            : (step.duration_minutes != null ? Number(step.duration_minutes) : null),
                    }
                });
            }
        }

        // Achievement: first_recipe
        const userRecipeCount = await prisma.recipes.count({ where: { created_by_id: userId } });
        if (userRecipeCount === 1) {
            await unlockAchievementIfNeeded(userId, 'first_recipe');
        }
        if (userRecipeCount === 10) {
            await unlockAchievementIfNeeded(userId, '10_recipes');
        }

        return recipe;
    } catch (error) {
        console.error('[ERROR - Prisma Recipe Creation] Fehler beim Erstellen des Rezepts:', error);
        throw error;
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
    getInternalRecipeDetails,
    addFavoriteRecipeByRecipeId,
    getOwnRecipesForUser,
    createRecipe,
};
