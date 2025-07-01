const prisma = require('../prisma');
const { startOfWeek, endOfWeek, format } = require('date-fns');
const recipeManagementService = require('./recipeManagementService');

function getMonday(date) {
  const d = new Date(date);
  const day = d.getDay();
  const diff = d.getDate() - day + (day === 0 ? -6 : 1); // adjust when day is sunday
  return new Date(d.setDate(diff));
}

// Hilfsfunktion: Backend-Recipe zu Frontend-RecipeModel-Format
function mapRecipeToFrontend(recipe) {
  if (!recipe) return null;
  // Zutaten mappen
  const usedIngredients = (recipe.recipe_ingredients || []).map(ri => ({
    id: ri.ingredients.id,
    name: ri.ingredients.name,
    imageUrl: ri.ingredients.image || null,
    amount: ri.amount,
    unit: ri.unit,
    original: ri.original,
  }));
  return {
    id: recipe.id,
    internalId: recipe.id,
    isInternal: true,
    name: recipe.title,
    imageUrl: recipe.image_url,
    place: undefined,
    readyInMinutes: recipe.ready_in_minutes,
    servings: recipe.servings,
    calories: undefined,
    protein: undefined,
    fat: undefined,
    carbs: undefined,
    sugar: undefined,
    healthScore: recipe.health_score,
    usedIngredientCount: usedIngredients.length,
    missedIngredientCount: 0,
    usedIngredients,
    missedIngredients: [],
    averageRating: undefined,
    ratingCount: undefined,
    containsUserAllergens: undefined,
    matchedAllergens: undefined,
    spoonacularId: recipe.spoonacular_id,
  };
}

exports.getCurrentMealplan = async (userId) => {
  const today = new Date();
  const weekStart = getMonday(today);
  let plan = await prisma.weekly_plan.findFirst({
    where: { user_id: userId, start_date: weekStart },
    include: { weekly_plan_item: true },
  });
  if (!plan) {
    plan = await prisma.weekly_plan.create({
      data: {
        user_id: userId,
        name: 'Mealplan',
        start_date: weekStart,
      },
      include: { weekly_plan_item: true },
    });
  }
  // Rezepte aus DB holen
  const recipeIds = plan.weekly_plan_item.map(item => item.recipe_id);
  console.log('[Mealplan-Backend] weekly_plan_item:', plan.weekly_plan_item);
  const recipes = await prisma.recipes.findMany({
    where: { id: { in: recipeIds } },
    include: {
      recipe_ingredients: {
        include: { ingredients: true }
      }
    }
  });
  const recipeMap = Object.fromEntries(recipes.map(r => [r.id, r]));
  console.log('[Mealplan-Backend] recipeMap:', recipeMap);
  // Group items by day and mealType, aber mit gemapptem Rezept-Objekt
  const grouped = {};
  for (const item of plan.weekly_plan_item) {
    const dateKey = format(new Date(item.date), 'yyyy-MM-dd');
    if (!grouped[dateKey]) grouped[dateKey] = {};
    grouped[dateKey][item.meal_type] = mapRecipeToFrontend(recipeMap[item.recipe_id]) || null;
  }
  console.log('[Mealplan-Backend] grouped:', grouped);
  return { id: plan.id, start_date: plan.start_date, days: grouped };
};

