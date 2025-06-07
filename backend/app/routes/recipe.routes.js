// routes/recipeSearch.js
const express = require('express');
const router = express.Router();
const { searchRecipes, getRecipeDetails } = require('../controllers/recipeController'); // Import the controller

router.post('/search', searchRecipes); // Map the route to the controller function
router.get('/:id', getRecipeDetails);
// If you have a details route for recipes, it would also go here:
// const recipeDetailsController = require('../controllers/recipeDetailsController');
// router.get('/:id/details', recipeDetailsController.getRecipeDetails);

module.exports = router;