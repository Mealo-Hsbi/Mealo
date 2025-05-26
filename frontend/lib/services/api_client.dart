// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  // Singleton
  static final ApiClient _instance = ApiClient._internal();

  factory ApiClient() {
    return _instance;
  }

  ApiClient._internal() {
    final baseUrl = dotenv.env['API_BASE_URL']!;
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ))
      ..interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            try {
              final token = await user.getIdToken();
              options.headers['Authorization'] = 'Bearer $token';
              print('-> API Request: ${options.method} ${options.uri} with token');
            } on FirebaseException catch (e) {
              print('Firebase Auth Token Fehler: ${e.message}');
            }
          } else {
            print('-> API Request: ${options.method} ${options.uri} (no user/token)');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print('!!! API Error: ${e.response?.statusCode ?? 'N/A'} - ${e.requestOptions.uri}');
          print('!!! Error message: ${e.message}');
          if (e.response?.data != null) {
            print('!!! Error data: ${e.response!.data}');
          }
          if (e.response?.statusCode == 401) {
            print('Authentication error (401): User might need to re-authenticate or token expired.');
          }
          if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
            print('Connection/Receive Timeout: Server took too long to respond.');
          }
          return handler.next(e);
        },
        onResponse: (response, handler) {
          print('<- API Response: ${response.statusCode} ${response.requestOptions.uri}');
          return handler.next(response);
        },
      ));
  }

  late final Dio _dio; // Hier bleibt die Dio-Instanz!

  Future<Response> getUser() {
    // Beispiel-Call auf /users/me
    return _dio.get('/users/me');
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data, // `dynamic` erlaubt sowohl Map, List, als auch FormData
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    return _dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}