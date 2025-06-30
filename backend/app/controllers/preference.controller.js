const preferenceService = require('../services/preference.service');

exports.getAllQuestions = async (req, res, next) => {
  try {
    const questions = await preferenceService.getAllWithOptions();
    res.json(questions);
  } catch (err) {
    next(err);
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
    res.status(204).send();
  } catch (err) {
    console.error('Error saving preferences:', err);
    res.status(500).json({ message: 'Error saving preferences', error: err.message });
  }
};
