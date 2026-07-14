import 'package:dio/dio.dart';
import 'api_endpoints.dart';
import 'api_error_mapper.dart';
import 'api_exception.dart';
import 'token_refresh_manager.dart';
import '../services/secure_storage_service.dart';
import '../utils/app_logger.dart';
import '../../config/app_navigation.dart';
import '../../config/app_routes.dart';

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;

  late final Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  ApiClient._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([
      _fallbackInterceptor(),
      _authInterceptor(),
      _logInterceptor(),
    ]);
  }

  Interceptor _fallbackInterceptor() => InterceptorsWrapper(
        onError: (err, handler) async {
          // If connection to localhost fails, automatically fall back to the PC's Wi-Fi IP address
          if (err.type == DioExceptionType.connectionError &&
              _dio.options.baseUrl.contains('127.0.0.1')) {
            AppLogger.warning('Connection refused on 127.0.0.1. Falling back to Wi-Fi host IP 192.168.1.11...');
            _dio.options.baseUrl = 'http://192.168.1.11:8000/api/v1';
            
            final options = err.requestOptions;
            options.baseUrl = _dio.options.baseUrl;
            try {
              final response = await _dio.fetch(options);
              return handler.resolve(response);
            } catch (e) {
              // If both fail, restore localhost configuration to prevent state pollution
              _dio.options.baseUrl = 'http://127.0.0.1:8000/api/v1';
            }
          }
          handler.next(err);
        },
      );

  Interceptor _authInterceptor() => InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _secureStorage.getAccessToken();
          if (token != null && !options.headers.containsKey('Authorization')) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (err, handler) async {
          // Token expired → trigger single-flight refresh and retry exactly once
          if (err.response?.statusCode == 401 &&
              err.requestOptions.extra['isRetry'] != true) {
            AppLogger.warning('Received 401 Unauthorized. Attempting token refresh...');
            err.requestOptions.extra['isRetry'] = true;
            
            try {
              final newAccessToken = await TokenRefreshManager().refreshAccessToken(_dio);
              if (newAccessToken != null) {
                // Update Authorization header with the new token
                err.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                // Clone and retry request
                final response = await _dio.fetch(err.requestOptions);
                return handler.resolve(response);
              }
            } catch (_) {}

            // If refresh fails or returns null, clear state and kick user to login
            AppLogger.error('Token refresh failed. Redirecting to Login screen...');
            await _secureStorage.clearTokens();
            AppNavigation.toAndRemoveUntil(AppRoutes.login);
          }
          handler.next(err);
        },
      );

  Interceptor _logInterceptor() => LogInterceptor(
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        logPrint: (obj) => AppLogger.debug(obj.toString()),
      );

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.get(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    try {
      return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  Future<Response> put(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.put(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  Future<Response> patch(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.patch(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }

  Future<Response> delete(String path, {dynamic data, Options? options}) async {
    try {
      return await _dio.delete(path, data: data, options: options);
    } on DioException catch (e) {
      throw ApiErrorMapper.map(e);
    }
  }
}
