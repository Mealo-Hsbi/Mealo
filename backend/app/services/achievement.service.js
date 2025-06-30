const prisma = require('../prisma');

async function getAchievementsWithStatus(userId) {
  const allAchievements = await prisma.achievement.findMany({
    orderBy: { created_at: 'asc' }
  });

  const unlockedAchievements = await prisma.user_achievement.findMany({
    where: { user_id: userId },
    select: { achievement_id: true }
  });

  const unlockedSet = new Set(unlockedAchievements.map(a => a.achievement_id));

  return allAchievements.map(a => ({
    id: a.id,
    key: a.key,
    title: a.title,
    description: a.description,
    icon: a.icon,
    unlocked: unlockedSet.has(a.id)
  }));
}

// Hilfsfunktion zum Freischalten eines Achievements
async function unlockAchievementIfNeeded(userId, achievementKey) {
  const achievement = await prisma.achievement.findUnique({ where: { key: achievementKey } });
  if (!achievement) return;

  const alreadyUnlocked = await prisma.user_achievement.findUnique({
    where: { user_id_achievement_id: { user_id: userId, achievement_id: achievement.id } }
  });
  if (alreadyUnlocked) return;

  await prisma.user_achievement.create({
    data: {
      user_id: userId,
      achievement_id: achievement.id
    }
  });
}

module.exports = {
  getAchievementsWithStatus,
  unlockAchievementIfNeeded
};
