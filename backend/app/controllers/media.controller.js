const mediaService = require('../services/media.service');

exports.uploadUrl = async (req, res, next) => {
  try {
    const { filename, contentType } = req.body;
    const info = await mediaService.getSignedUploadInfo(filename, contentType);
    res.json(info);
  } catch (err) {
    next(err);
  }
};

exports.downloadUrl = async (req, res, next) => {
  try {
    const { objectKey } = req.query;
    const downloadUrl = await mediaService.getSignedDownloadUrl(objectKey);
    res.json({ downloadUrl });
  } catch (err) {
    next(err);
  }
};
