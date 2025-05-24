// backend/app/firebase.js
const admin = require('firebase-admin');

let initOpts;

// 1) If GOOGLE_APPLICATION_CREDENTIALS is set (our container case),
//    load that file as a service‐account cert.
if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
  const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
  const serviceAccount = require(keyPath);
  initOpts = { credential: admin.credential.cert(serviceAccount) };

// 2) Otherwise (local dev), fallback to the one in ./certs/.
//    You’ll need to have your JSON there and npm ignore it in .gitignore.
} else {
  const serviceAccount = require('../certs/serviceAccountKey.json');
  initOpts = { credential: admin.credential.cert(serviceAccount) };
}

admin.initializeApp(initOpts);
module.exports = admin;
