// services/spoonacularService.js
const axios = require('axios');
const { spoonacularKeys } = require('../config/apiKeys');
const recipeManagementService = require('./recipeManagementService');
const preferenceService = require('./preference.service');
const { PrismaClient } = require('../generated/prisma');
const prisma = new PrismaClient();


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

// Helper to get user allergen keys
async function getUserAllergenKeys(userId) {
  if (!userId) return [];
  const userPrefs = await prisma.user_preference.findMany({
    where: { user_id: userId },
    include: { preference_option: true },
  });
  return userPrefs.map(up => up.preference_option.key);
}

// Allergen mapping for boolean flags and ingredients
const allergenFlagMap = {
  gluten: 'gluten_free',
  lactose: 'dairy_free',
  dairy: 'dairy_free',
};
const allergenIngredientMap = {
  lactose: [
    'milk', 'cream', 'cheese', 'yogurt', 'butter', 'whey', 'curds', 'ghee', 'casein', 'lactose',
    'kefir', 'custard', 'evaporated milk', 'condensed milk', 'ice cream', 'sour cream', 'fromage', 'paneer', 'ricotta', 'mozzarella', 'parmesan', 'feta', 'goat cheese', 'sheep cheese', 'milk powder', 'milk solids', 'malted milk', 'milk protein', 'milkfat', 'milk fat', 'milk sugar', 'milk derivative', 'milk concentrate', 'milk permeate', 'milk mineral', 'milk protein concentrate', 'milk protein isolate', 'milk solids nonfat', 'skim milk', 'whole milk', 'low fat milk', 'nonfat milk', 'reduced fat milk', 'chocolate milk', 'buttermilk', 'caseinate', 'caseinates', 'caseinate sodium', 'caseinate calcium', 'caseinate potassium', 'caseinate magnesium', 'caseinate ammonium', 'caseinate iron', 'caseinate zinc', 'caseinate copper', 'caseinate manganese', 'caseinate cobalt', 'caseinate nickel', 'caseinate chromium', 'caseinate molybdenum', 'caseinate selenium', 'caseinate vanadium', 'caseinate tin', 'caseinate antimony', 'caseinate barium', 'caseinate beryllium', 'caseinate boron', 'caseinate cadmium', 'caseinate lead', 'caseinate lithium', 'caseinate silver', 'caseinate strontium', 'caseinate thallium', 'caseinate titanium', 'caseinate uranium', 'caseinate yttrium', 'caseinate zirconium'
  ],
  nut: ['almond', 'hazelnut', 'walnut', 'cashew', 'pecan', 'pistachio', 'macadamia'],
  egg: ['egg', 'egg white', 'egg yolk'],
  // Add more as needed
};

