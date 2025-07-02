# Frontend Documentation

## Overview
The frontend is built with Flutter and Dart, providing a cross-platform mobile experience. It interacts with the backend via REST APIs and offers a modern, user-friendly interface.

## Technologies Used
- Flutter
- Dart
- Provider (state management)
- Firebase (authentication, storage)

## Main Screens
- **Login/Register**: User authentication
- **Home**: Dashboard and meal overview
- **Meal Plan**: View and manage meal plans
- **Recipe Search**: Discover and search for recipes
- **Camera/Image Recognition**: Upload images to identify ingredients
- **Profile**: User settings and preferences

## Directory Structure
```
frontend/
  lib/
    features/         # Main app features (auth, mealplan, camera, etc.)
    common/           # Shared models, styles, utils
    core/             # App-wide config, constants, providers
    services/         # API clients
    main.dart         # App entry point
  assets/             # Images, icons, sounds
  test/               # Frontend tests
```

## See Also
- [User Guide](usage.md) 