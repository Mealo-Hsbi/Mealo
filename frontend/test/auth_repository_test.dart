import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:frontend/features/auth/data/auth_repository.dart';
import 'package:frontend/features/auth/domain/user_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend/services/api_client.dart';
import 'package:dio/dio.dart';

// 🧪 Dummy ApiClient für Tests

class MockApiClient implements ApiClient {
  @override
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    print('Mock POST: $path');
    return Response<T>(
      data: {} as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  // Wiederhole das analog für GET, PATCH, DELETE, getUser:

  @override
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response<T>(
      data: {} as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response<T>(
      data: {} as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    void Function(int, int)? onSendProgress,
    void Function(int, int)? onReceiveProgress,
  }) async {
    return Response<T>(
      data: {} as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return Response<T>(
      data: {} as T,
      requestOptions: RequestOptions(path: path),
    );
  }

  @override
  Future<Response> getUser() async {
    return Response(
      data: {'firebase_uid': 'mock-user-id'}, // z. B. für Tests
      requestOptions: RequestOptions(path: '/users/me'),
    );
  }
}
void main() {
  // Flutter-Umgebung initialisieren
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockFirebaseAuth mockAuth;
  late AuthRepository repo;

  setUpAll(() async {
    await dotenv.load(fileName: ".env.test");
    print('ENV TEST geladen: ${dotenv.env['API_URL']}');
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    repo = AuthRepository(
      firebaseAuth: mockAuth,
      apiClient: MockApiClient(), // Mock verwenden
    );
  });

  test('signUp erstellt User', () async {
    await repo.signUp(email: 'a@b.com', password: 'password');
    final user = mockAuth.currentUser;
    expect(user, isNotNull);
    expect(user!.email, 'a@b.com');
  });

  test('user stream feuert UserModel nach Login', () async {
    final futureModel = repo.user.firstWhere((u) => u != null);

    await mockAuth.signInWithEmailAndPassword(
      email: 'a@b.com',
      password: 'password',
    );

    final model = await futureModel;

    expect(model, isA<UserModel>());
    expect(model!.uid, equals(mockAuth.currentUser!.uid));
  });
}
