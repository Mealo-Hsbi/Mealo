const request = require('supertest');
const express = require('express');
const bodyParser = require('body-parser');
const prisma = require('../app/prisma');

jest.mock('../app/services/preference.service');
jest.mock('../app/middleware/auth.middleware', () => (req, res, next) => {
  req.user = { id: '00000000-0000-0000-0000-000000000000' };
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

  beforeAll(async () => {
    // Lege Testuser an
    await prisma.users.create({
      data: {
        id: '00000000-0000-0000-0000-000000000000',
        firebase_uid: 'test-firebase-uid',
        email: 'test@example.com',
        name: 'Test User',
        avatar_url: 'https://example.com/avatar.jpg',
        has_completed_onboarding: false,
      },
    });
  });

  afterAll(async () => {
    // Lösche Testuser
    await prisma.users.delete({
      where: { id: '00000000-0000-0000-0000-000000000000' },
    });
    await prisma.$disconnect();
  });

  it('speichert Preferences für den User', async () => {
    preferenceService.setUserPreferences.mockResolvedValueOnce();
    const res = await request(app)
      .post('/api/preferences')
      .send({ optionKeys: ['vegan', 'lactose'] });
    expect(res.statusCode).toBe(204);
    expect(preferenceService.setUserPreferences).toHaveBeenCalledWith('00000000-0000-0000-0000-000000000000', ['vegan', 'lactose']);
  });
}); 