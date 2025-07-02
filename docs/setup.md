# Setup & Installation

This guide will help you set up the Mealo project for local development.

## Prerequisites
- Node.js (v14+)
- npm (v6+)
- Flutter SDK (v3+)
- Dart SDK (comes with Flutter)
- Git

## Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables (see `backend/app/config/apiKeys.js` and other config files).
4. Start the backend server:
   ```bash
   npm start
   ```

## Frontend Setup
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

## Additional Notes
- For iOS development, Xcode is required (macOS only).
- For Android development, Android Studio is recommended.
- See [docs/backend.md](backend.md) and [docs/frontend.md](frontend.md) for more details. 