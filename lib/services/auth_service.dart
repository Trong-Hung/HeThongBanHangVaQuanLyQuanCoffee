import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/shop_info.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';
  static const String _shopKey = 'shop_data';

  // Register (updated to require email)
  static Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String confirmPassword,
    required String fullName,
    required String email,
    required String shopName,
    required String address,
    required String phone,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/register'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': username,
              'password': password,
              'confirmPassword': confirmPassword,
              'full_name': fullName,
              'email': email,
              'shop_name': shopName,
              'address': address,
              'phone': phone,
              'bank_info': {
                'bank_name': bankName,
                'account_number': accountNumber,
                'account_name': accountName,
              },
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Sau khi đăng ký thành công, tự động đăng nhập
        if (responseData['success']) {
          try {
            final loginResult = await login(username, password);
            return {
              'success': true,
              'message': responseData['message'],
              'data': responseData['data'],
              'loginData': loginResult.data,
            };
          } catch (e) {
            // Nếu auto login thất bại, vẫn trả về kết quả đăng ký thành công
            return {
              'success': true,
              'message': responseData['message'],
              'data': responseData['data'],
              'autoLoginError': e.toString(),
            };
          }
        }
      }

      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Login
  static Future<LoginResponse> login(String username, String password) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.loginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          final loginResponse = LoginResponse.fromJson(responseData);

          // Save token, user data and shop info
          await _saveAuthData(
            loginResponse.data.token,
            loginResponse.data.user,
            loginResponse.data.shopInfo,
          );

          return loginResponse;
        } catch (parseError) {
          throw Exception('Phản hồi từ server không hợp lệ');
        }
      } else {
        // Parse error message from response
        String errorMessage = 'Đăng nhập thất bại';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorMessage;
        } catch (parseError) {
          // Ignore parsing error for error message
        }

        // Handle specific error cases
        if (response.statusCode == 401) {
          throw Exception('Sai tên đăng nhập hoặc mật khẩu');
        } else if (response.statusCode == 403) {
          throw Exception('Tài khoản bị khóa hoặc không có quyền truy cập');
        } else if (response.statusCode == 400) {
          throw Exception('Thông tin đăng nhập không hợp lệ');
        } else if (response.statusCode == 500) {
          throw Exception('Lỗi server - Vui lòng thử lại sau');
        } else {
          throw Exception(errorMessage);
        }
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối timeout - Kiểm tra backend có chạy không?');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra backend và internet');
      }
      rethrow;
    }
  }

  // Get Profile
  static Future<User> getProfile() async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http
          .get(
            Uri.parse(ApiConfig.profileEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return User.fromJson(responseData['data']);
      } else {
        throw Exception('Get profile failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  // Change Password
  static Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final token = await getToken();
      if (token == null) {
        throw Exception('No token found');
      }

      final response = await http
          .put(
            Uri.parse(ApiConfig.changePasswordEndpoint),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode({
              'currentPassword': currentPassword,
              'newPassword': newPassword,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Change password failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Change password error: $e');
    }
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    await prefs.remove(_shopKey);
  }

  // Google OAuth Login
  static Future<LoginResponse> googleLogin(String accessToken) async {
    try {
      print(
        '🔐 Attempting Google login to: ${ApiConfig.baseUrl}/api/auth/google',
      );

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/google'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'access_token': accessToken}),
          )
          .timeout(ApiConfig.requestTimeout);

      print('🔐 Google login response status: ${response.statusCode}');
      print('🔐 Google login response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final responseData = jsonDecode(response.body);
          final loginResponse = LoginResponse.fromJson(responseData);

          // Save token, user data and shop info
          await _saveAuthData(
            loginResponse.data.token,
            loginResponse.data.user,
            loginResponse.data.shopInfo,
          );

          return loginResponse;
        } catch (parseError) {
          print('🔐 JSON parsing error: $parseError');
          throw Exception('Invalid response format: ${response.body}');
        }
      } else {
        throw Exception(
          'Google login failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('🔐 Google login error details: $e');
      throw Exception('Google login error: $e');
    }
  }

  // Start Google OAuth flow (redirect to Google)
  static String getGoogleOAuthUrl() {
    return '${ApiConfig.baseUrl}/api/auth/google';
  }

  // Handle Google OAuth callback
  static Future<LoginResponse> handleGoogleCallback(String callbackUrl) async {
    try {
      // Extract token from URL
      final uri = Uri.parse(callbackUrl);
      final token = uri.queryParameters['token'];

      if (token == null) {
        throw Exception('No token found in callback URL');
      }

      // Create user and shop info from token (you might need to call another API to get user info)
      // For now, we'll assume the token contains user info or make another API call

      // This is a simplified implementation - you might need to adjust based on your backend
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}/api/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final loginResponse = LoginResponse.fromJson(responseData);

        // Save token, user data and shop info
        await _saveAuthData(
          token,
          loginResponse.data.user,
          loginResponse.data.shopInfo,
        );

        return loginResponse;
      } else {
        throw Exception('Failed to get user info from token');
      }
    } catch (e) {
      throw Exception('Google callback error: $e');
    }
  }

  // Forgot Password
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/forgot-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email}),
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Verify Reset Code (Optional step)
  static Future<Map<String, dynamic>> verifyResetCode(
    String email,
    String code,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/verify-reset-code'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'code': code}),
          )
          .timeout(ApiConfig.requestTimeout);

      final responseData = jsonDecode(response.body);
      return responseData;
    } catch (e) {
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Reset Password (updated to use token from email)
  static Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      print(
        '🔑 Reset password request to: ${ApiConfig.baseUrl}/api/auth/reset-password',
      );
      print('🔑 Request body: {email: $email, code: $code}');

      final response = await http
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'email': email,
              'code': code,
              'newPassword': newPassword,
              'confirmPassword': confirmPassword,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      print('🔑 Reset password response status: ${response.statusCode}');
      print('🔑 Reset password response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      // Nếu status code là 200 nhưng response không có success field, coi như thành công
      if (response.statusCode == 200 && responseData['success'] == null) {
        return {'success': true, 'message': 'Đặt lại mật khẩu thành công'};
      }

      return responseData;
    } catch (e) {
      print('🔑 Reset password error: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get stored user
  static Future<User?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // Get stored shop info
  static Future<ShopInfo?> getStoredShopInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final shopJson = prefs.getString(_shopKey);
    if (shopJson != null) {
      return ShopInfo.fromJson(jsonDecode(shopJson));
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Save auth data
  static Future<void> _saveAuthData(
    String token,
    User user,
    ShopInfo? shopInfo,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
    if (shopInfo != null) {
      await prefs.setString(_shopKey, jsonEncode(shopInfo.toJson()));
    }
  }

  // Get auth headers
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    print('🔑 Current token: ${token != null ? "EXISTS" : "NULL"}');
    if (token != null) {
      print('🔑 Token length: ${token.length}');
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}
