import 'package:dio/dio.dart';
import '../../core/api/api_client.dart';
import '../../core/api/api_endpoints.dart';
import '../../core/services/secure_storage_service.dart';
import '../models/user_model.dart';
import '../../core/utils/app_logger.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();
  final SecureStorageService _secureStorage = SecureStorageService();

  Future<UserModel> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.register,
      data: {
        'email': email,
        'password': password,
        'display_name': displayName,
      },
    );

    final data = response.data['data'];
    final user = UserModel.fromJson(data['user']);
    final tokens = data['tokens'];
    
    // Save tokens in secure storage
    await _secureStorage.saveAccessToken(tokens['access']);
    await _secureStorage.saveRefreshToken(tokens['refresh']);
    
    return user;
  }

  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {
        'email': email,
        'password': password,
      },
    );

    final Map<String, dynamic> dataMap;
    if (response.data is Map<String, dynamic> && response.data['success'] == true && response.data['data'] != null) {
      dataMap = response.data['data'] as Map<String, dynamic>;
    } else if (response.data is Map<String, dynamic>) {
      dataMap = response.data as Map<String, dynamic>;
    } else {
      throw Exception('Invalid login response type');
    }

    final accessToken = dataMap['access'] as String?;
    final refreshToken = dataMap['refresh'] as String?;
    
    if (accessToken != null) {
      await _secureStorage.saveAccessToken(accessToken);
    }
    if (refreshToken != null) {
      await _secureStorage.saveRefreshToken(refreshToken);
    }

    return await getProfile();
  }

  Future<UserModel> getProfile() async {
    final response = await _apiClient.get(ApiEndpoints.me);
    return UserModel.fromJson(response.data['data']);
  }

  Future<UserModel> updateProfile(Map<String, dynamic> data, {String? avatarPath}) async {
    dynamic requestData;
    Options? options;

    if (avatarPath != null) {
      final multipartFile = await MultipartFile.fromFile(
        avatarPath,
        filename: avatarPath.split('/').last,
      );
      final map = Map<String, dynamic>.from(data);
      map['avatar'] = multipartFile;
      requestData = FormData.fromMap(map);
      options = Options(contentType: 'multipart/form-data');
    } else {
      requestData = data;
    }

    final response = await _apiClient.patch(
      ApiEndpoints.me,
      data: requestData,
      options: options,
    );
    return UserModel.fromJson(response.data['data']);
  }

  Future<void> requestPasswordReset(String email) async {
    await _apiClient.post(ApiEndpoints.forgotPassword, data: {'email': email});
  }

  Future<void> verifyEmail() async {
    await _apiClient.post(ApiEndpoints.verifyEmail);
  }

  Future<void> logout() async {
    try {
      final refresh = await _secureStorage.getRefreshToken();
      if (refresh != null) {
        await _apiClient.post(ApiEndpoints.logout, data: {'refresh': refresh});
      }
    } catch (_) {}
    await _secureStorage.clearTokens();
  }

  Future<void> deleteAccount() async {
    await _apiClient.delete(ApiEndpoints.deleteAccount);
    await _secureStorage.clearTokens();
  }

  Future<bool> hasValidToken() async {
    final token = await _secureStorage.getAccessToken();
    return token != null;
  }

  Future<UserModel> loginWithGoogle({required String token, String? email, String? name}) async {
    final response = await _apiClient.post(
      ApiEndpoints.googleLogin,
      data: {
        'token': token,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      },
    );

    final data = response.data['data'];
    final user = UserModel.fromJson(data['user']);
    final tokens = data['tokens'];

    await _secureStorage.saveAccessToken(tokens['access']);
    await _secureStorage.saveRefreshToken(tokens['refresh']);

    return user;
  }

  Future<UserModel> loginWithApple({required String token, String? email, String? name}) async {
    final response = await _apiClient.post(
      ApiEndpoints.appleLogin,
      data: {
        'token': token,
        if (email != null) 'email': email,
        if (name != null) 'name': name,
      },
    );

    final data = response.data['data'];
    final user = UserModel.fromJson(data['user']);
    final tokens = data['tokens'];

    await _secureStorage.saveAccessToken(tokens['access']);
    await _secureStorage.saveRefreshToken(tokens['refresh']);

    return user;
  }
}
