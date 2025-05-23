// backend/app/middleware/auth.middleware.js
const admin = require('../firebase');

module.exports = async function authMiddleware(req, res, next) {
  const header = req.headers.authorization;
  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Kein Token gefunden' });
  }
  const idToken = header.split(' ')[1];
  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    req.user = {
      uid: decoded.uid,
      email: decoded.email,
      // hier kannst du alle benötigten Claims mitgeben
    };
    next();
  } catch (err) {
    return res.status(401).json({ message: 'Ungültiges Token' });
  }
};
