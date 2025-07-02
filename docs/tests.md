# Testing & Quality Assurance

This document describes the automated testing approach for Mealo, covering both backend and frontend.

## Overview
Automated tests help ensure the reliability, maintainability, and quality of the Mealo codebase. Both backend and frontend have dedicated test suites.

---

## Backend (Node.js)

### Test Frameworks & Tools
- **Jest**: Main test runner and assertion library
- **Supertest**: For HTTP endpoint testing
- **Mocking**: Used for external services and database calls

### Test Structure
- Tests are located in `backend/tests/`
- Organized by feature (e.g., `achievement.routes.test.js`, `media.routes.test.js`)
- Service and route tests are separated

### Running Backend Tests
```bash
cd backend
npm test
```

### Writing & Extending Tests
- Add new test files in `backend/tests/`
- Use Jest's `describe` and `it/test` blocks
- Mock external dependencies as needed

---

## Frontend (Flutter)

### Test Frameworks & Tools
- **flutter_test**: Core Flutter testing library
- **mockito**: For mocking dependencies
- **network_image_mock**: For mocking network images
- **firebase_auth_mocks**: For mocking Firebase Auth

### Test Structure
- Tests are located in `frontend/test/`
- Organized by feature/screen (e.g., `auth_repository_test.dart`, `home_screen_test.dart`)
- Includes widget, provider, and repository tests

### Running Frontend Tests
```bash
cd frontend
flutter test
```

### Writing & Extending Tests
- Add new test files in `frontend/test/`
- Use `test` and `testWidgets` for logic and widget tests
- Mock providers, services, and network calls as needed
- Wrap widgets in required providers (e.g., `ProviderScope`, `ChangeNotifierProvider`)

---

## Best Practices
- Write tests for new features and bug fixes
- Use mocks for external services (Firebase, APIs)
- Keep tests isolated and repeatable
- Run tests locally before pushing changes

---

For more details, see the test files in the respective `tests/` and `test/` directories. 