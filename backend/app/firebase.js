// backend/app/firebase.js
if (process.env.NODE_ENV === 'test') {
  module.exports = {};
} else {
  const admin = require('firebase-admin');
  let initOpts;

  // This condition checks if GOOGLE_APPLICATION_CREDENTIALS exists and its content
  // looks like a JSON string (starts with '{'). This is for Cloud Run.
  if (process.env.GOOGLE_APPLICATION_CREDENTIALS && process.env.GOOGLE_APPLICATION_CREDENTIALS.startsWith('{')) {
    try {
      // Parse the JSON string directly from the environment variable
      const serviceAccount = JSON.parse(process.env.GOOGLE_APPLICATION_CREDENTIALS);
      initOpts = { credential: admin.credential.cert(serviceAccount) };
      console.log("Firebase initialized using JSON from GOOGLE_APPLICATION_CREDENTIALS environment variable.");
    } catch (e) {
      console.error('Failed to parse GOOGLE_APPLICATION_CREDENTIALS as JSON:', e);
      throw new Error('Invalid GOOGLE_APPLICATION_CREDENTIALS JSON format.');
    }
  }
  // This condition is for local development or if you were to mount the key as a file
  // AND set GOOGLE_APPLICATION_CREDENTIALS to that file path.
  else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    const keyPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;
    try {
      const serviceAccount = require(keyPath);
      initOpts = { credential: admin.credential.cert(serviceAccount) };
      console.log(`Firebase initialized using credentials from file path: ${keyPath}`);
    } catch (e) {
      console.error('Failed to load GOOGLE_APPLICATION_CREDENTIALS from file path:', keyPath, e);
      throw new Error('Failed to load Firebase credentials from file path. Ensure it is a valid path.');
    }
  }
  // This is the fallback for local development where the JSON is in ./certs/serviceAccountKey.json
  else {
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