const admin = require('firebase-admin');

if (process.env.NODE_ENV === 'test') {
  // Mock-Objekt für Tests
  module.exports = {
    auth: () => ({
      verifyIdToken: async () => ({ uid: 'test-user-id' }),
    }),
    credential: { cert: () => ({}) },
    initializeApp: () => {},
  };
  console.log('Firebase is mocked for tests.');
} else {
  let initOpts;

  if (process.env.GOOGLE_APPLICATION_CREDENTIALS && process.env.GOOGLE_APPLICATION_CREDENTIALS.startsWith('{')) {
    try {
      const serviceAccount = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS);
      initOpts = { credential: admin.credential.cert(serviceAccount) };
      console.log("Firebase initialized using JSON from GOOGLE_APPLICATION_CREDENTIALS environment variable.");
    } catch (e) {
      console.error('Failed to parse GOOGLE_APPLICATION_CREDENTIALS as JSON:', e);
      throw new Error('Invalid GOOGLE_APPLICATION_CREDENTIALS JSON format.');
    }
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    try {
      const serviceAccount = require(keyPath);
      initOpts = { credential: admin.credential.cert(serviceAccount) };
      console.log(`Firebase initialized using credentials from file path: ${keyPath}`);
    } catch (e) {
      console.error('Failed to load GOOGLE_APPLICATION_CREDENTIALS from file path:', keyPath, e);
      throw new Error('Failed to load Firebase credentials from file path. Ensure it is a valid path.');
    }
  } else {
    try {
      const serviceAccount = require('../certs/serviceAccountKey.json');
      initOpts = { credential: admin.credential.cert(serviceAccount) };
      console.log("Firebase initialized using local certs file.");
    } catch (e) {
      console.error('Failed to load local Firebase serviceAccountKey.json:', e);
      throw new Error('Local Firebase serviceAccountKey.json not found or invalid.');
    }
  }

  admin.initializeApp(initOpts);
  module.exports = admin;
}