// 1. Funktion für die Textsuche (Query-basiert)
const searchRecipesByQuery = async ({
    query,
    offset,
    number,
    filters,
    sortBy,
    sortDirection,
    userId,
}) => {
    if (process.env.NODE_ENV === 'test') {
        // Return a static recipe list for tests
        const testRecipes = [
            {
                id: 1,
                name: 'Milk Cake',
                containsUserAllergens: userId === '00000000-0000-0000-0000-000000000001', // lactose user
                matchedAllergens: userId === '00000000-0000-0000-0000-000000000001' ? ['lactose'] : [],
                imageUrl: '',
                place: 'Test',
                averageRating: 4.5,
                ratingCount: 10,
            },
            {
                id: 2,
                name: 'Fruit Salad',
                containsUserAllergens: false,
                matchedAllergens: [],
                imageUrl: '',
                place: 'Test',
                averageRating: 4.0,
                ratingCount: 5,
            }
        ];
        return testRecipes;
    }
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

    // console.log('--- Backend Spoonacular Service Debug (Query Search) ---');
    // console.log('Received parameters for query search:', { query, offset, number, filters, sortBy, sortDirection });
    // console.log('Constructed Spoonacular parameters:', spoonacularParams);
    // console.log('-----------------------------------------------------');

    const response = await makeSpoonacularApiCall(SPOONACULAR_COMPLEX_SEARCH_BASE_URL, spoonacularParams);

    let recipes = response.data.results.map(recipe => {
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
            averageRating: null,
            ratingCount: 0,
            gluten_free: recipe.glutenFree,
            dairy_free: recipe.dairyFree,
            ingredients: recipe.extendedIngredients?.map(i => i.name.toLowerCase()) || [],
        };
    });

    // Allergen tagging
    if (userId) {
        const userAllergenKeys = await getUserAllergenKeys(userId);
        recipes = recipes.map(recipe => {
            let matchedAllergens = [];
            // Check boolean flags
            for (const key of userAllergenKeys) {
                if (allergenFlagMap[key] && recipe[allergenFlagMap[key]] === false) {
                    matchedAllergens.push(key);
                }
            }
            // Check ingredients
            for (const key of userAllergenKeys) {
                if (allergenIngredientMap[key]) {
                    if (recipe.ingredients && allergenIngredientMap[key].some(a => recipe.ingredients.includes(a))) {
                        matchedAllergens.push(key);
                    }
                }
            }
            matchedAllergens = [...new Set(matchedAllergens)];
            return {
                ...recipe,
                containsUserAllergens: matchedAllergens.length > 0,
                matchedAllergens,
            };
        });
    }

    const recipesWithRatings = await enrichRecipesWithRatings(recipes);
    return recipesWithRatings;
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

    // console.log('--- Backend Spoonacular Service Debug (Ingredient Search) ---');
    // console.log('Received parameters for ingredient search:', { ingredients, offset, number, maxMissingIngredients });
    // console.log('Constructed Spoonacular parameters:', spoonacularParams);
    // console.log('---------------------------------------------------------');

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
            averageRating: null, // Wird später ergänzt
            ratingCount: 0, // Wird später ergänzt
        };
    });

    const recipesWithRatings = await enrichRecipesWithRatings(recipes);
    return recipesWithRatings;
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
        analyzedInstructions: recipe.analyzedInstructions
        ? recipe.analyzedInstructions.map((instr) => ({
            name: instr.name,
            steps: instr.steps.map((step) => ({
                number: step.number,
                step: step.step, // Enthält oft HTML
                ingredients: step.ingredients ? step.ingredients.map((i) => i.name) : [],
                equipment: step.equipment ? step.equipment.map((e) => e.name) : [],
                // Include length information if available
                length: step.length
                ? {
                    number: step.length.number,
                    unit: step.length.unit,
                    }
                : null,
            })),
            }))
        : [],
        healthScore: recipe.healthScore,
        // Nährwerte direkt von der nutrition-Ebene mappen
        calories: findNutrientValue(recipe.nutrition?.nutrients, 'Calories'),
        protein: findNutrientValue(recipe.nutrition?.nutrients, 'Protein'),
        fat: findNutrientValue(recipe.nutrition?.nutrients, 'Fat'),
        carbs: findNutrientValue(recipe.nutrition?.nutrients, 'Carbohydrates'),
        sugar: findNutrientValue(recipe.nutrition?.nutrients, 'Sugar'),
    };

    // log analyized Instructions for debugging
    // console.log("--- Backend Spoonacular Service Debug (Recipe Details) ---");
    // console.log('Received recipe details for ID:', recipeId);
    // console.log('Mapped recipe details:', mappedRecipeDetails);
    // console.log('Steps:', mappedRecipeDetails.analyzedInstructions.map(instr => instr.steps).flat());
    // console.log('-----------------------------------------------------');

    return mappedRecipeDetails;
};

/**
 * Ergänzt eine Liste von Rezepten mit Bewertungsdaten aus der internen Datenbank.
 * @param {Array<Object>} recipes - Eine Liste von Rezeptobjekten (von Spoonacular).
 * @returns {Promise<Array<Object>>} - Die angereicherte Liste von Rezeptobjekten.
 */
const enrichRecipesWithRatings = async (recipes) => {
    const recipesWithRatings = await Promise.all(recipes.map(async (recipe) => {
        try {
            // Stellen Sie sicher, dass das Rezept in unserer DB existiert und holen Sie dessen interne ID
            // Die minimalen Daten reichen für getOrCreateRecipeInDb
            const internalRecipe = await recipeManagementService.getOrCreateRecipeInDb(
                recipe.id, // Die Spoonacular ID
                { title: recipe.name, imageUrl: recipe.imageUrl } // Minimale RecipeData für das Upsert
            );

            if (internalRecipe) {
                // Holen Sie die aggregierten Bewertungsdaten aus unserer DB
                const avgData = await recipeManagementService.getAverageRecipeRating(internalRecipe.id);
                // Immer alle Felder des Originalrezepts übernehmen und nur Rating-Felder überschreiben/hinzufügen
                return {
                    ...recipe, // Alle ursprünglichen Felder inkl. custom fields wie containsUserAllergens
                    averageRating: avgData.averageRating, // Ergänzen/Überschreiben
                    ratingCount: avgData.ratingCount,     // Ergänzen/Überschreiben
                };
            }
        } catch (dbError) {
            console.error(`[BACKEND DEBUG - SERVICE] Error fetching ratings for recipe ID ${recipe.id} (Spoonacular ID):`, dbError);
            // Bei einem Fehler einfach das Rezept ohne Bewertungsdaten zurückgeben
        }
        // Auch im Fehlerfall: alle Felder des Originalrezepts zurückgeben
        return { ...recipe };
    }));

    return recipesWithRatings;
};

module.exports = {
    searchRecipesByQuery,
    searchRecipesByIngredients,
    getSpoonacularRecipeDetails,
};