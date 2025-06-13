const admin = require('../firebase');
const {PrismaClient} = require('../generated/prisma');

const prisma = new PrismaClient();

module.exports = async function authMiddleware(req, res, next) {
  const header = req.headers.authorization;

  if (!header || !header.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'Kein Token übergeben.' });
  }

  const idToken = header.split(' ')[1];

  try {
    const decoded = await admin.auth().verifyIdToken(idToken);
    const firebaseUid = decoded.uid;

    // 🔍 Hole Benutzer anhand Firebase UID
    const user = await prisma.users.findUnique({
      where: { firebase_uid: firebaseUid },
    });

    if (!user) {
      return res.status(404).json({ message: 'Benutzer nicht in Datenbank gefunden.' });
    }

    // ✅ direkt den User mit UUID setzen
    req.user = {
      id: user.id,                 // UUID aus DB (für DB-Beziehungen)
      firebase_uid: user.firebase_uid,
      email: user.email,
      name: user.name,
    };

    next();
  } catch (err) {
    console.error('verifyIdToken failed:', err);
    return res.status(401).json({ message: 'Ungültiges Token', error: err.message });
  }
};
