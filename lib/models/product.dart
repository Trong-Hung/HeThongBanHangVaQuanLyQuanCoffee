class Product {
  final int id;
  final String name;
  final double price;
  final String? description;
  final String? imageUrl;
  final int? categoryId;
  final String? categoryName;
  final int userId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
    this.imageUrl,
    this.categoryId,
    this.categoryName,
    required this.userId,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
  });

  // Compatibility getter
  bool get isAvailable => isActive;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      price: json['price'] != null
          ? double.parse(json['price'].toString())
          : 0.0,
      description: json['description'],
      imageUrl: json['image_url'],
      categoryId: json['category_id'],
      categoryName: json['category_name'],
      userId: json['user_id'] ?? 0,
      isActive: json['is_active'] ?? json['is_available'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'image_url': imageUrl,
      'category_id': categoryId,
      'category_name': categoryName,
      'user_id': userId,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class ProductsResponse {
  final bool success;
  final String message;
  final List<Product> data;
  final Pagination pagination;

  ProductsResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.pagination,
  });

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    return ProductsResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((item) => Product.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      currentPage: json['current_page'],
      totalPages: json['total_pages'],
      totalItems: json['total_items'],
      itemsPerPage: json['items_per_page'],
    );
  }
}
