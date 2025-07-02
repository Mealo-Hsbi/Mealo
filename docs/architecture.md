# Architecture

## System Overview
Mealo consists of a Node.js/Express backend and a Flutter frontend. The backend exposes RESTful APIs, while the frontend consumes these APIs to provide a seamless user experience.

## High-Level Architecture Diagram

```
+-------------+        REST API        +----------------+
|  Frontend   | <-------------------> |    Backend     |
|  (Flutter)  |                       | (Node.js/Exp.) |
+-------------+                       +----------------+
        |                                    |
        |                                    |
        v                                    v
  [User Device]                        [Database, Firebase, Spoonacular API]
```

## Data Flow
1. User interacts with the Flutter app.
2. The app sends HTTP requests to the backend.
3. The backend processes requests, interacts with the database, Firebase, and external APIs (e.g., Spoonacular), and returns responses.
4. The frontend displays data and updates the UI accordingly.

## Main Components
- **Frontend**: UI, state management, API integration
- **Backend**: API endpoints, business logic, authentication, database, third-party API integration
- **Database**: Stores user data, meal plans, recipes
- **Firebase**: Authentication, storage, notifications
- **Spoonacular API**: Provides recipe, nutrition, and ingredient data

## External Services & Integrations

### Spoonacular API
The backend integrates with the Spoonacular API to fetch:
- Recipes and cooking instructions
- Nutrition information
- Ingredient details and food images

This allows Mealo to provide up-to-date and diverse meal options, as well as accurate nutrition analysis for users.

### Firebase
Firebase is used for:
- User authentication (sign up, login, password reset)
- Storing user profile data and preferences
- (Optionally) media storage and notifications

### Image Recognition (if applicable)
If image recognition is enabled, the backend may use a service like Google Vision API to identify ingredients from user-uploaded photos. The recognized ingredients are then matched with Spoonacular data to suggest recipes.

## Example User Flow
1. User uploads a photo of ingredients via the app.
2. The frontend sends the image to the backend.
3. The backend uses an image recognition service to identify ingredients.
4. The backend queries the Spoonacular API for recipes using the identified ingredients.
5. The backend returns recipe options to the frontend for display to the user. 