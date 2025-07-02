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

exports.generateMealplan = async (req, res) => {
  try {
    const userId = req.user.id;
    const { diet, timeFrame = 'week', targetCalories = 2000 } = req.body;
    
    const generatedPlan = await mealplanService.generateMealplan(userId, {
      diet,
      timeFrame,
      targetCalories
    });
    
    res.json(generatedPlan);
  } catch (err) {
    console.error('generateMealplan error:', err);
    res.status(500).json({ error: 'Failed to generate mealplan' });
  }
}; 