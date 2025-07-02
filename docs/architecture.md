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
  [User Device]                        [Database, Firebase]
```

## Data Flow
1. User interacts with the Flutter app.
2. The app sends HTTP requests to the backend.
3. The backend processes requests, interacts with the database and Firebase, and returns responses.
4. The frontend displays data and updates the UI accordingly.

## Main Components
- **Frontend**: UI, state management, API integration
- **Backend**: API endpoints, business logic, authentication, database
- **Database**: Stores user data, meal plans, recipes
- **Firebase**: Authentication, storage, notifications 