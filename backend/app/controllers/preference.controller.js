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
    const userId = req.user.id; // ✅ direkt aus Middleware (UUID)
    const { optionKeys } = req.body;

    if (!Array.isArray(optionKeys) || optionKeys.length === 0) {
      return res.status(400).json({ message: 'Keine Optionen übermittelt.' });
    }

    await preferenceService.setUserPreferences(userId, optionKeys);
    res.status(204).send();
  } catch (err) {
    console.error('Fehler beim Speichern der Präferenzen:', err);
    res.status(500).json({ message: 'Fehler beim Speichern der Präferenzen', error: err.message });
  }
};
