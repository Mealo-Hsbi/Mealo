const express = require('express');
const auth = require('../middleware/auth.middleware');
const achievementCtrl = require('../controllers/achievement.controller');

const router = express.Router();

router.get('/', auth, achievementCtrl.getAllAchievementsForUser);

module.exports = router;
