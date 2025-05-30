const express = require('express');
const auth = require('../middleware/auth.middleware');
const { getProfile } = require('../controllers/profile.controller');

const router = express.Router();

// GET /api/profilescreen
router.get('/profilescreen', auth, getProfile);

module.exports = router;
