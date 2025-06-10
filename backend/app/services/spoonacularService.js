// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');

const SPOONACULAR_SEARCH_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';
const SPOONACULAR_RECIPE_INFO_BASE_URL = 'https://api.spoonacular.com/recipes';

let currentKeyIndex = 0;

const findNutrientValue = (nutrients, title) => {
    if (!nutrients) return null;
    const nutrient = nutrients.find(n => n.name === title);
    return nutrient ? nutrient.amount : null;
};

const searchSpoonacularRecipes = async ({
    query,
    ingredients, // Dies sind die vom Frontend ausgewählten Zutaten
    offset,
    number,
    filters,
    sortBy,
    sortDirection,
    maxMissingIngredients // NEU: Diesen Parameter vom Frontend erwarten
}) => {
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
                // WICHTIG: Spoonacular erwartet 'includeIngredients' als Parametername,
                // nicht 'ingredients'. Auch der Wert muss ein kommaseparierter String sein.
                includeIngredients: ingredients && ingredients.length > 0 ? ingredients.join(',') : undefined,
                offset: offset,
                number: number,
                addRecipeInformation: true,
                addRecipeNutrition: true,
                minCalories: filters?.minCalories,
                maxCalories: filters?.maxCalories,
                diet: filters?.diet,
                intolerances: filters?.intolerances,
                sort: sortBy,
                sortDirection: sortDirection,
                // maxMissingIngredients: maxMissingIngredients, // Spoonacular Parameter ist auch maxMissingIngredients
                maxMissingIngredients: 10, // Spoonacular Parameter ist auch maxMissingIngredients
                ranking: 1,
            };

            // Clean up undefined params
            Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

            // --- FÜGEN SIE HIER DIE LOGS HINZU ---
            console.log('--- Backend Spoonacular Service Debug ---');
            console.log('Received parameters from controller:');
            console.log('  query:', query);
            console.log('  ingredients:', ingredients); // Die Array-Form vom Controller
            console.log('  maxMissingIngredients:', maxMissingIngredients);
            console.log('Constructed Spoonacular parameters:');
            console.log('  spoonacularParams:', spoonacularParams); // Die finalen Parameter, die gesendet werden
            console.log('-------------------------------------');
            // --- ENDE DER LOGS ---

            let response;
            try {
                response = await axios.get(SPOONACULAR_SEARCH_BASE_URL, {
                    params: spoonacularParams,
                    timeout: 10000 // Timeout for the Axios call
                });
            } catch (axiosError) {
                console.error(`[BACKEND DEBUG - SERVICE] Axios error during Spoonacular call: ${axiosError.message}`); // Debug print
                if (axiosError.response) {
                    console.error('[BACKEND DEBUG - SERVICE] Axios response error data:', axiosError.response.data); // Debug print
                    console.error('[BACKEND DEBUG - SERVICE] Axios response status:', axiosError.response.status); // Debug print
                    if (axiosError.response.status === 402 || axiosError.response.status === 429) {
                        console.warn(`[BACKEND DEBUG - SERVICE] Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`); // Debug print
                        currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                        retries++;
                        continue;
                    }
                } else if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
                    console.error('[BACKEND DEBUG - SERVICE] Axios Timeout/Connection error to Spoonacular.'); // Debug print
                }
                throw axiosError;
            }

            if (response.data && response.data.results && response.data.results.length > 0) {
                // Hier könnten Sie auch ein Log hinzufügen, wenn Ergebnisse gefunden wurden
                // console.log(`[BACKEND DEBUG - SERVICE] Found ${response.data.results.length} recipes from Spoonacular.`);
            } else {
                // console.log('[BACKEND DEBUG - SERVICE] No recipes found from Spoonacular for the given parameters.');
            }

            const findNutrientValue = (nutrients, name) => {
                const nutrient = nutrients?.find(n => n.name === name);
                return nutrient ? parseFloat(nutrient.amount.toFixed(2)) : undefined;
            };

            const recipes = response.data.results.map(recipe => {
                const nutrients = recipe.nutrition?.nutrients;

                return {
                    id: recipe.id,
                    name: recipe.title,
                    imageUrl: recipe.image,
                    imageType: recipe.imageType,
                    servings: recipe.servings,
                    readyInMinutes: recipe.readyInMinutes,
                    place: recipe.sourceName,
                    calories: findNutrientValue(nutrients, 'Calories'),
                    protein: findNutrientValue(nutrients, 'Protein'),
                    fat: findNutrientValue(nutrients, 'Fat'),
                    carbs: findNutrientValue(nutrients, 'Carbohydrates'),
                    sugar: findNutrientValue(nutrients, 'Sugar'),
                    healthScore: recipe.healthScore,
                    usedIngredientCount: recipe.usedIngredientCount,
                    missedIngredientCount: recipe.missedIngredientCount,
                    usedIngredients: recipe.usedIngredients,
                    missedIngredients: recipe.missedIngredients,
                };
            });

            return recipes;

        } catch (error) {
            console.error(`[BACKEND DEBUG - SERVICE] Outer catch - Error in searchSpoonacularRecipes: ${error.message}`); // Debug print
            const statusCode = error.response ? error.response.status : 500;
            const errorMessage = error.response && error.response.data ? error.response.data : { message: 'Failed to search recipes from external API.' };
            throw { status: statusCode, message: errorMessage.message || 'External API error' };
        }
    }

    console.error('[BACKEND DEBUG - SERVICE] All Spoonacular API keys attempted and failed for this request.'); // Debug print
    throw new Error('All Spoonacular API keys are currently unavailable or exhausted.');
};

const getSpoonacularRecipeDetails = async (recipeId) => {
    // ... (bestehender Code, keine Änderungen nötig für dieses Problem) ...
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

            return mappedRecipeDetails;

        } catch (axiosError) {
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
    getSpoonacularRecipeDetails,
};