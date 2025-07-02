// main.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart' as legacy_provider;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import 'package:frontend/core/themes/app_theme.dart';
import 'package:frontend/features/auth/presentation/auth_gate.dart';
import 'package:frontend/core/routes/app_router.dart';
import 'package:frontend/core/config/app_config.dart';
import 'package:frontend/core/config/environment.dart';
import 'package:frontend/core/providers/app_providers.dart';
// Importe für LoginScreen/RegisterScreen, falls direkt in routes verwendet
import 'package:frontend/features/auth/presentation/login_screen.dart';
import 'package:frontend/features/auth/presentation/register_screen.dart';
import 'package:frontend/features/recipe/presentation/provider/favorite_notifier.dart';
import 'package:frontend/features/auth/presentation/providers/auth_state_provider.dart';

import 'firebase_options.dart';

final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

Future<void> _initializeAppServices() async {
  WidgetsFlutterBinding.ensureInitialized();

  const isProd = bool.fromEnvironment('dart.vm.product');
  await dotenv.load(fileName: isProd ? '.env.prod' : '.env.dev');

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.logAppOpen();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  AppConfig.init(Environment.dev);
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeAppServices();
  runApp(
    ProviderScope(
      child: provider.MultiProvider(
        providers: [
          ...AppProviders.providers,
          provider.ChangeNotifierProvider(create: (_) => PremiumProvider()..loadPremiumStatus()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class FavoritesBootstrapper extends ConsumerStatefulWidget {
  final Widget child;
  const FavoritesBootstrapper({super.key, required this.child});

  @override
  ConsumerState<FavoritesBootstrapper> createState() => _FavoritesBootstrapperState();
}

class _FavoritesBootstrapperState extends ConsumerState<FavoritesBootstrapper> {
  String? _lastUserId;

  @override
  void didUpdateWidget(covariant FavoritesBootstrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    _maybeFetchFavorites();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _maybeFetchFavorites();
  }

  void _maybeFetchFavorites() {
    final asyncAuthUser = ref.watch(authStateChangesProvider);
    final userId = asyncAuthUser.asData?.value?.uid;
    final favoriteNotifier = legacy_provider.Provider.of<FavoriteNotifier>(context, listen: false);

    if (userId != null && userId != _lastUserId) {
      _lastUserId = userId;
      favoriteNotifier.fetchFavoriteRecipes(userId);
    }
    if (userId == null) {
      _lastUserId = null;
      favoriteNotifier.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final FirebaseAnalytics analytics = FirebaseAnalytics.instance;
  static final FirebaseAnalyticsObserver observer =
      FirebaseAnalyticsObserver(analytics: analytics);

  @override
  Widget build(BuildContext context) {
    return FavoritesBootstrapper(
      child: MaterialApp(
        title: 'Mealo',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AuthGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/register': (_) => const RegisterScreen(),
          '/home': (_) => const AppNavigationShell(),
        },
        navigatorObservers: [observer],
        scaffoldMessengerKey: scaffoldMessengerKey,
      ),
    );
  }
}