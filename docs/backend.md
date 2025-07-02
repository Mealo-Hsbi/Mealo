# Backend Documentation

## Overview
The backend is built with Node.js and Express, using Prisma as the ORM for database management. It provides RESTful APIs for the frontend and handles authentication, meal planning logic, image recognition, and more.

## Technologies Used
- Node.js
- Express.js
- Prisma ORM
- Firebase (for authentication and storage)
- Jest (for testing)

## Main Components
- **Controllers**: Handle HTTP requests and responses
- **Services**: Business logic and integration with external APIs
- **Models**: Database schema and ORM models
- **Middleware**: Authentication and request validation
- **Routes**: API endpoint definitions

## Directory Structure
```
backend/
  app/
    config/         # Configuration files
    controllers/    # Route controllers
    middleware/     # Express middleware
    models/         # Database models
    routes/         # API routes
    services/       # Business logic
    prisma/         # Prisma schema
    firebase.js     # Firebase integration
    prisma.js       # Prisma client setup
  tests/            # Backend tests
  Dockerfile        # Containerization
  jest.config.js    # Test configuration
```

## See Also
- [Backend API Reference](backend-api.md) 