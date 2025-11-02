import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/product.dart';
import 'auth_service.dart';

class ProductService {
  // Get all products
  static Future<ProductsResponse> getProducts({
    int page = 1,
    int limit = 10,
    int? categoryId,
    bool? isActive,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      // Build query parameters
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null) {
        queryParams['category_id'] = categoryId.toString();
      }

      if (isActive != null) {
        queryParams['is_active'] = isActive.toString();
      }

      final uri = Uri.parse(
        ApiConfig.productsEndpoint,
      ).replace(queryParameters: queryParams);

      final response = await http
          .get(uri, headers: headers)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return ProductsResponse.fromJson(jsonDecode(response.body));
      } else {
        // Handle specific error cases for products by category
        String errorMessage = 'Lỗi tải sản phẩm';
        if (response.statusCode == 500) {
          // If filter by category fails, try to load all products instead
          if (categoryId != null) {
            return getProducts(
              page: page,
              limit: limit,
              categoryId: null, // Remove category filter
              isActive: isActive,
            );
          }
          errorMessage = 'Lỗi server - Vui lòng thử lại sau';
        } else if (response.statusCode == 401) {
          errorMessage = 'Phiên đăng nhập hết hạn';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('ProductService error: $e');
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout - Kiểm tra kết nối mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      throw Exception('Lỗi tải sản phẩm: ${e.toString()}');
    }
  }

  // Get product by ID
  static Future<Product> getProduct(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .get(Uri.parse('${ApiConfig.productsEndpoint}/$id'), headers: headers)
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Product.fromJson(responseData['data']);
      } else {
        throw Exception('Get product failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Get product error: $e');
    }
  }

  // Create product
  static Future<Product> createProduct({
    required String name,
    required double price,
    required String description,
    required int categoryId,
    bool isActive = true,
    String? imageUrl,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .post(
            Uri.parse(ApiConfig.productsEndpoint),
            headers: headers,
            body: jsonEncode({
              'name': name,
              'price': price,
              'description': description,
              'category_id': categoryId,
              'is_active': isActive,
              if (imageUrl != null) 'image_url': imageUrl,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Product.fromJson(responseData['data']);
      } else {
        throw Exception('Create product failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Create product error: $e');
    }
  }

  // Update product
  static Future<Product> updateProduct({
    required int id,
    String? name,
    double? price,
    String? description,
    int? categoryId,
    bool? isActive,
    String? imageUrl,
  }) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final body = <String, dynamic>{};
      if (name != null) body['name'] = name;
      if (price != null) body['price'] = price;
      if (description != null) body['description'] = description;
      if (categoryId != null) body['category_id'] = categoryId;
      if (isActive != null) body['is_active'] = isActive;
      if (imageUrl != null) body['image_url'] = imageUrl;

      final response = await http
          .put(
            Uri.parse('${ApiConfig.productsEndpoint}/$id'),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return Product.fromJson(responseData['data']);
      } else {
        throw Exception('Update product failed: ${response.body}');
      }
    } catch (e) {
      throw Exception('Update product error: $e');
    }
  }

  // Delete product
  static Future<bool> deleteProduct(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.productsEndpoint}/$id'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true; // Success
      } else if (response.statusCode == 404) {
        throw Exception('Sản phẩm không tồn tại');
      } else if (response.statusCode == 400) {
        final responseData = jsonDecode(response.body);
        final errorMessage =
            responseData['message'] ?? 'Lỗi yêu cầu không hợp lệ';

        // Check for constraint violations
        if (errorMessage.contains('constraint') ||
            errorMessage.contains('foreign key') ||
            errorMessage.contains('referenced') ||
            errorMessage.contains('still in use') ||
            errorMessage.contains('order') ||
            errorMessage.contains('đang sử dụng')) {
          throw Exception(
            'Bạn không thể xóa sản phẩm này vì đang nằm trong order. Bạn có thể tắt hoặc ẩn sản phẩm này thay vì xóa.',
          );
        } else {
          throw Exception('Không thể xóa sản phẩm: $errorMessage');
        }
      } else if (response.statusCode == 409) {
        throw Exception(
          'Bạn không thể xóa sản phẩm này vì đang nằm trong order. Bạn có thể tắt hoặc ẩn sản phẩm này thay vì xóa.',
        );
      } else if (response.statusCode == 500) {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Lỗi server';

        // Check for constraint violations in server error
        if (errorMessage.contains('constraint') ||
            errorMessage.contains('foreign key') ||
            errorMessage.contains('referenced') ||
            errorMessage.contains('order') ||
            errorMessage.contains('đang sử dụng')) {
          throw Exception(
            'Bạn không thể xóa sản phẩm này vì đang nằm trong order. Bạn có thể tắt hoặc ẩn sản phẩm này thay vì xóa.',
          );
        } else {
          throw Exception('Lỗi server - Không thể xóa sản phẩm: $errorMessage');
        }
      } else {
        throw Exception('Xóa sản phẩm thất bại: ${response.body}');
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception('Timeout - Kiểm tra kết nối mạng');
      } else if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối - Kiểm tra internet');
      }
      rethrow;
    }
  }

  // Toggle product active/inactive status
  static Future<Product> toggleProductStatus(int id, bool isActive) async {
    return updateProduct(id: id, isActive: isActive);
  }

  // Force delete product (for admin)
  static Future<bool> forceDeleteProduct(int id) async {
    try {
      final headers = await AuthService.getAuthHeaders();

      final response = await http
          .delete(
            Uri.parse('${ApiConfig.productsEndpoint}/$id?force=true'),
            headers: headers,
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode == 200) {
        return true; // Success
      } else if (response.statusCode == 404) {
        throw Exception('Sản phẩm không tồn tại');
      } else if (response.statusCode == 403) {
        throw Exception('Không có quyền xóa vĩnh viễn sản phẩm');
      } else {
        throw Exception('Xóa vĩnh viễn sản phẩm thất bại: ${response.body}');
      }
    } catch (e) {
      print('ForceDeleteProduct error: $e');
      throw Exception('Lỗi xóa vĩnh viễn sản phẩm: ${e.toString()}');
    }
  }
}
