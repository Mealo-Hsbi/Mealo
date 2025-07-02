// kapselt alle Google-Cloud-Storage-Operationen
if (process.env.NODE_ENV === 'test') {
  // Dummy implementations for tests
  async function getSignedUploadInfo(filename, contentType) {
    return { uploadUrl: 'https://dummy-upload-url', objectKey: filename };
  }
  async function getSignedDownloadUrl(objectKey) {
    return 'https://dummy-download-url';
  }
  module.exports = {
    getSignedUploadInfo,
    getSignedDownloadUrl,
  };
} else {
  const { Storage } = require('@google-cloud/storage');
  const storage = new Storage({ keyFilename: process.env.GCS_KEY_FILE });
  const defaultBucket  = storage.bucket(process.env.BUCKET_NAME);
  const recipeBucket   = storage.bucket('recipe-pictures');

  async function getSignedUploadInfo(filename, contentType, bucketType = 'profile') {
    const bucket = bucketType === 'recipe' ? recipeBucket : defaultBucket;
    const file = bucket.file(filename);
    const [uploadUrl] = await file.getSignedUrl({
      version     : 'v4',
      action      : 'write',
      expires     : Date.now() + 15 * 60 * 1000,
      contentType,
    });
    return { uploadUrl, objectKey: filename };
  }

  async function getSignedDownloadUrl(objectKey, bucketType = 'profile') {
    const bucket = bucketType === 'recipe' ? recipeBucket : defaultBucket;
    const file = bucket.file(objectKey);
    const [downloadUrl] = await file.getSignedUrl({
      version : 'v4',
      action  : 'read',
      expires : Date.now() + 15 * 60 * 1000,
    });
    return downloadUrl;
  }

  module.exports = {
    getSignedUploadInfo,
    getSignedDownloadUrl,
  };
}
