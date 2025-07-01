const mealplanService = require('../services/mealplan.service');

exports.getCurrentMealplan = async (req, res) => {
  try {
    const userId = req.user.id;
    const plan = await mealplanService.getCurrentMealplan(userId);
    res.json(plan);
  } catch (err) {
    console.error('getCurrentMealplan error:', err);
    res.status(500).json({ error: 'Failed to fetch mealplan' });
  }
};

exports.updateCurrentMealplan = async (req, res) => {
  try {
    const userId = req.user.id;
    const planData = req.body;
    const updated = await mealplanService.updateCurrentMealplan(userId, planData);
    res.json(updated);
  } catch (err) {
    console.error('updateCurrentMealplan error:', err);
    res.status(500).json({ error: 'Failed to update mealplan' });
  }
}; 