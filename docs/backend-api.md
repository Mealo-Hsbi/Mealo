# Backend API Reference

This document describes the main API endpoints provided by the Mealo backend.

## Authentication
Most endpoints require authentication via Firebase tokens. Include the token in the `Authorization` header:
```
Authorization: Bearer <token>
```

## Example Endpoints

### User Registration
- **POST** `/api/auth/register`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "yourpassword"
  }
  ```
- **Response:**
  ```json
  {
    "message": "User registered successfully"
  }
  ```

### Login
- **POST** `/api/auth/login`
- **Body:**
  ```json
  {
    "email": "user@example.com",
    "password": "yourpassword"
  }
  ```
- **Response:**
  ```json
  {
    "token": "<jwt-token>"
  }
  ```

### Get Meal Plans
- **GET** `/api/mealplans`
- **Headers:** `Authorization: Bearer <token>`
- **Response:**
  ```json
  [
    {
      "id": 1,
      "name": "Weekly Plan",
      "meals": [...]
    }
  ]
  ```

### Image Recognition
- **POST** `/api/image-recognition`
- **Body:** Multipart/form-data with image file
- **Response:**
  ```json
  {
    "ingredients": ["chicken", "onion", "pepper"]
  }
  ```

## More Endpoints
See the source code in `backend/app/routes/` for a full list of endpoints. 