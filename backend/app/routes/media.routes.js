const { Router } = require('express');
const { Storage } = require('@google-cloud/storage');

const router = Router();

require('dotenv').config();

// Erzeuge den Storage-Client mit dem expliziten keyFilename
const storage = new Storage({
  keyFilename: process.env.GCS_KEY_FILE
});
const bucket = storage.bucket(process.env.BUCKET_NAME);

// Upload-URL
router.post('/upload-url', async (req, res, next) => {
  try {
    const { filename, contentType } = req.body;
    const file = bucket.file(filename);
    const [url] = await file.getSignedUrl({
      version: 'v4',
      action: 'write',
      expires: Date.now() + 15 * 60 * 1000,
      contentType,
    });
    res.json({ uploadUrl: url, objectKey: filename });
  } catch (err) {
    next(err);
  }
});

// Download-URL
router.get('/download-url', async (req, res, next) => {
  try {
    const { objectKey } = req.query;
    const file = bucket.file(objectKey);
    const [url] = await file.getSignedUrl({
      version: 'v4',
      action: 'read',
      expires: Date.now() + 15 * 60 * 1000,
    });
    res.json({ downloadUrl: url });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
