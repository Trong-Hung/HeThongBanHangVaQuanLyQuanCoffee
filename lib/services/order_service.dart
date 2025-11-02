import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/order.dart';
import '../models/shop_info.dart';
import 'auth_service.dart';

class OrderService {
  // Get all orders
  static Future<OrdersResponse> getOrders({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        ApiConfig.ordersEndpoint,
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return OrdersResponse.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Get orders failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get orders error: $e');
    }
  }

  // Get order by ID
  static Future<Order> getOrder(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(Uri.parse('${ApiConfig.ordersEndpoint}/$id'), headers: headers)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Order.fromJson(responseData['data']);
      } else {
        throw Exception('Get order failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get order error: $e');
    }
  }

  // Create order
  static Future<Order> createOrder(CreateOrderRequest orderRequest) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      print(
        '🛒 Creating order with request: ${jsonEncode(orderRequest.toJson())}',
      );

      final response = await http
          .post(
            Uri.parse(ApiConfig.ordersEndpoint),
            headers: headers,
            body: jsonEncode(orderRequest.toJson()),
          )
          .timeout(ApiConfig.requestTimeout);

      print('🛒 Create order response status: ${response.statusCode}');
      print('🛒 Create order response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        // Try different response structures
        if (responseData['data'] != null) {
          if (responseData['data']['order'] != null) {
            return Order.fromJson(responseData['data']['order']);
          } else {
            return Order.fromJson(responseData['data']);
          }
        } else {
          throw Exception('Invalid response structure: missing data field');
        }
      } else {
        throw Exception(
          'Create order failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('🛒 Create order error: $e');
      throw Exception('Create order error: $e');
    }
  }

  // Get order statistics
  static Future<OrderStatsResponse> getOrderStats({
    String? startDate,
    String? endDate,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final queryParams = <String, String>{};
      if (startDate != null) queryParams['start_date'] = startDate;
      if (endDate != null) queryParams['end_date'] = endDate;

      final uri = Uri.parse(
        ApiConfig.orderStatsEndpoint,
      ).replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

      print('📊 Getting order stats from: $uri');
      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.requestTimeout);

      print('📊 Order stats response: ${response.statusCode}');
      print('📊 Order stats body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return OrderStatsResponse.fromJson(responseData);
      } else {
        throw Exception(
          'Get order stats failed (${response.statusCode}): ${response.body}',
        );
      }
    } catch (e) {
      print('📊 Order stats error: $e');
      throw Exception('Get order stats error: $e');
    }
  }

  // Update order status
  static Future<Order> updateOrderStatus(int id, String status) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .put(
            Uri.parse('${ApiConfig.ordersEndpoint}/$id'),
            headers: headers,
            body: jsonEncode({'status': status}),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Order.fromJson(responseData['data']);
      } else {
        throw Exception('Update order status failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update order status error: $e');
    }
  }

  // Delete order
  static Future<bool> deleteOrder(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.ordersEndpoint}/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Delete order failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Delete order error: $e');
    }
  }
}

class ShopService {
  // Get public shop info (no auth required)
  static Future<ShopInfo> getPublicShopInfo() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.publicShopInfoEndpoint),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopInfo.fromJson(responseData['data']);
      } else {
        throw Exception('Get public shop info failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get public shop info error: $e');
    }
  }

  // Get shop info (with auth)
  static Future<ShopInfo> getShopInfo() async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(Uri.parse(ApiConfig.shopInfoEndpoint), headers: headers)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopInfo.fromJson(responseData['data']);
      } else {
        throw Exception('Get shop info failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get shop info error: $e');
    }
  }

  // Update shop info
  static Future<ShopInfo> updateShopInfo({
    required String shopName,
    required String address,
    required String phone,
    BankInfo? bankInfo,
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
        body['bank_info'] = bankInfo.toJson();
      }

      if (logoUrl != null) {
        body['logo_url'] = logoUrl;
      }

      final response = await http
          .put(
            Uri.parse(ApiConfig.shopInfoEndpoint),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return ShopInfo.fromJson(responseData['data']);
      } else {
        throw Exception('Update shop info failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update shop info error: $e');
    }
  }
}

class HealthService {
  // Health check
  static Future<bool> checkHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse(ApiConfig.healthEndpoint),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(ApiConfig.requestTimeout);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
