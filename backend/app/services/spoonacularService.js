// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');

const SPOONACULAR_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';

let currentKeyIndex = 0;

const searchSpoonacularRecipes = async ({ query, ingredients, offset, number, filters, sortBy, sortDirection }) => {
    // DIESER LOG MUSS ERSCHEINEN, WENN DIE SERVICE-FUNKTION AUFGERUFEN WIRD!
    console.log('[BACKEND DEBUG - SERVICE] searchSpoonacularRecipes called.');
    console.log('[BACKEND DEBUG - SERVICE] Incoming parameters:', { query, ingredients, offset, number, filters, sortBy, sortDirection });


    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        console.error('[BACKEND DEBUG - SERVICE] No Spoonacular API keys found.');
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
                sort: sortBy,
                sortDirection: sortDirection,
            };

            Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

            console.log(`[BACKEND DEBUG - SERVICE] Sending request to Spoonacular with params:`, spoonacularParams);

            // --- WICHTIG: Zusätzlicher Try-Catch um den Axios-Aufruf ---
            let response;
            try {
                response = await axios.get(SPOONACULAR_BASE_URL, {
                    params: spoonacularParams,
                    timeout: 10000 // Füge hier einen Timeout für den Axios-Aufruf selbst hinzu (10 Sekunden)
                });
                console.log(`[BACKEND DEBUG - SERVICE] Spoonacular API responded with status: ${response.status}`);
            } catch (axiosError) {
                console.error(`[BACKEND DEBUG - SERVICE] Axios error during Spoonacular call: ${axiosError.message}`);
                // Wenn Axios einen Fehler wirft (z.B. Timeout, 4xx/5xx von Spoonacular)
                if (axiosError.response) {
                    console.error('[BACKEND DEBUG - SERVICE] Axios response error data:', axiosError.response.data);
                    console.error('[BACKEND DEBUG - SERVICE] Axios response status:', axiosError.response.status);
                    if (axiosError.response.status === 402 || axiosError.response.status === 429) {
                        console.warn(`[BACKEND DEBUG - SERVICE] Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`);
                        currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                        retries++;
                        continue; // Versuche den nächsten Key
                    }
                } else if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
                    console.error('[BACKEND DEBUG - SERVICE] Axios Timeout/Connection error to Spoonacular.');
                }
                // Bei anderen Fehlern oder wenn alle Retries erschöpft sind, werfen wir den Fehler weiter
                throw axiosError; // Wirf den originalen Axios-Fehler, um ihn im äußeren Catch zu behandeln
            }
            // --- ENDE ZUSÄTZLICHER TRY-CATCH ---


            console.log(`[BACKEND DEBUG - SERVICE] Raw Spoonacular API Response Data (results array):`);
            if (response.data && response.data.results && response.data.results.length > 0) {
                console.log(`[BACKEND DEBUG - SERVICE] First Spoonacular Result:`, response.data.results[0]);
            } else {
                console.log(`[BACKEND DEBUG - SERVICE] Spoonacular returned no results or empty results array.`);
            }

            const recipes = response.data.results.map(recipe => ({
                id: recipe.id,
                name: recipe.title,
                imageUrl: recipe.image,
                imageType: recipe.imageType,
                servings: recipe.servings,
                readyInMinutes: recipe.readyInMinutes,
                place: recipe.sourceName,
            }));

            console.log(`[BACKEND DEBUG - SERVICE] Transformed Recipes (sent to Flutter):`);
            if (recipes.length > 0) {
                console.log(`[BACKEND DEBUG - SERVICE] First Transformed Recipe:`, recipes[0]);
            } else {
                console.log(`[BACKEND DEBUG - SERVICE] Transformed recipes array is empty.`);
            }

            return recipes;

        } catch (error) { // Dieser Catch fängt Fehler vom Axios-Aufruf oder vom Mapping ab
            console.error(`[BACKEND DEBUG - SERVICE] Outer catch - Error in searchSpoonacularRecipes: ${error.message}`);
            // Hier kannst du spezifischere Fehlerbehandlung für Flutter machen
            const statusCode = error.response ? error.response.status : 500;
            const errorMessage = error.response && error.response.data ? error.response.data : { message: 'Failed to search recipes from external API.' };
            throw { status: statusCode, message: errorMessage.message || 'External API error' };
        }
    }

    console.error('[BACKEND DEBUG - SERVICE] All Spoonacular API keys attempted and failed for this request.');
    throw new Error('All Spoonacular API keys are currently unavailable or exhausted.');
};

module.exports = {
    searchSpoonacularRecipes,
};