// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');

const SPOONACULAR_COMPLEX_SEARCH_BASE_URL = 'https://api.spoonacular.com/recipes/complexSearch';
const SPOONACULAR_FIND_BY_INGREDIENTS_BASE_URL = 'https://api.spoonacular.com/recipes/findByIngredients';
const SPOONACULAR_RECIPE_INFO_BASE_URL = 'https://api.spoonacular.com/recipes';

let currentKeyIndex = 0;

const findNutrientValue = (nutrients, title) => {
    if (!nutrients) return null;
    const nutrient = nutrients.find(n => n.name === title);
    return nutrient ? nutrient.amount : null;
};

// Helper function to handle API key rotation and Axios calls
const makeSpoonacularApiCall = async (url, params) => {
    let retries = 0;
    const maxRetries = spoonacularKeys.length;

    while (retries < maxRetries) {
        currentKeyIndex = currentKeyIndex % spoonacularKeys.length;
        const currentKey = spoonacularKeys[currentKeyIndex];
        params.apiKey = currentKey; // Assign current key to params

        // Clean up undefined params before sending
        Object.keys(params).forEach(key => params[key] === undefined && delete params[key]);

        try {
            const response = await axios.get(url, {
                params: params,
                timeout: 10000 // Timeout for the Axios call
            });
            return response;
        } catch (axiosError) {
            console.error(`[BACKEND DEBUG - SERVICE] Axios error during Spoonacular call to ${url}: ${axiosError.message}`);
            if (axiosError.response) {
                console.error('[BACKEND DEBUG - SERVICE] Axios response error data:', axiosError.response.data);
                console.error('[BACKEND DEBUG - SERVICE] Axios response status:', axiosError.response.status);
                if (axiosError.response.status === 402 || axiosError.response.status === 429) {
                    console.warn(`[BACKEND DEBUG - SERVICE] Spoonacular API Key ${currentKey} exhausted or rate-limited. Trying next key.`);
                    currentKeyIndex = (currentKeyIndex + 1) % spoonacularKeys.length;
                    retries++;
                    continue; // Retry with next key
                }
            } else if (axiosError.code === 'ECONNABORTED' || axiosError.code === 'ETIMEDOUT') {
                console.error('[BACKEND DEBUG - SERVICE] Axios Timeout/Connection error to Spoonacular.');
            }
            throw axiosError; // Re-throw other errors
        }
    }
    throw new Error('All Spoonacular API keys attempted and failed for this request.');
};


// 1. Funktion für die Textsuche (Query-basiert)
const searchRecipesByQuery = async ({
    query,
    offset,
    number,
    filters,
    sortBy,
    sortDirection,
}) => {
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        throw new Error('Server configuration error: Spoonacular API keys are missing.');
    }
    if (!query || query.trim().length === 0) {
        throw { status: 400, message: 'Query parameter is required for text search.' };
    }

    const spoonacularParams = {
        query: query,
        offset: offset,
        number: number,
        addRecipeInformation: true, // Um servings, readyInMinutes etc. zu erhalten
        addRecipeNutrition: true,    // Um Nährwerte zu erhalten
        fillIngredients: true,       // Um used/missedIngredientCount zu erhalten
        // ComplexSearch unterstützt ranking auch, aber der Fokus ist hier anders
        // ranking: 1, // Optional: "Match best"
    };

    // Filter und Sortierung für ComplexSearch
    if (filters?.minCalories) spoonacularParams.minCalories = filters.minCalories;
    if (filters?.maxCalories) spoonacularParams.maxCalories = filters.maxCalories;
    if (filters?.diet) spoonacularParams.diet = filters.diet;
    if (filters?.intolerances) spoonacularParams.intolerances = filters.intolerances;

    if (sortBy) spoonacularParams.sort = sortBy;
    if (sortDirection) spoonacularParams.sortDirection = sortDirection;

    console.log('--- Backend Spoonacular Service Debug (Query Search) ---');
    console.log('Received parameters for query search:', { query, offset, number, filters, sortBy, sortDirection });
    console.log('Constructed Spoonacular parameters:', spoonacularParams);
    console.log('-----------------------------------------------------');

    const response = await makeSpoonacularApiCall(SPOONACULAR_COMPLEX_SEARCH_BASE_URL, spoonacularParams);

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
};


