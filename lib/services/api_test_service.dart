import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiTestService {
  static Future<void> testApiConnection() async {
    try {
      print('🔄 Testing API connection...');
      print('📍 Base URL: ${ApiConfig.baseUrl}');
      print('🏥 Health endpoint: ${ApiConfig.healthEndpoint}');

      final response = await http
          .get(
            Uri.parse(ApiConfig.healthEndpoint),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Response status: ${response.statusCode}');
      print('📝 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ API connection successful!');
        print('🎯 Server status: ${data['status']}');
        print('💬 Message: ${data['message']}');
      } else {
        print('❌ API connection failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 API connection error: $e');
    }
  }

  static Future<void> testLoginApi() async {
    try {
      print('🔄 Testing login API...');

      final response = await http
          .post(
            Uri.parse(ApiConfig.loginEndpoint),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'username': ApiConfig.defaultUsername,
              'password': ApiConfig.defaultPassword,
            }),
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Login response status: ${response.statusCode}');
      print('📝 Login response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ Login API successful!');
      } else {
        print('❌ Login API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Login API error: $e');
    }
  }

  static Future<void> testProductsApi() async {
    try {
      print('🔄 Testing products API...');

      final response = await http
          .get(
            Uri.parse('${ApiConfig.productsEndpoint}?limit=5'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      print('📊 Products response status: ${response.statusCode}');
      print(
        '📝 Products response: ${response.body.length > 200 ? response.body.substring(0, 200) + "..." : response.body}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Products API successful!');
        print('📦 Found ${data['data']?.length ?? 0} products');
      } else {
        print('❌ Products API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 Products API error: $e');
    }
  }

  static Future<void> runAllTests() async {
    print('🚀 Starting API connectivity tests...');
    print('=' * 50);

    await testApiConnection();
    print('-' * 30);

    await testLoginApi();
    print('-' * 30);

    await testProductsApi();
    print('=' * 50);
    print('🎯 API tests completed!');
  }
}
