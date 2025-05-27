// kapselt alle Google-Cloud-Storage-Operationen
const { Storage } = require('@google-cloud/storage');

const storage = new Storage({ keyFilename: process.env.GCS_KEY_FILE });
const bucket  = storage.bucket(process.env.BUCKET_NAME);

async function getSignedUploadInfo(filename, contentType) {
  const file = bucket.file(filename);
  const [uploadUrl] = await file.getSignedUrl({
    version     : 'v4',
    action      : 'write',
    expires     : Date.now() + 15 * 60 * 1000,
    contentType,
  });
  return { uploadUrl, objectKey: filename };
}

async function getSignedDownloadUrl(objectKey) {
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
