const { PrismaClient } = require('../generated/prisma');
const mediaService = require('./media.service');

const prisma = new PrismaClient();

async function fetchProfile(firebaseUid) {
  // 1) User mit verknüpften Daten laden
  const user = await prisma.users.findUnique({
    where: { firebase_uid: firebaseUid },
    include: {
      user_tags: { include: { tags: true } },
      recipes: {
        orderBy: { created_at: 'desc' }, // Neueste Rezepte zuerst
        take: 3,                         // Nur die letzten 3
      },
      favorites: true,
      ratings: true,
    },
  });
  
  if (!user) throw new Error('User nicht gefunden');

  // 2) Counts berechnen
  const recipesCount   = user.recipes.length;
  const favoritesCount = user.favorites.length;
  const likesCount     = user.ratings.length;

  // 3) Signed URL für Avatar holen
  const avatarUrl = await mediaService.getSignedDownloadUrl(user.avatar_url);

  // 4) Neu: recentRecipes (Titel + temporäre URL)
  const recentRecipes = await Promise.all(user.recipes.map(async (recipe) => ({
    title: recipe.title,
    imageUrl: recipe.image_url 
      ? await mediaService.getSignedDownloadUrl(recipe.image_url) 
      : null,  // Falls kein Bild vorhanden
  })));

  // 5) DTO zusammenstellen und zurückgeben
  return {
    id             : user.id,
    name           : user.name,
    email          : user.email,
    tags           : user.user_tags.map(ut => ut.tags.name),
    recipesCount,
    favoritesCount,
    likesCount,
    avatarUrl,
    recentRecipes,   // Neu hinzugefügt!
  };
}

module.exports = { fetchProfile };
