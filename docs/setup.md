# Setup & Installation

This guide will help you set up the Mealo project for local development on both backend and frontend, including mobile device and emulator setup.

## Prerequisites
- **Node.js** (v14+)
- **npm** (v6+)
- **Flutter SDK** (v3+)
- **Dart SDK** (comes with Flutter)
- **Git**
- **Android Studio** (for Android development)
- **Xcode** (for iOS development, macOS only)

## Backend Setup
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Set up environment variables:
   - Copy or create any required `.env` files (see `backend/app/config/apiKeys.js` and other config files for required keys).
   - Add your API keys (e.g., Spoonacular, Firebase) as needed.
4. (Optional) Run database migrations if using Prisma:
   ```bash
   npx prisma migrate dev
   ```
5. Start the backend server:
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
3. Check your Flutter environment:
   ```bash
   flutter doctor
   ```
   - Follow any instructions to resolve missing dependencies (e.g., Android toolchain, licenses).

### Running on Android
1. **Install Android Studio:**
   - Download from [developer.android.com/studio](https://developer.android.com/studio)
   - Install the Android SDK and set up an emulator via AVD Manager, or connect a physical device.
2. **Enable USB Debugging on your Android device:**
   - Go to Settings > About phone > Tap 'Build number' 7 times to enable Developer Options.
   - In Developer Options, enable 'USB debugging'.
   - Connect your device via USB and allow debugging access.
3. **Run the app:**
   ```bash
   flutter run
   ```
   - Use `flutter devices` to list available devices/emulators.

## Frontend Environment Variables

The frontend uses environment variables managed by the `flutter_dotenv` package. You need to create a `.env.dev` (for development) and/or `.env.prod` (for production) file in the `frontend/` directory.

### Example `.env.dev` file:
```
API_BASE_URL=http://localhost:3000/api
```

- `API_BASE_URL`: The base URL for your backend API. Use your local server or deployed backend as appropriate.


> **Tip:** Never commit your real API keys to version control. Use `.env` files for secrets and add them to `.gitignore`.

## Backend Environment Variables

The backend uses environment variables for configuration. Create a `.env` file in the `backend/` directory with the following keys:

### Example `.env` file:
```
PORT=8080
DATABASE_URL=postgresql://user:password@localhost:5432/mealo

# Spoonacular API keys (at least one required)
SPOONACULAR_API_KEY=your-main-spoonacular-key

# Firebase service account (either a file path or the JSON string)
GOOGLE_APPLICATION_CREDENTIALS=./certs/serviceAccountKey.json

# Google Cloud Storage (if used)
GCS_KEY_FILE=./certs/gcs-key.json
BUCKET_NAME=your-gcs-bucket-name

# OpenAI API key (if using OpenAI services)
OPENAI_API_KEY=your-openai-api-key
```

- `PORT`: (Optional) Port for the backend server (default: 8080)
- `DATABASE_URL`: Connection string for your database (PostgreSQL, etc.)
- `SPOONACULAR_API_KEY`: Your Spoonacular API key 
- `GOOGLE_APPLICATION_CREDENTIALS`: Path to your Firebase service account JSON file, or the JSON string itself
- `GCS_KEY_FILE`: Path to your Google Cloud Storage key file (if using GCS)
- `BUCKET_NAME`: Name of your Google Cloud Storage bucket
- `OPENAI_API_KEY`: Your OpenAI API key (if using OpenAI services)

> **Tip:** Never commit your real API keys or secrets to version control. Use `.env` files for secrets and add them to `.gitignore`.

## Troubleshooting & Tips
- Use `flutter doctor` to diagnose and fix environment issues.
- If you encounter device connection issues, try restarting your IDE and device.
- For backend issues, check that all environment variables and API keys are set correctly.
- For more help, see the [Flutter installation guide](https://docs.flutter.dev/get-started/install) and [Node.js documentation](https://nodejs.org/en/docs/).

## Additional Notes
- For iOS development, Xcode is required (macOS only).
- For Android development, Android Studio is recommended.
- See [docs/backend.md](backend.md) and [docs/frontend.md](frontend.md) for more details. 