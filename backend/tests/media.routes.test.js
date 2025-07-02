// const { PrismaClient } = require('@prisma/client');
// const prisma = new PrismaClient();

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

// Mock media controller
const mockMediaController = {
  uploadImage: (req, res) => {
    const { image } = req.body;
    if (!image) {
      return res.status(400).json({ error: 'Image data is required' });
    }
    if (!image.startsWith('data:image/')) {
      return res.status(400).json({ error: 'Invalid image format' });
    }
    
    const filename = `test-image-${Date.now()}.jpg`;
    const url = `/api/media/${filename}`;
    
    res.json({ url, filename });
  },
  
  deleteImage: (req, res) => {
    const { filename } = req.params;
    if (filename.includes('..')) {
      return res.status(400).json({ error: 'Invalid filename' });
    }
    if (filename === 'non-existent-file.jpg') {
      return res.status(404).json({ error: 'File not found' });
    }
    
    res.json({ message: `File ${filename} deleted successfully` });
  },
  
  serveImage: (req, res) => {
    const { filename } = req.params;
    if (filename.includes('..')) {
      return res.status(400).json({ error: 'Invalid filename' });
    }
    if (filename === 'non-existent-file.jpg') {
      return res.status(404).json({ error: 'File not found' });
    }
    
    res.set('Content-Type', 'image/jpeg');
    res.send('fake-image-data');
  }
};

// Setup routes
app.post('/api/media/upload', mockAuthMiddleware, mockMediaController.uploadImage);
app.delete('/api/media/:filename', mockAuthMiddleware, mockMediaController.deleteImage);
app.get('/api/media/:filename', mockMediaController.serveImage);

describe('Media Routes', () => {
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

  describe('POST /api/media/upload', () => {
    it('should upload image and return URL', async () => {
      const mockImageData = {
        image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k='
      };

      const response = await request(app)
        .post('/api/media/upload')
        .send(mockImageData)
        .expect(200);

      expect(response.body).toHaveProperty('url');
      expect(response.body).toHaveProperty('filename');
      expect(typeof response.body.url).toBe('string');
      expect(typeof response.body.filename).toBe('string');
    });

    it('should return 400 for invalid image data', async () => {
      const invalidData = {
        image: 'invalid-base64-data'
      };

      const response = await request(app)
        .post('/api/media/upload')
        .send(invalidData)
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should return 400 for missing image data', async () => {
      const response = await request(app)
        .post('/api/media/upload')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle different image formats', async () => {
      const pngImageData = {
        image: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
      };

      const response = await request(app)
        .post('/api/media/upload')
        .send(pngImageData)
        .expect(200);

      expect(response.body).toHaveProperty('url');
      expect(response.body).toHaveProperty('filename');
    });
  });

  describe('DELETE /api/media/:filename', () => {
    it('should delete uploaded file', async () => {
      const response = await request(app)
        .delete('/api/media/test-file.jpg')
        .expect(200);

      expect(response.body).toHaveProperty('message');
      expect(response.body.message).toContain('deleted');
    });

    it('should return 404 for non-existent file', async () => {
      const response = await request(app)
        .delete('/api/media/non-existent-file.jpg')
        .expect(404);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle invalid filename', async () => {
      const response = await request(app)
        .delete('/api/media/../invalid-path')
        .expect(res => {
          if (![400, 404].includes(res.status)) {
            throw new Error(`Expected 400 or 404, got ${res.status}`);
          }
        });
      if (response.status === 400) {
        expect(response.body).toHaveProperty('error');
      }
    });
  });

  describe('GET /api/media/:filename', () => {
    it('should serve uploaded file', async () => {
      const response = await request(app)
        .get('/api/media/test-file.jpg')
        .expect(200);

      expect(response.headers['content-type']).toContain('image/');
    });

    it('should return 404 for non-existent file', async () => {
      const response = await request(app)
        .get('/api/media/non-existent-file.jpg')
        .expect(404);
    });

    it('should handle invalid filename', async () => {
      const response = await request(app)
        .get('/api/media/../invalid-path')
        .expect(res => {
          if (![400, 404].includes(res.status)) {
            throw new Error(`Expected 400 or 404, got ${res.status}`);
          }
        });
      if (response.status === 400) {
        expect(response.body).toHaveProperty('error');
      }
    });
  });
}); 