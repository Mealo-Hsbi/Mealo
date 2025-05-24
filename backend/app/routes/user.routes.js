// backend/app/routes/user.routes.js
const express        = require('express');
const router         = express.Router();
const authMiddleware = require('../middleware/auth.middleware');

// Public-Route (z. B. Register / Login) bleibt ohne Auth-Check
router.post('/register', (req, res) => {
  // ... Registrierung über Firebase SDK …
});
router.post('/login', (req, res) => {
  // ... könntest hier den Token zurückgeben, wenn nötig …
});

// Alle folgenden Routes benötigen ein gültiges Firebase-JWT
router.use(authMiddleware);

// GET /api/v1/users/me
// liefert dem Client die gerade eingeloggte Nutzer-Info
router.get('/me', (req, res) => {
  res.json({ user: req.user });
});
module.exports = router;