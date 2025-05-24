// backend/app/routes/user.routes.js
const express        = require('express');
const router         = express.Router();
const authMiddleware = require('../middleware/auth.middleware');

router.post('/register', (req, res) => {
  // ### STUB ###
  return res.status(201).json({ message: 'User registered (stub)' });
});
router.post('/login', (req, res) => {
  // ### STUB ###
  return res.status(200).json({ token: 'fake-jwt-token' });
});


// Alle folgenden Routes benötigen ein gültiges Firebase-JWT
router.use(authMiddleware);

// GET /api/v1/users/me
// liefert dem Client die gerade eingeloggte Nutzer-Info
router.get('/me', (req, res) => {
  res.json({ user: req.user });
});
module.exports = router;