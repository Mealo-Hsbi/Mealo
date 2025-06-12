const express = require('express');
const auth = require('../middleware/auth.middleware');
const preferenceCtrl = require('../controllers/preference.controller');

const router = express.Router();

router.get('/', auth, preferenceCtrl.getAllQuestions);
router.post('/', auth, preferenceCtrl.saveUserPreferences);

module.exports = router;
