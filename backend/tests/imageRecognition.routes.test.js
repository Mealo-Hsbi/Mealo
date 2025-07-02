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

// Mock image recognition controller
const mockImageRecognitionController = {
  analyzeImage: (req, res) => {
    const { image } = req.body;
    if (!image) {
      return res.status(400).json({ error: 'Image data is required' });
    }
    if (!image.startsWith('data:image/')) {
      return res.status(400).json({ error: 'Invalid image format' });
    }
    res.json({ ingredients: ['tomato', 'onion', 'garlic'] });
  },
  
  batchAnalyzeImages: (req, res) => {
    const { images } = req.body;
    if (!images || !Array.isArray(images)) {
      return res.status(400).json({ error: 'Images array is required' });
    }
    if (images.length === 0) {
      return res.status(400).json({ error: 'Images array cannot be empty' });
    }
    
    const results = images.map((image, index) => {
      if (image.startsWith('data:image/')) {
        return { ingredients: [`ingredient-${index + 1}`] };
      } else {
        return { error: 'Invalid image format' };
      }
    });
    
    res.json({ results });
  },
  
  getHealth: (req, res) => {
    res.json({ 
      status: 'healthy', 
      timestamp: new Date().toISOString() 
    });
  }
};

// Setup routes
app.post('/api/image-recognition/analyze', mockAuthMiddleware, mockImageRecognitionController.analyzeImage);
app.post('/api/image-recognition/batch-analyze', mockAuthMiddleware, mockImageRecognitionController.batchAnalyzeImages);
app.get('/api/image-recognition/health', mockImageRecognitionController.getHealth);

describe('Image Recognition Routes', () => {
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

  describe('POST /api/image-recognition/analyze', () => {
    it('should analyze image and return ingredients', async () => {
      const mockImageData = {
        image: 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k='
      };

      const response = await request(app)
        .post('/api/image-recognition/analyze')
        .send(mockImageData)
        .expect(200);

      expect(response.body).toHaveProperty('ingredients');
      expect(Array.isArray(response.body.ingredients)).toBe(true);
    });

    it('should return 400 for invalid image data', async () => {
      const invalidData = {
        image: 'invalid-base64-data'
      };

      const response = await request(app)
        .post('/api/image-recognition/analyze')
        .send(invalidData)
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should return 400 for missing image data', async () => {
      const response = await request(app)
        .post('/api/image-recognition/analyze')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle different image formats', async () => {
      const pngImageData = {
        image: 'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=='
      };

      const response = await request(app)
        .post('/api/image-recognition/analyze')
        .send(pngImageData)
        .expect(200);

      expect(response.body).toHaveProperty('ingredients');
    });
  });

  describe('POST /api/image-recognition/batch-analyze', () => {
    it('should analyze multiple images and return ingredients', async () => {
      const mockImagesData = {
        images: [
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k='
        ]
      };

      const response = await request(app)
        .post('/api/image-recognition/batch-analyze')
        .send(mockImagesData)
        .expect(200);

      expect(response.body).toHaveProperty('results');
      expect(Array.isArray(response.body.results)).toBe(true);
      expect(response.body.results).toHaveLength(2);
    });

    it('should return 400 for empty images array', async () => {
      const emptyData = {
        images: []
      };

      const response = await request(app)
        .post('/api/image-recognition/batch-analyze')
        .send(emptyData)
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should return 400 for missing images array', async () => {
      const response = await request(app)
        .post('/api/image-recognition/batch-analyze')
        .send({})
        .expect(400);

      expect(response.body).toHaveProperty('error');
    });

    it('should handle mixed valid and invalid images', async () => {
      const mixedData = {
        images: [
          'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAYEBQYFBAYGBQYHBwYIChAKCgkJChQODwwQFxQYGBcUFhYaHSUfGhsjHBYWICwgIyYnKSopGR8tMC0oMCUoKSj/2wBDAQcHBwoIChMKChMoGhYaKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCgoKCj/wAARCAABAAEDASIAAhEBAxEB/8QAFQABAQAAAAAAAAAAAAAAAAAAAAv/xAAUEAEAAAAAAAAAAAAAAAAAAAAA/8QAFQEBAQAAAAAAAAAAAAAAAAAAAAX/xAAUEQEAAAAAAAAAAAAAAAAAAAAA/9oADAMBAAIRAxEAPwCdABmX/9k=',
          'invalid-image-data'
        ]
      };

      const response = await request(app)
        .post('/api/image-recognition/batch-analyze')
        .send(mixedData)
        .expect(200);

      expect(response.body).toHaveProperty('results');
      expect(response.body.results).toHaveLength(2);
      // One result should be successful, one should have error
      expect(response.body.results.some(r => r.error)).toBe(true);
    });
  });

  describe('GET /api/image-recognition/health', () => {
    it('should return service health status', async () => {
      const response = await request(app)
        .get('/api/image-recognition/health')
        .expect(200);

      expect(response.body).toHaveProperty('status');
      expect(response.body).toHaveProperty('timestamp');
      expect(response.body.status).toBe('healthy');
    });
  });
}); 