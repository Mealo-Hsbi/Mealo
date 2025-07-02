const prisma = require('../prisma');
const { startOfWeek, endOfWeek, format } = require('date-fns');
const recipeManagementService = require('./recipeManagementService');
const { makeSpoonacularApiCall } = require('./spoonacularService');

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
    imageUrl: recipe.image_url, // Das ist korrekt - Backend verwendet image_url
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
  // console.log('[Mealplan-Backend] weekly_plan_item:', plan.weekly_plan_item);
  const recipes = await prisma.recipes.findMany({
    where: { id: { in: recipeIds } },
    include: {
      recipe_ingredients: {
        include: { ingredients: true }
      }
    }
  });
  const recipeMap = Object.fromEntries(recipes.map(r => [r.id, r]));
  //console.log('[Mealplan-Backend] recipeMap:', recipeMap);
  // Group items by day and mealType, aber mit gemapptem Rezept-Objekt
  const grouped = {};
  for (const item of plan.weekly_plan_item) {
    const dateKey = format(new Date(item.date), 'yyyy-MM-dd');
    if (!grouped[dateKey]) grouped[dateKey] = {};
    grouped[dateKey][item.meal_type] = mapRecipeToFrontend(recipeMap[item.recipe_id]) || null;
  }
  // console.log('[Mealplan-Backend] grouped:', grouped);
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
    // Call Spoonacular API to generate mealplan using our helper function
    const url = 'https://api.spoonacular.com/mealplanner/generate';
    const params = {
      timeFrame: timeFrame,
      targetCalories: targetCalories,
      ...(diet && { diet: diet }), // Only include diet if it's provided
    };
    
    //console.log(`[Mealplan Generation] Calling Spoonacular API with params:`, params);
    
    const response = await makeSpoonacularApiCall(url, params);
    const data = response.data;
    
    //console.log('[Mealplan Generation] Spoonacular response received');
    //console.log('[Mealplan Generation] Response data structure:', JSON.stringify(data, null, 2));
    
    // Check for different possible response structures
    if (!data.week && !data.meals && !data.items) {
      console.error('[Mealplan Generation] No meal plan data in response. Full response:', data);
      throw new Error('No meal plan data received from Spoonacular');
    }
    
    // Handle different response formats
    let weekData = data.week;
    if (!weekData && data.meals) {
      // If response has meals directly, create a week structure
      weekData = {
        monday: { meals: data.meals },
        tuesday: { meals: data.meals },
        wednesday: { meals: data.meals },
        thursday: { meals: data.meals },
        friday: { meals: data.meals },
        saturday: { meals: data.meals },
        sunday: { meals: data.meals },
      };
    }
    
    if (!weekData) {
      console.error('[Mealplan Generation] Could not extract week data from response:', data);
      throw new Error('Invalid meal plan data structure received from Spoonacular');
    }
    
    // First, prepare the plan and collect all meals
    const today = new Date();
    const weekStart = getMonday(today);
    // console.log('[Mealplan Generation] Today:', today);
    // console.log('[Mealplan Generation] Week start (Monday):', weekStart);
    // console.log('[Mealplan Generation] Week start formatted:', format(weekStart, 'yyyy-MM-dd'));
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
    const mealplanItems = [];
    
    for (const day of days) {
      const dayData = weekData[day];
      if (!dayData) continue;
      
      // Calculate date for this day
      const dayIndex = days.indexOf(day);
      const dayDate = new Date(weekStart);
      dayDate.setDate(dayDate.getDate() + dayIndex);
      
      // console.log(`[Mealplan Generation] Processing ${day} with data:`, dayData);
      
      for (const mealType of mealTypes) {
        // Try different ways to find the meal based on the API response structure
        let meal = null;
        
        if (dayData.meals && Array.isArray(dayData.meals)) {
          // Try to find by slot number
          meal = dayData.meals.find(m => 
            (m.slot === 1 && mealType === 'breakfast') || 
            (m.slot === 2 && mealType === 'lunch') || 
            (m.slot === 3 && mealType === 'dinner')
          );
        }
        
        // If not found by slot, try to find by meal type directly
        if (!meal && dayData.meals && Array.isArray(dayData.meals)) {
          meal = dayData.meals.find(m => 
            m.title && m.title.toLowerCase().includes(mealType.toLowerCase())
          );
        }
        
        // If still not found, try to find by position in array
        if (!meal && dayData.meals && Array.isArray(dayData.meals)) {
          const mealIndex = mealTypes.indexOf(mealType);
          if (mealIndex < dayData.meals.length) {
            meal = dayData.meals[mealIndex];
          }
        }
        
        // console.log(`[Mealplan Generation] Found meal for ${mealType}:`, meal);
        
        if (meal) {
          try {
            // console.log(`[Mealplan Generation] Processing meal:`, meal);
            // console.log(`[Mealplan Generation] Meal image:`, meal.image);
            
            // Build image URL manually using the consistent Spoonacular pattern
            // Always use our manual URL format since the API might return different formats
            const imageUrl = `https://img.spoonacular.com/recipes/${meal.id}-312x231.jpg`;
            // console.log(`[Mealplan Generation] Original meal.image:`, meal.image);
            // console.log(`[Mealplan Generation] Using manual image URL:`, imageUrl);
            
            // Get or create recipe in database (this can take time due to API calls)
            const recipe = await recipeManagementService.getOrCreateRecipeInDb(
              meal.id,
              {
                id: meal.id,
                title: meal.title,
                imageUrl: imageUrl,  // Use our manually built URL with correct field name
                readyInMinutes: meal.readyInMinutes,  // Fixed: use camelCase
                servings: meal.servings,
                healthScore: meal.healthScore,  // Fixed: use camelCase
              },
              userId
            );
            // console.log(`[Mealplan Generation] Saved recipe image_url:`, recipe.image_url);
            
            // Collect mealplan item for batch insert
            mealplanItems.push({
              plan_id: plan.id,
              date: dayDate,
              meal_type: mealType.toUpperCase(),
              recipe_id: recipe.id,
            });
            
            // console.log(`[Mealplan Generation] Successfully prepared ${meal.title} for ${day} ${mealType}`);
          } catch (recipeError) {
            console.error(`[Mealplan Generation] Error processing recipe for ${day} ${mealType}:`, recipeError);
          }
        } else {
          // console.log(`[Mealplan Generation] No meal found for ${day} ${mealType}`);
        }
      }
    }
    
    // Now insert all mealplan items in a single transaction
    if (mealplanItems.length > 0) {
      await prisma.$transaction(async (tx) => {
        await tx.weekly_plan_item.createMany({
          data: mealplanItems,
        });
      });
      // console.log(`[Mealplan Generation] Successfully inserted ${mealplanItems.length} mealplan items`);
    }
    
    // Return the generated mealplan
    return await exports.getCurrentMealplan(userId);
    
  } catch (error) {
    console.error('[Mealplan Generation] Error:', error);
    throw new Error(`Failed to generate mealplan: ${error.message}`);
  }
};
    
 