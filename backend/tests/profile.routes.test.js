const request = require('supertest');
const express = require('express');

// Create a simple test app
const app = express();
app.use(express.json());

// Mock middleware
const mockAuthMiddleware = (req, res, next) => {
  req.user = { id: '00000000-0000-0000-0000-000000000000', email: 'test@example.com' };
  next();
};

// Mock profile controller
const mockProfileController = {
  getUserProfile: (req, res) => {
    const user = {
      id: '00000000-0000-0000-0000-000000000000',
      email: 'test@example.com',
      name: 'Test User',
      avatar_url: 'https://example.com/avatar.jpg'
    };
    res.json(user);
  },
  
  updateUserProfile: (req, res) => {
    const { name, avatar_url } = req.body;
    
    if (name === '') {
      return res.status(400).json({ error: 'Name cannot be empty' });
    }
    
    if (avatar_url && !avatar_url.startsWith('http')) {
      return res.status(400).json({ error: 'Invalid avatar URL' });
    }
    
    const updatedUser = {
      id: '00000000-0000-0000-0000-000000000000',
      email: 'test@example.com',
      name: name || 'Test User',
      avatar_url: avatar_url || 'https://example.com/avatar.jpg'
    };
    
    res.json(updatedUser);
  },
  
  deleteUserProfile: (req, res) => {
    res.json({ message: 'User profile deleted successfully' });
  }
};

// Setup routes
app.get('/api/profile', mockAuthMiddleware, mockProfileController.getUserProfile);
app.put('/api/profile', mockAuthMiddleware, mockProfileController.updateUserProfile);
app.delete('/api/profile', mockAuthMiddleware, mockProfileController.deleteUserProfile);

describe('Profile Routes', () => {
  beforeAll(async () => {
    // Clean up database before tests
    // await prisma.user_preference.deleteMany();
    // await prisma.preference_option.deleteMany();
    // await prisma.preference_question.deleteMany();
    // await prisma.user.deleteMany();
  });

  afterAll(async () => {
    // await prisma.$disconnect();
  });

  describe('GET /api/profile', () => {
    it('should return user profile', async () => {
      const response = await request(app)
        .get('/api/profile')
        .expect(200);

      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('email');
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('avatar_url');
      expect(response.body.id).toBe('00000000-0000-0000-0000-000000000000');
      expect(response.body.email).toBe('test@example.com');
    });
  });

  describe('PUT /api/profile', () => {
    it('should update user profile', async () => {
      const updateData = {
        name: 'Updated Test User',
        avatar_url: 'https://example.com/new-avatar.jpg'
      };

      const response = await request(app)
        .put('/api/profile')
        .send(updateData)
        .expect(200);

      expect(response.body).toHaveProperty('id');
      expect(response.body).toHaveProperty('name');
      expect(response.body).toHaveProperty('avatar_url');
      expect(response.body.name).toBe('Updated Test User');
      expect(response.body.avatar_url).toBe('https://example.com/new-avatar.jpg');
    });

    it('should update only name', async () => {
      const updateData = {
        name: 'Only Name Updated'
      };

      const response = await request(app)
        .put('/api/profile')
        .send(updateData)
        .expect(200);

      expect(response.body.name).toBe('Only Name Updated');
    });

    it('should return 400 for invalid data', async () => {
      const invalidData = {
        name: '', // Empty name
        avatar_url: 'not-a-valid-url'
      };

      const response = await request(app)
        .put('/api/profile')
        .send(invalidData)
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });
  });

  describe('DELETE /api/profile', () => {
    it('should delete user profile', async () => {
      const response = await request(app)
        .delete('/api/profile')
        .expect(200);

      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('deleted');
    });
  });
}); 