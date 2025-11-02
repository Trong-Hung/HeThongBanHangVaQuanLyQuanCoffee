import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ReportsService {
  static const String baseUrl = 'http://10.0.2.2:3000/api/reports';

  /// Xác thực mật khẩu để lấy report token
  /// POST /api/reports/verify-password
  Future<Map<String, dynamic>> verifyPassword(String password) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      if (authToken == null) {
        print('❌ Không có auth token');
        return {'success': false, 'message': 'Không tìm thấy token xác thực'};
      }

      print('🔐 Đang xác thực mật khẩu...');

      final response = await http.post(
        Uri.parse('$baseUrl/verify-password'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'password': password}),
      );

      print('🔐 Response status: ${response.statusCode}');
      print('🔐 Response body: ${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        // Lưu report token
        final reportToken = responseData['reportToken'];
        await _storeReportToken(reportToken);

        return {
          'success': true,
          'message': responseData['message'] ?? 'Xác thực thành công',
          'reportToken': reportToken,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Mật khẩu không chính xác',
        };
      }
    } catch (e) {
      print('❌ Lỗi xác thực mật khẩu: $e');
      return {'success': false, 'message': 'Lỗi kết nối: ${e.toString()}'};
    }
  }

  /// Lấy báo cáo theo ngày
  /// GET /api/reports/daily (cần report token)
  Future<Map<String, dynamic>?> getDailyReport({String? date}) async {
    try {
      final reportToken = await _getValidReportToken();
      if (reportToken == null) {
        print('❌ Không có report token hợp lệ');
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      String targetDate =
          date ?? DateTime.now().toIso8601String().split('T')[0];

      print('📊 Lấy báo cáo ngày: $targetDate');

      final response = await http.get(
        Uri.parse('$baseUrl/daily?date=$targetDate&reportToken=$reportToken'),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Response status: ${response.statusCode}');
      print('📊 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      } else if (response.statusCode == 401) {
        // Token hết hạn, xóa
        await clearReportToken();
      }
      return null;
    } catch (e) {
      print('❌ Lỗi lấy báo cáo ngày: $e');
      return null;
    }
  }

  /// Lấy danh sách đơn hàng
  /// POST /api/reports/orders-detail (cần report token)
  Future<Map<String, dynamic>?> getOrdersList({
    String? startDate,
    String? endDate,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final reportToken = await _getValidReportToken();
      if (reportToken == null) {
        print('❌ Không có report token hợp lệ');
        return null;
      }

      final prefs = await SharedPreferences.getInstance();
      final authToken = prefs.getString('auth_token');

      String start =
          startDate ?? DateTime.now().toIso8601String().split('T')[0];
      String end = endDate ?? DateTime.now().toIso8601String().split('T')[0];

      print('📋 Lấy danh sách đơn hàng: $start - $end (trang $page)');

      final response = await http.get(
        Uri.parse(
          '$baseUrl/orders?startDate=$start&endDate=$end&page=$page&limit=$limit&reportToken=$reportToken',
        ),
        headers: {
          'Authorization': 'Bearer $authToken',
          'Content-Type': 'application/json',
        },
      );

      print('📋 Response status: ${response.statusCode}');
      print('📋 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          return data;
        }
      } else if (response.statusCode == 401) {
        // Token hết hạn, xóa
        await clearReportToken();
      }
      return null;
    } catch (e) {
      print('❌ Lỗi lấy danh sách đơn hàng: $e');
      return null;
    }
  }

  /// Lưu report token với thời hạn 30 phút
  Future<void> _storeReportToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('report_token', token);

    // Token hết hạn sau 30 phút
    final expiry = DateTime.now().add(const Duration(minutes: 30));
    await prefs.setString('report_token_expiry', expiry.toIso8601String());

    print('🔐 Report token đã lưu, hết hạn: ${expiry.toIso8601String()}');
  }

  /// Lấy report token hợp lệ
  Future<String?> _getValidReportToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('report_token');
    final expiryString = prefs.getString('report_token_expiry');

    if (token == null || expiryString == null) {
      print('🔐 Không có report token');
      return null;
    }

    final expiry = DateTime.parse(expiryString);
    if (DateTime.now().isAfter(expiry)) {
      print('🔐 Report token đã hết hạn');
      await clearReportToken();
      return null;
    }

    print('🔐 Report token hợp lệ');
    return token;
  }

  /// Xóa report token
  Future<void> clearReportToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('report_token');
    await prefs.remove('report_token_expiry');
    print('🔐 Report token đã xóa');
  }

  /// Kiểm tra xem có report token hợp lệ không
  Future<bool> hasValidReportToken() async {
    final token = await _getValidReportToken();
    return token != null;
  }

  /// Format số tiền cho hiển thị
  static String formatMoney(double amount) {
    return amount.toInt().toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// Format ngày cho hiển thị
  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  /// Tên phương thức thanh toán tiếng Việt
  static String getPaymentMethodName(String method) {
    switch (method.toUpperCase()) {
      case 'CASH':
        return 'Tiền mặt';
      case 'BANK_TRANSFER':
        return 'Chuyển khoản';
      case 'CARD':
        return 'Thẻ';
      case 'MOMO':
        return 'Ví MoMo';
      default:
        return method;
    }
  }
}
