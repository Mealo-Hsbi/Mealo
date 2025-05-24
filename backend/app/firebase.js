const admin = require('firebase-admin');
const keyFile = process.env.GOOGLE_APPLICATION_CREDENTIALS;      // "/secrets/…/serviceAccountKey.json"
admin.initializeApp({
  credential: admin.credential.cert(require(keyFile))
});
module.exports = admin;
