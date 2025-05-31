// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');

const SPOONACULAR_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';

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
                // --- REMOVED THESE PARAMETERS FOR BASIC SEARCH LIST ---
                // addRecipeInformation: true,
                // fillIngredients: true,
                // ---------------------------------------------------
                minCalories: filters?.minCalories,
                maxCalories: filters?.maxCalories,
                diet: filters?.diet,
                intolerances: filters?.intolerances,
                sort: sortBy,
                sortDirection: sortDirection,
            };

            Object.keys(spoonacularParams).forEach(key => spoonacularParams[key] === undefined && delete spoonacularParams[key]);

            console.log(`[BACKEND DEBUG] Sending request to Spoonacular with params:`, spoonacularParams);

            const response = await axios.get(SPOONACULAR_BASE_URL, {
                params: spoonacularParams
            });

            // --- IMPORTANT LOGS START HERE ---
            console.log(`[BACKEND DEBUG] Raw Spoonacular API Response Data (results array):`);
            if (response.data && response.data.results && response.data.results.length > 0) {
                console.log(`[BACKEND DEBUG] First Spoonacular Result:`, response.data.results[0]);
            } else {
                console.log(`[BACKEND DEBUG] Spoonacular returned no results or empty results array.`);
            }
            // --- IMPORTANT LOGS END HERE ---

            const recipes = response.data.results.map(recipe => ({
                id: recipe.id,
                name: recipe.title,
                imageUrl: recipe.image,
                imageType: recipe.imageType,
                // Note: servings, readyInMinutes, sourceName might still be available even without
                // addRecipeInformation: true for basic search. You'll need to confirm with logs.
                servings: recipe.servings, // Keep if available in basic search
                readyInMinutes: recipe.readyInMinutes, // Keep if available in basic search
                place: recipe.sourceName, // Keep if available in basic search
            }));

            console.log(`[BACKEND DEBUG] Transformed Recipes (sent to Flutter):`);
            if (recipes.length > 0) {
                console.log(`[BACKEND DEBUG] First Transformed Recipe:`, recipes[0]);
            } else {
                console.log(`[BACKEND DEBUG] Transformed recipes array is empty.`);
            }

            return recipes;

        } catch (error) {
            console.error(`Error searching recipes with key ${currentKey}:`, error.message);
            if (error.response && (error.response.status === 402 || error.response.status === 429)) {
                console.warn(`Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`);
                currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                retries++;
            } else {
                console.error('[BACKEND DEBUG] Non-quota related Spoonacular API error details:', error.response ? error.response.data : error.message);
                const statusCode = error.response ? error.response.status : 500;
                const errorMessage = error.response && error.response.data ? error.response.data : { message: 'Failed to search recipes from external API.' };
                throw { status: statusCode, message: errorMessage.message || 'External API error' };
            }
        }
    }

    throw new Error('All Spoonacular API keys are currently unavailable or exhausted.');
};

module.exports = {
    searchSpoonacularRecipes,
};