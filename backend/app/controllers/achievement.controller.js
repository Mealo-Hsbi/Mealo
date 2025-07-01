const achievementService = require('../services/achievement.service');

exports.getAllAchievementsForUser = async (req, res, next) => {
  try {
    const userId = req.user.id; // aus auth.middleware gesetzt
    const achievements = await achievementService.getAchievementsWithStatus(userId);
    res.json(achievements);
  } catch (error) {
    next(error);
  }
};
