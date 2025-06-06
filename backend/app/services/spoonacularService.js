// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');

const SPOONACULAR_SEARCH_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';
const SPOONACULAR_RECIPE_INFO_BASE_URL = 'https://api.spoonacular.com/recipes';

let currentKeyIndex = 0;

const searchSpoonacularRecipes = async ({ query, ingredients, offset, number, filters, sortBy, sortDirection }) => {
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        throw new Error('Server configuration error: Spoonacular API keys are missing.');
    }

    let retries = 0;
    const maxRetries = spoonacularKeys.length;

    while (retries < maxRetries) {
        currentKeyIndex = currentKeyIndex % spoonacularKeys.length;
        const currentKey = spoonacularKeys[currentKeyIndex];

        try {
            const spoonacularParams = {
                apiKey: currentKey,
                query: query,
                includeIngredients: ingredients && ingredients.length > 0 ? ingredients.join(',') : undefined,
                offset: offset,
                number: number,
                addRecipeInformation: true, // Already there: needed for readyInMinutes, servings, place, sourceName
                addRecipeNutrition: true,    // <--- NEW: Request nutrition information from Spoonacular
                minCalories: filters?.minCalories,
                maxCalories: filters?.maxCalories,
                diet: filters?.diet,
                intolerances: filters?.intolerances,
                sort: sortBy,
                sortDirection: sortDirection,
            };

            // Clean up undefined params
            Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

            // console.log(`[BACKEND DEBUG - SERVICE] Sending request to Spoonacular with params:`, spoonacularParams); // Debug print

            let response;
            try {
                response = await axios.get(SPOONACULAR_SEARCH_BASE_URL, {
                    params: spoonacularParams,
                    timeout: 10000 // Timeout for the Axios call
                });
                // console.log(`[BACKEND DEBUG - SERVICE] Spoonacular API responded with status: ${response.status}`); // Debug print
            } catch (axiosError) {
                // console.error(`[BACKEND DEBUG - SERVICE] Axios error during Spoonacular call: ${axiosError.message}`); // Debug print
                if (axiosError.response) {
                    // console.error('[BACKEND DEBUG - SERVICE] Axios response error data:', axiosError.response.data); // Debug print
                    // console.error('[BACKEND DEBUG - SERVICE] Axios response status:', axiosError.response.status); // Debug print
                    if (axiosError.response.status === 402 || axiosError.response.status === 429) {
                        // console.warn(`[BACKEND DEBUG - SERVICE] Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`); // Debug print
                        currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                        retries++;
                        continue;
                    }
                } else if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
                    // console.error('[BACKEND DEBUG - SERVICE] Axios Timeout/Connection error to Spoonacular.'); // Debug print
                }
                throw axiosError;
            }

            if (response.data && response.data.results && response.data.results.length > 0) {
                // console.log(`[BACKEND DEBUG - SERVICE] Raw Spoonacular API Response Data (first result):`, response.data.results[0]); // Debug print
            } else {
                // console.log(`[BACKEND DEBUG - SERVICE] Spoonacular returned no results or empty results array.`); // Debug print
            }

            // Helper function to find a nutrient value
            const findNutrientValue = (nutrients, title) => {
                if (!nutrients) return null;
                const nutrient = nutrients.find(n => n.name === title);
                return nutrient ? nutrient.amount : null;
            };

            const recipes = response.data.results.map(recipe => {
                const nutrients = recipe.nutrition?.nutrients;


                return {
                    id: recipe.id,
                    name: recipe.title, // Maps to `name` in RecipeModel
                    imageUrl: recipe.image, // Maps to `imageUrl` in RecipeModel
                    imageType: recipe.imageType,
                    servings: recipe.servings,
                    readyInMinutes: recipe.readyInMinutes,
                    place: recipe.sourceName, // Maps to `place` in RecipeModel

                    // <--- NEW: Map nutrition data from Spoonacular response
                    calories: findNutrientValue(nutrients, 'Calories'),
                    protein: findNutrientValue(nutrients, 'Protein'),
                    fat: findNutrientValue(nutrients, 'Fat'),
                    carbs: findNutrientValue(nutrients, 'Carbohydrates'), // Spoonacular uses 'Carbohydrates'
                    sugar: findNutrientValue(nutrients, 'Sugar'),
                    healthScore: recipe.healthScore, // Directly available on recipe object
                    // --- END NEW ---

                    // These fields are assumed to be added by your backend later,
                    // if they are based on internal logic (e.g., ingredient matching).
                    // If Spoonacular provides them directly, you'd map them here too.
                    matchingIngredientsCount: recipe.matchingIngredientsCount, // Assumed from backend, not Spoonacular by default
                    missingIngredientsCount: recipe.missingIngredientsCount,   // Assumed from backend, not Spoonacular by default
                };
            });

            // console.log(`[BACKEND DEBUG - SERVICE] Transformed Recipes (sent to Flutter, first result):`, recipes[0]); // Debug print

            return recipes;

        } catch (error) {
            // console.error(`[BACKEND DEBUG - SERVICE] Outer catch - Error in searchSpoonacularRecipes: ${error.message}`); // Debug print
            const statusCode = error.response ? error.response.status : 500;
            const errorMessage = error.response && error.response.data ? error.response.data : { message: 'Failed to search recipes from external API.' };
            throw { status: statusCode, message: errorMessage.message || 'External API error' };
        }
    }

    // console.error('[BACKEND DEBUG - SERVICE] All Spoonacular API keys attempted and failed for this request.'); // Debug print
    throw new Error('All Spoonacular API keys are currently unavailable or exhausted.');
};