// 2. Funktion für die Zutatensuche (findByIngredients-basiert)
const searchRecipesByIngredients = async ({
    ingredients, // Array von Strings
    offset,
    number,
    maxMissingIngredients, // Max. fehlende Zutaten
    // HINWEIS: sortBy, sortDirection und Filter für Nährwerte werden hier NICHT unterstützt!
    // findByIngredients hat nur "ranking" als Sortieroption.
    // Wenn Nährwert-Sortierung hier benötigt wird, müsstest du eine POST-Filterung / Sortierung im Backend vornehmen
    // (was bei vielen Ergebnissen ineffizient sein kann) oder einen zweiten Call pro Rezept machen.
    // Für dieses Beispiel lassen wir sie weg.
}) => {
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        throw new Error('Server configuration error: Spoonacular API keys are missing.');
    }
    if (!ingredients || ingredients.length === 0) {
        throw { status: 400, message: 'Ingredients array is required for ingredient search.' };
    }

    const spoonacularParams = {
        ingredients: ingredients.join(','),
        offset: offset,
        number: number,
        ranking: 2, // Priorisiert Rezepte mit den wenigsten fehlenden Zutaten
        ignorePantry: true, // Um genauere used/missed counts zu erhalten
    };

    if (maxMissingIngredients !== undefined) {
        spoonacularParams.maxMissingIngredients = maxMissingIngredients;
    } else {
        spoonacularParams.maxMissingIngredients = 10; // Standardwert
    }

    console.log('--- Backend Spoonacular Service Debug (Ingredient Search) ---');
    console.log('Received parameters for ingredient search:', { ingredients, offset, number, maxMissingIngredients });
    console.log('Constructed Spoonacular parameters:', spoonacularParams);
    console.log('---------------------------------------------------------');

    const response = await makeSpoonacularApiCall(SPOONACULAR_FIND_BY_INGREDIENTS_BASE_URL, spoonacularParams);

    // findByIngredients gibt direkt ein Array von Rezepten zurück
    const recipes = response.data.map(recipe => {
        // HINWEIS: Nährwerte, servings, readyInMinutes, healthScore sind HIER NICHT ENTHALTEN!
        // Sie müssten über einen ZWEITEN API-Call (getSpoonacularRecipeDetails) pro Rezept nachgeladen werden,
        // was SEHR ineffizient ist und dein API-Kontingent sprengt.
        // Das Frontend muss damit umgehen, dass diese Felder hier undefined sind.
        return {
            id: recipe.id,
            name: recipe.title,
            imageUrl: recipe.image,
            imageType: recipe.imageType,
            // Diese Felder sind hier typischerweise NICHT vorhanden.
            servings: undefined,
            readyInMinutes: undefined,
            place: undefined,
            calories: undefined,
            protein: undefined,
            fat: undefined,
            carbs: undefined,
            sugar: undefined,
            healthScore: undefined,
            // Diese sind vorhanden:
            usedIngredientCount: recipe.usedIngredientCount,
            missedIngredientCount: recipe.missedIngredientCount,
            usedIngredients: recipe.usedIngredients,
            missedIngredients: recipe.missedIngredients,
        };
    });

    return recipes;
};


// getSpoonacularRecipeDetails bleibt unverändert
const getSpoonacularRecipeDetails = async (recipeId) => {
    if (!spoonacularKeys || spoonacularKeys.length === 0) {
        throw new Error('Server configuration error: Spoonacular API keys are missing.');
    }

    const spoonacularParams = {
        includeNutrition: true, // Wichtig: Auch hier Nährwertinfos anfordern!
    };

    const response = await makeSpoonacularApiCall(
        `${SPOONACULAR_RECIPE_INFO_BASE_URL}/${recipeId}/information`,
        spoonacularParams
    );

    const recipe = response.data; // Die Antwort ist direkt das Rezeptobjekt

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
};

module.exports = {
    searchRecipesByQuery,
    searchRecipesByIngredients,
    getSpoonacularRecipeDetails,
};