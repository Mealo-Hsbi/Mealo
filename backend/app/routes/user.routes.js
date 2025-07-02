// backend/app/routes/user.routes.js

const express        = require('express');
const admin          = require('../firebase.js');
const prisma         = require('../prisma');
const authMiddleware = require('../middleware/auth.middleware');

const router = express.Router();

// Registrierung / Upsert
router.post('/register', async (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    if (!authHeader?.startsWith('Bearer ')) {
      return res.status(401).json({ message: 'Unauthorized' });
    }
    const idToken = authHeader.split(' ')[1];
    const decoded = await admin.auth().verifyIdToken(idToken);

    const { name } = req.body;
    const PLACEHOLDER_KEY = 'profile-pictures/profile_placeholder.png';

    // Prüfen, ob Nutzer bereits in DB existiert
    const userExists = await prisma.users.findUnique({
      where: { firebase_uid: decoded.uid },
    });

    let user;

    if (userExists) {
      // Nur den Namen aktualisieren, avatar_url nicht überschreiben
      user = await prisma.users.update({
        where: { firebase_uid: decoded.uid },
        data: { name },
      });
    } else {
      // Nutzer neu anlegen mit Platzhalter-Profilbild
      user = await prisma.users.create({
        data: {
          firebase_uid: decoded.uid,
          email      : decoded.email,
          name       : name,
          avatar_url : PLACEHOLDER_KEY,
        },
      });
    }

    res.status(201).json(user);
  } catch (err) {
    next(err);
  }
});

router.post('/login', (req, res) => {
  res.status(200).json({ token: 'fake-jwt-token' });
});

// Ab hier gelten alle Routen nur, wenn authMiddleware durchgelaufen ist
router.use(authMiddleware);

// GET /api/me  → Profil des eingeloggten Nutzers
router.get('/me', async (req, res, next) => {
  try {
    const { id } = req.user; // wird von authMiddleware gesetzt (UUID)
    const user = await prisma.users.findUnique({
      where: { id },
      include: { user_tags: { include: { tags: true } } },
    });
    if (!user) return res.sendStatus(404);
    res.json(user);
  } catch (err) {
    next(err);
  }
});

// GET /api/user/premium → Gibt den Premium-Status zurück
router.get('/premium', async (req, res, next) => {
  try {
    const { firebase_uid } = req.user;
    const user = await prisma.users.findUnique({
      where: { firebase_uid },
      select: { isPremium: true },
    });
    if (!user) return res.sendStatus(404);
    res.json({ isPremium: user.isPremium });
  } catch (err) {
    next(err);
  }
});

// POST /api/user/premium → Setzt Premium auf true (simuliert Kauf)
router.post('/premium', async (req, res, next) => {
  try {
    const { firebase_uid } = req.user;
    const user = await prisma.users.update({
      where: { firebase_uid },
      data: { isPremium: true },
      select: { isPremium: true },
    });
    res.json({ isPremium: user.isPremium });
  } catch (err) {
    next(err);
  }
});

// DELETE /api/user/premium → Setzt Premium auf false (Kündigung)
router.delete('/premium', async (req, res, next) => {
  try {
    const { firebase_uid } = req.user;
    const user = await prisma.users.update({
      where: { firebase_uid },
      data: { isPremium: false },
      select: { isPremium: true },
    });
    res.json({ isPremium: user.isPremium });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
