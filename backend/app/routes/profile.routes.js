const express = require('express');
const auth = require('../middleware/auth.middleware');
const { getProfile, updateAvatar } = require('../controllers/profile.controller');

const router = express.Router();

// GET /api/profilescreen
router.get('/profilescreen', auth, getProfile);
router.patch('/profile', auth, updateAvatar);

module.exports = router;
