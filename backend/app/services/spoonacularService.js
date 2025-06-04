// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');

const SPOONACULAR_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';

let currentKeyIndex = 0;

const searchSpoonacularRecipes = async ({ query, ingredients, offset, number, filters, sortBy, sortDirection }) => {
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        // console.error('[BACKEND DEBUG - SERVICE] No Spoonacular API keys found.'); // Removed debug print
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
                addRecipeInformation: true, // This is needed for readyInMinutes, servings, place
                minCalories: filters?.minCalories,
                maxCalories: filters?.maxCalories,
                diet: filters?.diet,
                intolerances: filters?.intolerances,
                sort: sortBy,
                sortDirection: sortDirection,
            };

            Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

            // console.log(`[BACKEND DEBUG - SERVICE] Sending request to Spoonacular with params:`, spoonacularParams); // Removed debug print

            let response;
            try {
                response = await axios.get(SPOONACULAR_BASE_URL, {
                    params: spoonacularParams,
                    timeout: 10000 // Timeout for the Axios call
                });
                // console.log(`[BACKEND DEBUG - SERVICE] Spoonacular API responded with status: ${response.status}`); // Removed debug print
            } catch (axiosError) {
                // console.error(`[BACKEND DEBUG - SERVICE] Axios error during Spoonacular call: ${axiosError.message}`); // Removed debug print
                if (axiosError.response) {
                    // console.error('[BACKEND DEBUG - SERVICE] Axios response error data:', axiosError.response.data); // Removed debug print
                    // console.error('[BACKEND DEBUG - SERVICE] Axios response status:', axiosError.response.status); // Removed debug print
                    if (axiosError.response.status === 402 || axiosError.response.status === 429) {
                        // console.warn(`[BACKEND DEBUG - SERVICE] Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`); // Removed debug print
                        currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                        retries++;
                        continue;
                    }
                } else if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
                    // console.error('[BACKEND DEBUG - SERVICE] Axios Timeout/Connection error to Spoonacular.'); // Removed debug print
                }
                throw axiosError;
            }

            if (response.data && response.data.results && response.data.results.length > 0) {
                // console.log(`[BACKEND DEBUG - SERVICE] Raw Spoonacular API Response Data (first result):`, response.data.results[0]); // Removed debug print
            } else {
                // console.log(`[BACKEND DEBUG - SERVICE] Spoonacular returned no results or empty results array.`); // Removed debug print
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

            // console.log(`[BACKEND DEBUG - SERVICE] Transformed Recipes (sent to Flutter, first result):`, recipes[0]); // Removed debug print

            return recipes;

        } catch (error) {
            // console.error(`[BACKEND DEBUG - SERVICE] Outer catch - Error in searchSpoonacularRecipes: ${error.message}`); // Removed debug print
            const statusCode = error.response ? error.response.status : 500;
            const errorMessage = error.response && error.response.data ? error.response.data : { message: 'Failed to search recipes from external API.' };
            throw { status: statusCode, message: errorMessage.message || 'External API error' };
        }
    }

    // console.error('[BACKEND DEBUG - SERVICE] All Spoonacular API keys attempted and failed for this request.'); // Removed debug print
    throw new Error('All Spoonacular API keys are currently unavailable or exhausted.');
};

module.exports = {
    searchSpoonacularRecipes,
};
