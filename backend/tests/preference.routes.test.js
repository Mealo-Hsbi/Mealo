const request = require('supertest');
const express = require('express');
const bodyParser = require('body-parser');

jest.mock('../app/services/preference.service');
jest.mock('../app/middleware/auth.middleware', () => (req, res, next) => {
  req.user = { id: 'test-user-id' };
  next();
});
const preferenceService = require('../app/services/preference.service');
const preferenceRoutes = require('../app/routes/preference.routes');

describe('Preference Routes', () => {
  let app;
  beforeEach(() => {
    app = express();
    app.use(bodyParser.json());
    app.use('/api/preferences', preferenceRoutes);
  });

  it('speichert Preferences für den User', async () => {
    preferenceService.setUserPreferences.mockResolvedValueOnce();
    const res = await request(app)
      .post('/api/preferences')
      .send({ optionKeys: ['vegan', 'lactose'] });
    expect(res.statusCode).toBe(204);
    expect(preferenceService.setUserPreferences).toHaveBeenCalledWith('test-user-id', ['vegan', 'lactose']);
  });
}); 