const profileService = require('../services/profile.service');

async function getProfile(req, res, next) {
  try {
    const profile = await profileService.fetchProfile(req.user.firebase_uid);
    res.json(profile);
  } catch (err) {
    next(err);
  }
}

async function updateAvatar(req, res, next) {
  try {
    const { avatarUrl } = req.body;
    if (!avatarUrl) {
      return res.status(400).json({ message: 'avatarUrl fehlt im Body' });
    }
    await profileService.updateAvatar(req.user.firebase_uid, avatarUrl);
    res.sendStatus(204);
  } catch (err) {
    next(err);
  }
}

module.exports = {
  getProfile,
  updateAvatar,
};
