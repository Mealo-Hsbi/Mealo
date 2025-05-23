// backend/app/firebase.js
const admin = require('firebase-admin');
const serviceAccount = require('../certs/serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

module.exports = admin;
