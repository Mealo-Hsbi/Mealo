const profileService = require('../services/profile.service');

exports.getProfile = async (req, res, next) => {
  try {
    // auth.middleware hat req.user.uid gesetzt
    const profileDto = await profileService.fetchProfile(req.user.uid);
    console.log('Profile fetched:', profileDto);
    res.json(profileDto);
  } catch (err) {
    next(err);
  }
};
