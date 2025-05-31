// routes/recipeSearch.js
const express = require('express');
const router = express.Router();
const recipeController = require('../controllers/recipeController'); // Import the controller

router.post('/search', recipeController.searchRecipes); // Map the route to the controller function

// If you have a details route for recipes, it would also go here:
// const recipeDetailsController = require('../controllers/recipeDetailsController');
// router.get('/:id/details', recipeDetailsController.getRecipeDetails);

module.exports = router;