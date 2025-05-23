// tests/user.me.test.js
const request = require('supertest');

// 1) Mock exakt das Modul, das in auth.middleware.js via `require('../firebase')` geladen wird.
//    Da auth.middleware.js in backend/app/middleware liegt, heißt der relative Pfad aus tests: '../app/firebase'
jest.mock('../app/firebase', () => ({
  auth: () => ({
    // Dieser Stub simuliert, dass jedes Token geprüft wird und diesen User liefert
    verifyIdToken: jest.fn().mockResolvedValue({
      uid: 'test-uid-123',
      email: 'test@mealo.app',
    }),
  }),
}));

// 2) Jetzt erst Deine App importieren – der Mock ist registriert, bevor auth.middleware geladen wird.
const app = require('../app');

describe('GET /api/users/me', () => {
  it('gibt den eingeloggten User aus', async () => {
    const res = await request(app)
      .get('/api/users/me')
      .set('Authorization', 'Bearer any-token');

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('user');
    expect(res.body.user).toEqual({
      uid: 'test-uid-123',
      email: 'test@mealo.app',
    });
  });

  it('lehnt ohne Token ab', async () => {
    const res = await request(app).get('/api/users/me');

    expect(res.statusCode).toBe(401);
    expect(res.body).toHaveProperty('message', 'Kein Token gefunden');
  });
});
