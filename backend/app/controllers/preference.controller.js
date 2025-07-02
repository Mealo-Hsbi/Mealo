const preferenceService = require('../services/preference.service');

exports.getAllQuestions = async (req, res, next) => {
  try {
    const questions = await preferenceService.getAllWithOptions();
    res.json(questions);
  } catch (err) {
    next(err);
  }
};

exports.getUserPreferences = async (req, res, next) => {
  try {
    const userId = req.user.id;
    const preferences = await preferenceService.getUserPreferences(userId);
    res.json(preferences);
  } catch (err) {
    console.error('Error fetching user preferences:', err);
    res.status(500).json({ message: 'Error fetching user preferences', error: err.message });
  }
};

exports.saveUserPreferences = async (req, res, next) => {
  try {
    const userId = req.user.id; // ✅ directly from middleware (UUID)
    const { optionKeys } = req.body;

    // Allow empty arrays - users don't need to answer all questions
    if (!Array.isArray(optionKeys)) {
      return res.status(400).json({ message: 'optionKeys must be an array.' });
    }

    await preferenceService.setUserPreferences(userId, optionKeys);
    // Setze Onboarding-Status auf true
    const prisma = require('../prisma');
    await prisma.users.update({
      where: { id: userId },
      data: { has_completed_onboarding: true },
    });
    res.status(204).send();
  } catch (err) {
    console.error('Error saving preferences:', err);
    res.status(500).json({ message: 'Error saving preferences', error: err.message });
  }
};
