import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/category.dart';
import 'auth_service.dart';

class CategoryService {
  // Get all categories
  static Future<CategoriesResponse> getCategories({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final uri = Uri.parse(
        ApiConfig.categoriesEndpoint,
      ).replace(queryParameters: queryParams);

      print('Calling API: $uri');
      print('Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.requestTimeout);

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return CategoriesResponse.fromJson(jsonDecode(response.body));
      } else {
        // Improved error handling with specific error messages
        String errorMessage = 'Lỗi tải danh mục';
        if (response.statusCode == 500) {
          errorMessage = 'Lỗi server (500) - Vui lòng thử lại sau';
        } else if (response.statusCode == 401) {
          errorMessage = 'Phiên đăng nhập hết hạn - Vui lòng đăng nhập lại';
        } else if (response.statusCode == 404) {
          errorMessage = 'Không tìm thấy danh mục';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('CategoryService error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout - Kiểm tra kết nối mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      throw Exception('Lỗi tải danh mục: ${e.toString()}');
    }
  }

  // Get category by ID
  static Future<Category> getCategory(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(
            Uri.parse('${ApiConfig.categoriesEndpoint}/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Category.fromJson(responseData['data']);
      } else {
        throw Exception('Get category failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get category error: $e');
    }
  }

  // Create category
  static Future<Category> createCategory({
    required String name,
    required String description,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .post(
            Uri.parse(ApiConfig.categoriesEndpoint),
            headers: headers,
            body: jsonEncode({'name': name, 'description': description}),
          )
          .timeout(ApiConfig.requestTimeout);

      print('Create category response: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Category.fromJson(responseData['data']);
      } else if (response.statusCode == 500) {
        throw Exception('Lỗi server - Không thể tạo danh mục mới');
      } else if (response.statusCode == 400) {
        throw Exception('Dữ liệu không hợp lệ - Kiểm tra tên danh mục');
      } else {
        throw Exception('Tạo danh mục thất bại');
      }
    } catch (e) {
      print('CreateCategory error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout - Kiểm tra kết nối mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      throw Exception('Lỗi tạo danh mục: ${e.toString()}');
    }
  }

  // Update category
  static Future<Category> updateCategory({
    required int id,
    String? name,
    String? description,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (description != null) body['description'] = description;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.categoriesEndpoint}/$id'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Category.fromJson(responseData['data']);
      } else {
        throw Exception('Update category failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update category error: $e');
    }
  }

  // Delete category
  static Future<bool> deleteCategory(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.categoriesEndpoint}/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true;
      } else {
        throw Exception('Delete category failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Delete category error: $e');
    }
  }
}
