import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login(String email, String password);
  Future<UserModel> register(String name, String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> forgotPassword(String email);
  Future<void> verifyAccount(String token);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl(this.dio);

  @override
  Future<UserModel> login(String email, String password) async {
    try {
      print('DEBUG: Starting login process for email: $email');
      print('DEBUG: Login endpoint: ${AppConstants.loginEndpoint}');
      
      // Step 1: Login to get access token
      final loginResponse = await dio.post(
        AppConstants.loginEndpoint,
        data: {
          'username': email, // Using username instead of email
          'password': password,
        },
      );

      print('DEBUG: Login response status: ${loginResponse.statusCode}');
      print('DEBUG: Login response data: ${loginResponse.data}');

      if (loginResponse.statusCode != 200) {
        final errorData = loginResponse.data;
        print('DEBUG: Login failed with error: $errorData');
        throw Exception(errorData['message'] ?? 'Invalid username or password');
      }

      final loginData = loginResponse.data as Map<String, dynamic>;
      final accessToken = loginData['access_token'];
      print('DEBUG: Access token received: ${accessToken != null ? 'Yes' : 'No'}');

      if (accessToken == null) {
        throw Exception('Access token not found in login response.');
      }

      // Step 2: Get user details using the token
      print('DEBUG: Getting user details from: ${AppConstants.usersEndpoint}');
      final meResponse = await dio.get(
        AppConstants.usersEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
          },
        ),
      );

      print('DEBUG: Me response status: ${meResponse.statusCode}');
      print('DEBUG: Me response data: ${meResponse.data}');

      if (meResponse.statusCode != 200) {
        throw Exception('Failed to fetch user details after login.');
      }

      final meData = meResponse.data as Map<String, dynamic>;

      // Step 3: Combine data and create user model
      final completeUserData = {
        ...meData,
        'access_token': loginData['access_token'],
        'refresh_token': loginData['refresh_token'],
      };

      print('DEBUG: Complete user data: $completeUserData');
      print('DEBUG: Company ID from meData: ${meData['company_id'] ?? meData['companyId'] ?? 'NOT_FOUND'}');
      return UserModel.fromJson(completeUserData);
    } catch (e) {
      print('DEBUG: Login error: $e');
      throw Exception('Login failed: $e');
    }
  }

  @override
  Future<UserModel> register(String name, String email, String password) async {
    try {
      final response = await dio.post(
        AppConstants.registerEndpoint,
        data: {
          'name': name,
          'email': email,
          'password': password,
        },
      );

      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dio.post('/auth/logout');
    } catch (e) {
      throw Exception('Logout failed: $e');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await dio.get(AppConstants.usersEndpoint);
      return UserModel.fromJson(response.data);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await dio.post('/auth/forgot-password', data: {'email': email});
    } catch (e) {
      throw Exception('Forgot password failed: $e');
    }
  }

  @override
  Future<void> verifyAccount(String token) async {
    try {
      await dio.post('/auth/verify', data: {'token': token});
    } catch (e) {
      throw Exception('Account verification failed: $e');
    }
  }
} 