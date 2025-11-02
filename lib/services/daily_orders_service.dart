import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/daily_order.dart';
import '../services/auth_service.dart';

class DailyOrdersService {
  static const String baseEndpoint = '/api/daily-orders';

  static Map<String, String> get _headers {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  static Future<Map<String, String>> _getAuthHeaders() async {
    final token = await AuthService.getToken();
    return {..._headers, 'Authorization': 'Bearer $token'};
  }

  // GET /api/daily-orders - Lấy danh sách đơn hàng hôm nay
  static Future<DailyOrdersResponse> getDailyOrders() async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$baseEndpoint'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          // Debug: Log response data to check payment methods
          print('🔍 Daily Orders API Response:');
          final data = jsonResponse['data'];
          if (data['orders'] != null) {
            for (var order in data['orders']) {
              print(
                '📋 Order ${order['orderId']}: paymentMethod = ${order['paymentMethod']}',
              );
            }
          }

          return DailyOrdersResponse.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Lỗi khi lấy danh sách đơn hàng',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting daily orders: $e');
      rethrow;
    }
  }

  // GET /api/daily-orders/{id} - Chi tiết đơn hàng
  static Future<DailyOrderDetail> getOrderDetail(int orderId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}$baseEndpoint/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] == true) {
          return DailyOrderDetail.fromJson(jsonResponse['data']);
        } else {
          throw Exception(
            jsonResponse['message'] ?? 'Lỗi khi lấy chi tiết đơn hàng',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy đơn hàng');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting order detail: $e');
      rethrow;
    }
  }

  // PUT /api/daily-orders/{id}/complete - Đánh dấu hoàn thành
  static Future<void> completeOrder(int orderId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$baseEndpoint/$orderId/complete'),
        headers: headers,
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] != true) {
          throw Exception(
            jsonResponse['message'] ?? 'Lỗi khi đánh dấu hoàn thành',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy đơn hàng hoặc đơn hàng đã hoàn thành');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error completing order: $e');
      rethrow;
    }
  }

  // PUT /api/daily-orders/{id}/restart - Chuyển về đang làm
  static Future<void> restartOrder(int orderId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$baseEndpoint/$orderId/restart'),
        headers: headers,
        body: json.encode({}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] != true) {
          throw Exception(
            jsonResponse['message'] ?? 'Lỗi khi chuyển về đang làm',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception(
          'Không tìm thấy đơn hàng hoặc đơn hàng chưa hoàn thành',
        );
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error restarting order: $e');
      rethrow;
    }
  }

  // DELETE /api/daily-orders/{id} - Xóa khỏi danh sách hôm nay
  static Future<void> deleteFromToday(int orderId) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$baseEndpoint/$orderId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        if (jsonResponse['success'] != true) {
          throw Exception(jsonResponse['message'] ?? 'Lỗi khi xóa đơn hàng');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.');
      } else if (response.statusCode == 404) {
        throw Exception('Không tìm thấy đơn hàng trong danh sách hôm nay');
      } else {
        throw Exception('Lỗi server: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting order from today: $e');
      rethrow;
    }
  }
}
