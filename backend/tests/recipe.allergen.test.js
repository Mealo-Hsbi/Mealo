jest.mock('../app/services/vision.service.js');
const request = require('supertest');
const app = require('../app'); // Adjust if your Express app export path is different

describe('Recipe Allergen Tagging', () => {
  // Mock user tokens or use a test user setup as needed
  const lactoseUserToken = process.env.TEST_LACTOSE_USER_TOKEN || 'test-lactose-token';
  const noAllergyUserToken = process.env.TEST_NOALLERGY_USER_TOKEN || 'test-noallergy-token';

  it('tags recipes with lactose for lactose-intolerant user', async () => {
    const res = await request(app)
      .get('/api/recipes/search/query?query=milk')
      .set('Authorization', `Bearer ${lactoseUserToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    // At least one recipe should be tagged
    const tagged = res.body.find(r => r.containsUserAllergens === true && (r.matchedAllergens || []).includes('lactose'));
    expect(tagged).toBeDefined();
  });

  it('does not tag recipes for user with no allergies', async () => {
    const res = await request(app)
      .get('/api/recipes/search/query?query=milk')
      .set('Authorization', `Bearer ${noAllergyUserToken}`);
    expect(res.statusCode).toBe(200);
    expect(Array.isArray(res.body)).toBe(true);
    // No recipe should be tagged
    const tagged = res.body.find(r => r.containsUserAllergens === true);
    expect(tagged).toBeUndefined();
  });
}); 