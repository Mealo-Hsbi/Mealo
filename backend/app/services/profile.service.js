// lib/services/profile.service.js

const { PrismaClient } = require('../generated/prisma');
const mediaService = require('./media.service');

const prisma = new PrismaClient();

async function fetchProfile(firebaseUid) {
  // 1) User mit verknüpften Daten laden
  const user = await prisma.users.findUnique({
    where: { firebase_uid: firebaseUid },
    include: {
      user_tags:  { include: { tags: true } },
      recipes:    { orderBy: { created_at: 'desc' }, take: 3 },
      favorites:  true,
      ratings:    true,
      inventory:  true, // <- korrektes Laden der Pantry
    },
  });
  if (!user) throw new Error('User nicht gefunden');

  // 2) Counts berechnen
  const recipesCount   = user.recipes.length;
  const favoritesCount = user.favorites.length;
  const likesCount     = user.ratings.length;
  const pantryCount    = user.inventory.length;

  // 3) Signed URL für Avatar holen
  const avatarUrl = user.avatar_url
    ? await mediaService.getSignedDownloadUrl(user.avatar_url)
    : null;

  // 4) recentRecipes zusammenstellen (Titel + Bild-URL)
  const recentRecipes = await Promise.all(
    user.recipes.map(async (recipe) => ({
      title:    recipe.title,
      imageUrl: recipe.image_url
        ? await mediaService.getSignedDownloadUrl(recipe.image_url)
        : null,
    }))
  );

  // 5) Drei zufällige freigeschaltete Achievements laden
  const unlocked = await prisma.user_achievement.findMany({
    where: { user_id: user.id },
    include: { achievement: true },
  });

  const randomThree = unlocked
    .map((ua) => ua.achievement)
    .sort(() => Math.random() - 0.5)
    .slice(0, 3)
    .map((a) => ({
      key:         a.key,
      title:       a.title,
      description: a.description,
      icon:        a.icon,
    }));

  // 6) DTO zusammenstellen und zurückgeben
  return {
    id:               user.id,
    name:             user.name,
    email:            user.email,
    tags:             user.user_tags.map((ut) => ut.tags.name),
    recipesCount,
    favoritesCount,
    likesCount,
    pantryCount,
    avatarUrl,
    recentRecipes,
    achievements:     randomThree,
  };
}

module.exports = { fetchProfile };