exports.updateCurrentMealplan = async (userId, planData) => {
  const today = new Date();
  const weekStart = getMonday(today);
  let plan = await prisma.weekly_plan.findFirst({
    where: { user_id: userId, start_date: weekStart },
  });
  if (!plan) {
    plan = await prisma.weekly_plan.create({
      data: {
        user_id: userId,
        name: 'Mealplan',
        start_date: weekStart,
      },
    });
  }
  // Delete all old items
  await prisma.weekly_plan_item.deleteMany({ where: { plan_id: plan.id } });
  // Create new items
  if (Array.isArray(planData.items)) {
    for (const item of planData.items) {
      // Rezept sicherstellen (wie bei Favoriten)
      const recipe = await recipeManagementService.getOrCreateRecipeInDb(
        item.spoonacularId || null,
        item.recipeData || { id: item.recipeId },
        userId
      );
      await prisma.weekly_plan_item.create({
        data: {
          plan_id: plan.id,
          date: new Date(item.date),
          meal_type: item.mealType,
          recipe_id: recipe.id,
        },
      });
    }
  }
  // Return new plan
  const updated = await prisma.weekly_plan.findUnique({
    where: { id: plan.id },
    include: { weekly_plan_item: true },
  });
  // Group items by day and mealType
  const grouped = {};
  for (const item of updated.weekly_plan_item) {
    if (!grouped[item.date]) grouped[item.date] = {};
    grouped[item.date][item.meal_type] = item.recipe_id;
  }
  return { id: updated.id, start_date: updated.start_date, items: grouped };
};

exports.generateMealplan = async (userId, options) => {
  const { diet, timeFrame = 'week', targetCalories = 2000 } = options;
  
  try {
    // Call Spoonacular API to generate mealplan
    const apiKey = process.env.SPOONACULAR_API_KEY;
    const url = `https://api.spoonacular.com/mealplanner/generate?apiKey=${apiKey}&timeFrame=${timeFrame}&targetCalories=${targetCalories}&diet=${diet}`;
    
    console.log(`[Mealplan Generation] Calling Spoonacular API: ${url}`);
    
    const response = await fetch(url);
    if (!response.ok) {
      throw new Error(`Spoonacular API error: ${response.status} ${response.statusText}`);
    }
    
    const data = await response.json();
    console.log('[Mealplan Generation] Spoonacular response:', data);
    
    if (!data.week) {
      throw new Error('No meal plan data received from Spoonacular');
    }
    
    // Clear existing mealplan for current week
    const today = new Date();
    const weekStart = getMonday(today);
    let plan = await prisma.weekly_plan.findFirst({
      where: { user_id: userId, start_date: weekStart },
    });
    
    if (plan) {
      // Delete existing items
      await prisma.weekly_plan_item.deleteMany({ where: { plan_id: plan.id } });
    } else {
      // Create new plan
      plan = await prisma.weekly_plan.create({
        data: {
          user_id: userId,
          name: 'Generated Mealplan',
          start_date: weekStart,
        },
      });
    }
    
    // Process each day of the generated mealplan
    const days = ['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'];
    const mealTypes = ['breakfast', 'lunch', 'dinner'];
    
    for (const day of days) {
      const dayData = data.week[day];
      if (!dayData) continue;
      
      // Calculate date for this day
      const dayIndex = days.indexOf(day);
      const dayDate = new Date(weekStart);
      dayDate.setDate(dayDate.getDate() + dayIndex);
      
      for (const mealType of mealTypes) {
        const meal = dayData.meals?.find(m => m.slot === 1 && mealType === 'breakfast' || 
                                               m.slot === 2 && mealType === 'lunch' || 
                                               m.slot === 3 && mealType === 'dinner');
        
        if (meal) {
          // Get or create recipe in database
          const recipe = await recipeManagementService.getOrCreateRecipeInDb(
            meal.id,
            {
              id: meal.id,
              title: meal.title,
              image_url: meal.image,
              ready_in_minutes: meal.readyInMinutes,
              servings: meal.servings,
              health_score: meal.healthScore,
            },
            userId
          );
          
          // Create mealplan item
          await prisma.weekly_plan_item.create({
            data: {
              plan_id: plan.id,
              date: dayDate,
              meal_type: mealType.toUpperCase(),
              recipe_id: recipe.id,
            },
          });
        }
      }
    }
    
    // Return the generated mealplan
    return await exports.getCurrentMealplan(userId);
    
  } catch (error) {
    console.error('[Mealplan Generation] Error:', error);
    throw new Error(`Failed to generate mealplan: ${error.message}`);
  }
}; 