const getSpoonacularRecipeDetails = async (recipeId) => {
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        throw new Error('Server configuration error: Spoonacular API keys are missing.');
    }

    let retries = 0;
    const maxRetries = spoonacularKeys.length;

    while (retries < maxRetries) {
        currentKeyIndex = currentKeyIndex % spoonacularKeys.length;
        const currentKey = spoonacularKeys[currentKeyIndex];

        try {
            const spoonacularParams = {
                apiKey: currentKey,
                includeNutrition: true, // Wichtig: Auch hier Nährwertinfos anfordern!
            };

            // Der Endpoint ist /recipes/{id}/information
            const response = await axios.get(
                `${SPOONACULAR_RECIPE_INFO_BASE_URL}/${recipeId}/information`,
                {
                    params: spoonacularParams,
                    timeout: 10000 // Timeout für den Axios-Aufruf
                }
            );

            const recipe = response.data; // Die Antwort ist direkt das Rezeptobjekt

            // Hier kannst du die Daten mappen, falls nötig.
            // Für den Anfang können wir sie fast 1:1 übernehmen.
            // Später können wir hier Aufräumarbeiten (z.B. HTML-Tags entfernen) durchführen.
            const mappedRecipeDetails = {
                id: recipe.id,
                title: recipe.title,
                imageUrl: recipe.image,
                sourceName: recipe.sourceName,
                sourceUrl: recipe.sourceUrl, // Wichtig für den Link zum Originalrezept
                readyInMinutes: recipe.readyInMinutes,
                servings: recipe.servings,
                summary: recipe.summary, // Enthält oft HTML
                extendedIngredients: recipe.extendedIngredients ? recipe.extendedIngredients.map(ing => ({
                    id: ing.id,
                    aisle: ing.aisle,
                    image: ing.image,
                    consistency: ing.consistency,
                    name: ing.name,
                    original: ing.original, // Die vollständige Zeichenkette der Zutat
                    amount: ing.amount,
                    unit: ing.unit
                })) : [],
                analyzedInstructions: recipe.analyzedInstructions ? recipe.analyzedInstructions.map(instr => ({
                    name: instr.name,
                    steps: instr.steps.map(step => ({
                        number: step.number,
                        step: step.step, // Enthält oft HTML
                        ingredients: step.ingredients ? step.ingredients.map(i => i.name) : [],
                        equipment: step.equipment ? step.equipment.map(e => e.name) : []
                    }))
                })) : [],
                healthScore: recipe.healthScore,
                // Nährwerte direkt von der nutrition-Ebene mappen
                calories: findNutrientValue(recipe.nutrition?.nutrients, 'Calories'),
                protein: findNutrientValue(recipe.nutrition?.nutrients, 'Protein'),
                fat: findNutrientValue(recipe.nutrition?.nutrients, 'Fat'),
                carbs: findNutrientValue(recipe.nutrition?.nutrients, 'Carbohydrates'),
                sugar: findNutrientValue(recipe.nutrition?.nutrients, 'Sugar'),
            };

            console.log(`[BACKEND] Fetched recipe details for ID: ${recipeId}`);
            return mappedRecipeDetails;

        } catch (axiosError) {
            console.error(`[BACKEND] Axios error fetching recipe details for ID ${recipeId}: ${axiosError.message}`);
            if (axiosError.response) {
                if (axiosError.response.status === 402 || axiosError.response.status === 429) {
                    console.warn(`[BACKEND] Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`);
                    currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                    retries++;
                    continue; // Erneuter Versuch mit dem nächsten Schlüssel
                }
            }
            throw axiosError; // Andere Fehler weitergeben
        }
    }
    throw new Error('All Spoonacular API keys attempted and failed for this request.');
};


module.exports = {
    searchSpoonacularRecipes,
    getSpoonacularRecipeDetails, // NEU: Exportiere die Funktion
};