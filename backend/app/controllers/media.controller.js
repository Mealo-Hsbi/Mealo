const mediaService = require('../services/media.service');

exports.uploadUrl = async (req, res, next) => {
  try {
    const { filename, contentType, bucketType } = req.body;
    const info = await mediaService.getSignedUploadInfo(filename, contentType, bucketType);
    res.json(info);
  } catch (err) {
    next(err);
  }
};

exports.downloadUrl = async (req, res, next) => {
  try {
    const { objectKey, bucketType } = req.query;
    const downloadUrl = await mediaService.getSignedDownloadUrl(objectKey, bucketType);
    res.json({ downloadUrl });
  } catch (err) {
    next(err);
  }
};
