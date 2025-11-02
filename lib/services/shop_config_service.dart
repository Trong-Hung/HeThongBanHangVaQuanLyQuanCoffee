import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/shop_config.dart';
import 'auth_service.dart';

class ShopConfigService {
  // Get shop configuration
  static Future<ShopConfig> getShopConfig() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/config/shop'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopConfig.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy cấu hình cửa hàng');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Lỗi tải cấu hình cửa hàng');
        } catch (parseError) {
          throw Exception('Lỗi tải cấu hình cửa hàng');
        }
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối timeout - Kiểm tra mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      rethrow;
    }
  }

  // Update shop configuration
  static Future<ShopConfig> updateShopConfig(ShopConfig config) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/config/shop'),
            headers: headers,
            body: jsonEncode(config.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopConfig.fromJson(responseData['data']);
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại');
      } else if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          final errorMessage = errorData['message'] ?? 'Dữ liệu không hợp lệ';
          final errors = errorData['errors'] as List?;
          if (errors != null && errors.isNotEmpty) {
            throw Exception('$errorMessage: ${errors.join(', ')}');
          }
          throw Exception(errorMessage);
        } catch (parseError) {
          throw Exception('Dữ liệu không hợp lệ');
        }
      } else if (response.statusCode == 403) {
        throw Exception('Không có quyền cập nhật cấu hình cửa hàng');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Cập nhật cấu hình thất bại');
        } catch (parseError) {
          throw Exception('Cập nhật cấu hình thất bại');
        }
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Kết nối timeout - Kiểm tra mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      rethrow;
    }
  }
}
