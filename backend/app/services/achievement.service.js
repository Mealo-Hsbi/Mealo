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

module.exports = {
  getAchievementsWithStatus
};
