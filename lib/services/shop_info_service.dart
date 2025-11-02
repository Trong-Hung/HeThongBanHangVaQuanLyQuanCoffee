import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/shop_info.dart';
import 'auth_service.dart';

class ShopInfoService {
  // Get shop info (public - no auth required)
  static Future<ShopInfo> getPublicShopInfo() async {
    try {
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/api/config/public/shop-info'))
          .timeout(ApiConfig.requestTimeout);

      print('Public shop info response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopInfo.fromJson(responseData['data']);
      } else {
        throw Exception('Lỗi tải thông tin cửa hàng');
      }
    } catch (e) {
      print('ShopInfoService error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout - Kiểm tra kết nối mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      throw Exception('Lỗi tải thông tin cửa hàng: ${e.toString()}');
    }
  }

  // Get shop info (with auth - may have issues according to docs)
  static Future<ShopInfo> getShopInfo() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(
            Uri.parse('${ApiConfig.baseUrl}/api/config/shop-info'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      print('Shop info response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopInfo.fromJson(responseData['data']);
      } else if (response.statusCode == 500) {
        // API has issues, fallback to public endpoint
        print('Auth endpoint failed, using public endpoint...');
        return getPublicShopInfo();
      } else {
        throw Exception('Lỗi tải thông tin cửa hàng');
      }
    } catch (e) {
      print('ShopInfoService auth error: $e');
      // Try public endpoint as fallback
      if (!e.toString().contains('Lỗi tải thông tin cửa hàng')) {
        print('Fallback to public endpoint...');
        return getPublicShopInfo();
      }
      throw e;
    }
  }

  // Update shop info
  static Future<ShopInfo> updateShopInfo({
    required String shopName,
    required String address,
    required String phone,
    Map<String, String>? bankInfo,
    String? logoUrl,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final body = <String, dynamic>{
        'shop_name': shopName,
        'address': address,
        'phone': phone,
      };

      if (bankInfo != null) {
        body['bank_info'] = bankInfo;
      }
      if (logoUrl != null) {
        body['logo_url'] = logoUrl;
      }

      final response = await http
          .put(
            Uri.parse('${ApiConfig.baseUrl}/api/config/shop-info'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      print('Update shop info response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopInfo.fromJson(responseData['data']);
      } else if (response.statusCode == 500) {
        throw Exception('Lỗi server - Không thể cập nhật thông tin cửa hàng');
      } else {
        throw Exception('Cập nhật thông tin cửa hàng thất bại');
      }
    } catch (e) {
      print('UpdateShopInfo error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout - Kiểm tra kết nối mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      throw Exception('Lỗi cập nhật thông tin cửa hàng: ${e.toString()}');
    }
  }
}
