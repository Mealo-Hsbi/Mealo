// services/recipeManagementService.js
const { PrismaClient } = require('../generated/prisma'); // Pfad ggf. anpassen
const prisma = new PrismaClient();

// Diese Funktion ist wichtig: Sie stellt sicher, dass ein Spoonacular-Rezept
// in UNSERER 'Recipe'-Tabelle existiert, bevor es favorisiert oder bewertet wird.
async function getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular) {
  // Hier könnten Sie auch den spoonacularService aufrufen,
  // falls Sie nicht alle Details im recipeDetailsFromSpoonacular Objekt haben.
  // In diesem Fall wäre es aber besser, wenn der Controller die Details schon besorgt hat.

  return prisma.recipe.upsert({
    where: { spoonacularId: spoonacularId },
    update: {
      // Optional: Update Felder, falls Spoonacular-Details sich ändern könnten
      title: recipeDetailsFromSpoonacular.title,
      imageUrl: recipeDetailsFromSpoonacular.image_url,
      // ... weitere Felder
    },
    create: {
      spoonacularId: spoonacularId,
      title: recipeDetailsFromSpoonacular.title,
      imageUrl: recipeDetailsFromSpoonacular.image_url,
      servings: recipeDetailsFromSpoonacular.servings,
      readyInMinutes: recipeDetailsFromSpoonacular.ready_in_minutes,
      isVegetarian: recipeDetailsFromSpoonacular.vegetarian,
      isVegan: recipeDetailsFromSpoonacular.vegan,
      isGlutenFree: recipeDetailsFromSpoonacular.gluten_free,
      isDairyFree: recipeDetailsFromSpoonacular.dairy_free,
      // ... weitere Felder, die Sie im 'Recipe'-Modell haben
    },
  });
}


// Favoriten-Operationen
async function addFavoriteRecipe(userId, spoonacularId, recipeDetailsFromSpoonacular) {
  const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular);
  return prisma.favorite.create({
    data: {
      userId: userId,
      recipeId: recipe.id,
    },
  });
}

async function removeFavoriteRecipe(userId, recipeId) {
  return prisma.favorite.deleteMany({
    where: {
      userId: userId,
      recipeId: recipeId,
    },
  });
}

async function getFavoriteRecipesForUser(userId) {
  return prisma.favorite.findMany({
    where: { userId: userId },
    include: { recipe: true }, // Laden Sie die Recipe-Details gleich mit
  });
}

async function isRecipeFavoritedByUser(userId, recipeId) {
  const favorite = await prisma.favorite.findUnique({
    where: {
      userId_recipeId: {
        userId: userId,
        recipeId: recipeId,
      },
    },
  });
  return !!favorite; // Gibt true zurück, wenn favorisiert, sonst false
}


// Bewertungs-Operationen
async function addOrUpdateRecipeRating(userId, spoonacularId, ratingScore, recipeDetailsFromSpoonacular) {
  const recipe = await getOrCreateRecipeInDb(spoonacularId, recipeDetailsFromSpoonacular);
  return prisma.recipeRating.upsert({
    where: {
      userId_recipeId: { // Der unique-Constraint auf userId und recipeId
        userId: userId,
        recipeId: recipe.id,
      },
    },
    update: {
      rating: ratingScore,
      updatedAt: new Date(),
    },
    create: {
      userId: userId,
      recipeId: recipe.id,
      rating: ratingScore,
    },
  });
}

async function getUserRecipeRating(userId, recipeId) {
  return prisma.recipeRating.findUnique({
    where: {
      userId_recipeId: {
        userId: userId,
        recipeId: recipeId,
      },
    },
  });
}


module.exports = {
  addFavoriteRecipe,
  removeFavoriteRecipe,
  getFavoriteRecipesForUser,
  isRecipeFavoritedByUser, // Nützlich für den Frontend-Buttonstatus
  addOrUpdateRecipeRating,
  getUserRecipeRating,
};