import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/momo_models.dart';
import '../services/auth_service.dart';

/// Service for handling MoMo payment API calls
class MomoApiService {
  // Use Android emulator URL for localhost
  static const String baseUrl = 'http://10.0.2.2:3000/api/momo';

  /// Create MoMo QR code for payment
  /// 
  /// Takes cart items and optional note, returns QR info and temp order data
  Future<MomoQRResponse> createQR({
    required List<MomoOrderItem> items,
    String? note,
  }) async {
    try {
      // Get current user token
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Prepare request
      final request = MomoQRRequest(items: items, note: note);
      
      print('🔄 Creating MoMo QR...');
      print('📦 Items: ${items.length}');
      print('💬 Note: $note');

      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl/create-qr'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true) {
          print('✅ MoMo QR created successfully');
          return MomoQRResponse.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to create MoMo QR');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Network error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating MoMo QR: $e');
      rethrow;
    }
  }

  /// Confirm MoMo payment after customer has paid
  /// 
  /// Takes temp order data and creates final order in database
  Future<PaymentConfirmResponse> confirmPayment({
    required TempOrderData tempOrderData,
  }) async {
    try {
      // Get current user token
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      // Prepare request
      final request = ConfirmPaymentRequest(tempOrderData: tempOrderData);
      
      print('🔄 Confirming MoMo payment...');
      print('🆔 Order ID: ${tempOrderData.orderId}');
      print('💰 Amount: ${tempOrderData.totalAmount}');

      // Make API call
      final response = await http.post(
        Uri.parse('$baseUrl/confirm-payment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 201) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true) {
          print('✅ MoMo payment confirmed successfully');
          return PaymentConfirmResponse.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to confirm payment');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Network error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error confirming MoMo payment: $e');
      rethrow;
    }
  }

  /// Check payment status (optional feature)
  /// 
  /// Returns current status of a MoMo order
  Future<PaymentStatusResponse> checkStatus({
    required String orderId,
  }) async {
    try {
      // Get current user token
      final token = await AuthService.getToken();
      if (token == null) {
        throw Exception('User not authenticated');
      }

      print('🔄 Checking MoMo payment status...');
      print('🆔 Order ID: $orderId');

      // Make API call
      final response = await http.get(
        Uri.parse('$baseUrl/check-status/$orderId'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      print('📡 Response status: ${response.statusCode}');
      print('📄 Response body: ${response.body}');

      // Handle response
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        
        if (jsonData['success'] == true) {
          print('✅ Status checked successfully');
          return PaymentStatusResponse.fromJson(jsonData['data']);
        } else {
          throw Exception(jsonData['message'] ?? 'Failed to check status');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Network error: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error checking MoMo status: $e');
      rethrow;
    }
  }

  /// Convert cart items to MoMo order items
  /// 
  /// Helper method to transform cart data to MoMo format
  static List<MomoOrderItem> convertCartToMomoItems(List<dynamic> cartItems) {
    return cartItems.map((item) {
      return MomoOrderItem(
        productId: item['id'] ?? item['product_id'],
        quantity: item['quantity'],
        note: item['note'],
      );
    }).toList();
  }

  /// Format amount for display
  /// 
  /// Helper method to format currency
  static String formatAmount(double amount) {
    return '${amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} VNĐ';
  }

  /// Validate MoMo order items before creating QR
  /// 
  /// Helper method to validate cart data
  static bool validateOrderItems(List<MomoOrderItem> items) {
    if (items.isEmpty) {
      print('❌ No items in order');
      return false;
    }

    for (final item in items) {
      if (item.productId <= 0) {
        print('❌ Invalid product ID: ${item.productId}');
        return false;
      }
      if (item.quantity <= 0) {
        print('❌ Invalid quantity: ${item.quantity}');
        return false;
      }
    }

    print('✅ Order items validation passed');
    return true;
  }
}