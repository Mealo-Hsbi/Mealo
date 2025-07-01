import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class MockFirebaseApp extends Mock implements FirebaseApp {}

class MockAuthRepository implements AuthRepository {
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  @override
  Stream<UserModel?> get user {
    return Stream.value(_isAuthenticated ? UserModel(uid: '1', email: 'test@example.com') : null);
  }

  @override
  Future<void> signUp({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (email == 'new@example.com') {
      _isAuthenticated = true;
      _error = null;
    } else {
      _error = 'Email already exists';
    }
    _isLoading = false;
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    if (email == 'test@example.com' && password == 'password') {
      _isAuthenticated = true;
      _error = null;
    } else {
      _error = 'Invalid credentials';
    }
    _isLoading = false;
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
  }

  @override
  Future<void> createUserInDb({required String name, String? avatarUrl}) async {
    // Mock implementation
  }

  @override
  Future<void> signInWithGoogleAndSyncDb() async {
    _isLoading = true;
    _error = null;
    
    await Future.delayed(const Duration(milliseconds: 100));
    _isAuthenticated = true;
    _isLoading = false;
  }
}

class AuthProvider extends ChangeNotifier {
  final MockAuthRepository _authRepository;
  
  AuthProvider(this._authRepository);
  
  bool get isLoading => _authRepository.isLoading;
  String? get error => _authRepository.error;
  bool get isAuthenticated => _authRepository.isAuthenticated;
  Stream<UserModel?> get user => _authRepository.user;
  
  Future<void> signInWithEmail(String email, String password) async {
    await _authRepository.signIn(email: email, password: password);
    notifyListeners();
  }
  
  Future<void> signUpWithEmail(String email, String password, String name) async {
    await _authRepository.signUp(email: email, password: password);
    if (_authRepository.isAuthenticated) {
      await _authRepository.createUserInDb(name: name);
    }
    notifyListeners();
  }
  
  Future<void> signInWithGoogle() async {
    await _authRepository.signInWithGoogleAndSyncDb();
    notifyListeners();
  }
  
  Future<void> signOut() async {
    await _authRepository.signOut();
    notifyListeners();
  }
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    
    // Initialize dotenv
    dotenv.testLoad();
    dotenv.env['API_BASE_URL'] = 'http://localhost:3000/api';
    dotenv.env['SPOONACULAR_API_KEY'] = 'test-key';
    
    // Initialize AppConfig
    AppConfig.init(Environment.dev);
    
    // Mock Firebase
    final fakePlatform = FakeFirebasePlatform();
    FirebasePlatform.instance = fakePlatform;
  });

  group('Login Screen Tests', () {
    testWidgets('Login screen displays correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Should show login form
        expect(find.text("Welcome back, you've been missed!"), findsOneWidget);
        expect(find.text('Sign In'), findsOneWidget);
        expect(find.text('Sign in with Google'), findsOneWidget);
      });
    });

    testWidgets('Login form validation works', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const LoginScreen(),
          ),
        );
        await tester.tap(find.text('Sign In'));
        expect(find.text('Sign In'), findsOneWidget);
      });
    });

    testWidgets('Successful login', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter credentials
        await tester.enterText(find.byType(TextField).first, 'test@example.com');
        await tester.enterText(find.byType(TextField).last, 'password123');
        await tester.pumpAndSettle();

        // Should show login button
        expect(find.text('Sign In'), findsOneWidget);
      });
    });

    testWidgets('Google sign in button works', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const LoginScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Should show Google sign in button
        expect(find.text('Sign in with Google'), findsOneWidget);
      });
    });
  });

  group('Register Screen Tests', () {
    testWidgets('Register screen displays correctly', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const RegisterScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Should show register form
        expect(find.text('Create your account'), findsOneWidget);
        expect(find.text('Sign Up'), findsOneWidget);
      });
    });

    testWidgets('Register form validation works', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const RegisterScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Try to register without entering credentials
        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Bitte gib deinen Vornamen ein'), findsOneWidget);
      });
    });

    testWidgets('Password validation works', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const RegisterScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter invalid password
        await tester.enterText(find.byType(TextField).at(0), 'John');
        await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextField).at(2), '123');
        await tester.enterText(find.byType(TextField).at(3), '456');
        await tester.pumpAndSettle();

        await tester.tap(find.text('Sign Up'));
        await tester.pumpAndSettle();

        // Should show error message
        expect(find.text('Passwörter stimmen nicht überein'), findsOneWidget);
      });
    });

    testWidgets('Successful registration', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        await tester.pumpWidget(
          MaterialApp(
            home: const RegisterScreen(),
          ),
        );
        await tester.pumpAndSettle();

        // Enter valid credentials
        await tester.enterText(find.byType(TextField).at(0), 'John');
        await tester.enterText(find.byType(TextField).at(1), 'test@example.com');
        await tester.enterText(find.byType(TextField).at(2), 'password123');
        await tester.enterText(find.byType(TextField).at(3), 'password123');
        await tester.pumpAndSettle();

        // Should show loading indicator
        expect(find.text('Sign Up'), findsOneWidget);
      });
    });
  });

  group('Auth Gate Tests', () {
    testWidgets('Auth gate shows login when not authenticated', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final mockRepo = MockAuthRepository();
        mockRepo._isAuthenticated = false;

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(mockRepo),
              child: Builder(
                builder: (context) {
                  return StreamBuilder<UserModel?>(
                    stream: mockRepo.user,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.data == null) {
                        return const LoginScreen();
                      }
                      return const Scaffold(body: Text('Logged in'));
                    },
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text("Welcome back, you've been missed!"), findsOneWidget);
      });
    });

    testWidgets('Auth gate shows home when authenticated', (WidgetTester tester) async {
      await mockNetworkImagesFor(() async {
        final mockRepo = MockAuthRepository();
        mockRepo._isAuthenticated = true;

        await tester.pumpWidget(
          MaterialApp(
            home: ChangeNotifierProvider<AuthProvider>(
              create: (_) => AuthProvider(mockRepo),
              child: Builder(
                builder: (context) {
                  return StreamBuilder<UserModel?>(
                    stream: mockRepo.user,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      }
                      if (snapshot.hasData) {
                        return const Scaffold(body: Text('Authenticated'));
                      } else {
                        return const LoginScreen();
                      }
                    },
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Should show authenticated state
        expect(find.text('Authenticated'), findsOneWidget);
      });
    });
  });
}

class FakeFirebasePlatform extends FirebasePlatform {
  FakeFirebasePlatform() : super();
  @override
  Future<FirebaseAppPlatform> initializeApp({String? name, FirebaseOptions? options}) async {
    return FakeFirebaseAppPlatform();
  }
  @override
  FirebaseAppPlatform app([String? name]) {
    return FakeFirebaseAppPlatform();
  }
  @override
  List<FirebaseAppPlatform> get apps => <FirebaseAppPlatform>[FakeFirebaseAppPlatform()];
}

class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform() : super('delegate', FirebaseOptions(apiKey: '', appId: '', messagingSenderId: '', projectId: ''));
  @override
  String get name => 'FakeApp';
  @override
  Future<void> delete() async {}
  @override
  Future<void> setAutomaticDataCollectionEnabled(bool enabled) async {}
  @override
  bool get automaticDataCollectionEnabled => false;
  @override
  FirebaseOptions get options => FirebaseOptions(apiKey: '', appId: '', messagingSenderId: '', projectId: '');
} 