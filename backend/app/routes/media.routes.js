const express = require('express');
const auth    = require('../middleware/auth.middleware');
const mediaCtrl = require('../controllers/media.controller');

const router = express.Router();

// Falls Upload/Download nur für authentifizierte User gilt, häng auth() dran
router.post('/media/upload-url', auth, mediaCtrl.uploadUrl);
router.get('/media/download-url', auth, mediaCtrl.downloadUrl);

module.exports = router;
