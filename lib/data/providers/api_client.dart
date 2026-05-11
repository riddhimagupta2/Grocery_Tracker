import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart' hide Response;
import 'package:logger/logger.dart';

class ApiClient extends GetxService {
  late final Dio _dio;
  final _log = Logger();

  static const String _baseUrl = 'https://freshtrack-api.railway.app/api/v1';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    _dio.interceptors.addAll([_authInterceptor(), _logInterceptor()]);
  }

  Interceptor _authInterceptor() => InterceptorsWrapper(
    onRequest: (options, handler) async {
      try {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
      } catch (_) {}
      handler.next(options);
    },
    onError: (err, handler) async {
      // Token expired → refresh and retry once
      if (err.response?.statusCode == 401) {
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            final token = await user.getIdToken(true);
            err.requestOptions.headers['Authorization'] = 'Bearer $token';
            final retried = await _dio.fetch(err.requestOptions);
            return handler.resolve(retried);
          }
        } catch (_) {}
      }
      handler.next(err);
    },
  );

  Interceptor _logInterceptor() => LogInterceptor(
    requestBody: true,
    responseBody: true,
    logPrint: (o) => _log.d(o.toString()),
  );

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}
