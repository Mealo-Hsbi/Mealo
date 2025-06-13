const profileService = require('../services/profile.service');

exports.getProfile = async (req, res, next) => {
  try {
    // auth.middleware hat req.user.uid gesetzt
    const profileDto = await profileService.fetchProfile(req.user.firebase_uid);
    res.json(profileDto);
  } catch (err) {
    next(err);
  }
};
