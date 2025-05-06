const request = require('supertest');
const app = require('../app');

describe('GET /api/users', () => {
  it('should return a list of users', async () => {
    const res = await request(app).get('/api/users');
    expect(res.statusCode).toBe(200);
    expect(res.body.users).toContain('Alice');
  });
});
