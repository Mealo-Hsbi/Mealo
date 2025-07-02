# Frontend Documentation

## Overview
The frontend is built with Flutter and Dart, providing a cross-platform mobile experience. It interacts with the backend via REST APIs and offers a modern, user-friendly interface.

## Technologies Used
- Flutter
- Dart
- Provider (state management)
- Riverpod (state management)
- Firebase (authentication, storage)
- Dio (HTTP client)
- flutter_dotenv (environment variables)

## Features & Components Overview

The frontend is organized into feature-based modules, each responsible for a core part of the app. Here's an overview of the main features and their components:

### Features Directory (`lib/features/`)
- **auth/**: User authentication (login, registration, auth state)
- **mealplan/**: Meal plan creation, editing, and display
- **camera/**: Camera integration and image recognition for ingredient detection
- **profile/**: User profile, preferences, and settings
- **recipe/**: Recipe discovery, search, and details
- **favorites/**: Managing and displaying favorite recipes
- **explore/**: Explore new recipes and meal ideas
- **onboarding/**: User onboarding flow
- **search/**: Ingredient and recipe search functionality
- **home/**: Home screen/dashboard
- **blub/**: (Custom feature, e.g., hotel list demo)

### Common & Core Modules
- **common/**: Shared models (e.g., ingredient, recipe), styles, utilities, and reusable widgets
- **core/**: App-wide configuration, constants, error handling, providers, routing, and theming
- **services/**: API clients and network logic (e.g., `api_client.dart`)
- **assets/**: Images, icons, and sounds used throughout the app

### State Management
- Uses both Provider and Riverpod for state management, depending on the feature
- App-wide providers are defined in `core/providers/app_providers.dart`
- Feature-specific providers are in their respective modules

### API Integration
- All backend communication is handled via REST APIs using the Dio HTTP client
- API endpoints and base URLs are configured via environment variables (`.env.dev`, `.env.prod`)
- Authentication tokens are managed with Firebase Auth and attached to requests

### Testing
- Tests are located in the `test/` directory and cover screens, repositories, and core logic

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

## Feature Module Structure: Clean Architecture

Each feature in the `lib/features/` directory is organized following a clean architecture approach, which separates concerns into distinct layers:

- **Presentation Layer** (`presentation/`):
  - Contains UI widgets, screens, and state management providers/controllers specific to the feature.
  - Handles user interaction, input validation, and displaying data.

- **Domain Layer** (`domain/`):
  - Contains business logic, core models/entities, and use cases.
  - Defines interfaces (abstract classes) for repositories and services, decoupling business logic from implementation details.

- **Data Layer** (`data/`):
  - Handles data sources, repositories, and API integration.
  - Responsible for fetching, caching, and persisting data (e.g., from REST APIs, local storage, or Firebase).

### Example Feature Structure
```
features/
  recipe/
    data/
      repositories/
      datasources/
    domain/
      models/
      usecases/
      repositories/
    presentation/
      screens/
      providers/
      widgets/
```

This structure ensures:
- **Separation of concerns**: UI, business logic, and data access are independent.
- **Testability**: Each layer can be tested in isolation.
- **Scalability**: New features or changes can be added with minimal impact on other layers.
- **Maintainability**: Code is easier to understand, refactor, and extend.

> **Tip:** Not all features may use every layer if not needed, but this structure is recommended for complex or core features. 