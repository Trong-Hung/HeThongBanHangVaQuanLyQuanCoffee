class Order {
  final int id;
  final int userId;
  final double totalAmount;
  final String paymentMethod;
  final DateTime orderDate;
  final String status;
  final String? note;
  final String username;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.orderDate,
    required this.status,
    this.note,
    required this.username,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: double.parse(json['total_amount'].toString()),
      paymentMethod: json['payment_method'],
      orderDate: DateTime.parse(json['order_date'] ?? json['created_at']),
      status: json['status'],
      note: json['note'] ?? json['notes'],
      username: json['username'] ?? '',
      items: json['items'] != null
          ? (json['items'] as List)
                .map((item) => OrderItem.fromJson(item))
                .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'total_amount': totalAmount.toString(),
      'payment_method': paymentMethod,
      'order_date': orderDate.toIso8601String(),
      'status': status,
      'note': note,
      'username': username,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }
}

class OrderItem {
  final int id;
  final int productId;
  final int quantity;
  final double unitPrice;
  final String? note;
  final String? productName;
  final String? productImage;
  final double? totalPrice;

  OrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.note,
    this.productName,
    this.productImage,
    this.totalPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      note: json['note'] ?? json['notes'],
      productName: json['product_name'],
      productImage: json['product_image'],
      totalPrice: json['total_price'] != null
          ? double.parse(json['total_price'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'quantity': quantity,
      'unit_price': unitPrice.toString(),
      'total_price': totalPrice?.toString(),
      'note': note,
      'product_name': productName,
      'product_image': productImage,
    };
  }
}

class OrdersResponse {
  final bool success;
  final String message;
  final List<Order> data;
  final OrderSummary? summary;
  final Pagination pagination;

  OrdersResponse({
    required this.success,
    required this.message,
    required this.data,
    this.summary,
    required this.pagination,
  });

  factory OrdersResponse.fromJson(Map<String, dynamic> json) {
    return OrdersResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List).map((item) => Order.fromJson(item)).toList(),
      summary: json['summary'] != null
          ? OrderSummary.fromJson(json['summary'])
          : null,
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class OrderSummary {
  final double totalRevenue;
  final int totalOrdersInPage;

  OrderSummary({required this.totalRevenue, required this.totalOrdersInPage});

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      totalRevenue: json['total_revenue'].toDouble(),
      totalOrdersInPage: json['total_orders_in_page'],
    );
  }
}

class CreateOrderRequest {
  final List<CreateOrderItem> items;
  final String paymentMethod;
  final String? note;

  CreateOrderRequest({
    required this.items,
    required this.paymentMethod,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'payment_method': paymentMethod,
      'note': note,
    };
  }
}

class CreateOrderItem {
  final int productId;
  final int quantity;
  final String? note;

  CreateOrderItem({required this.productId, required this.quantity, this.note});

  Map<String, dynamic> toJson() {
    return {'product_id': productId, 'quantity': quantity, 'note': note};
  }
}

class OrderStatsResponse {
  final bool success;
  final String message;
  final OrderStats data;

  OrderStatsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrderStatsResponse.fromJson(Map<String, dynamic> json) {
    return OrderStatsResponse(
      success: json['success'],
      message: json['message'],
      data: OrderStats.fromJson(json['data']),
    );
  }
}

class OrderStats {
  final OrderOverview overview;
  final List<PaymentMethodStat> paymentMethods;
  final List<DailyStat> dailyStats;

  OrderStats({
    required this.overview,
    required this.paymentMethods,
    required this.dailyStats,
  });

  factory OrderStats.fromJson(Map<String, dynamic> json) {
    return OrderStats(
      overview: OrderOverview.fromJson(json['overview']),
      paymentMethods: (json['payment_methods'] as List)
          .map((item) => PaymentMethodStat.fromJson(item))
          .toList(),
      dailyStats: (json['daily_stats'] as List)
          .map((item) => DailyStat.fromJson(item))
          .toList(),
    );
  }
}

class OrderOverview {
  final int totalOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final double minOrderValue;
  final double maxOrderValue;

  OrderOverview({
    required this.totalOrders,
    required this.totalRevenue,
    required this.averageOrderValue,
    required this.minOrderValue,
    required this.maxOrderValue,
  });

  factory OrderOverview.fromJson(Map<String, dynamic> json) {
    return OrderOverview(
      totalOrders: _parseInt(json['total_orders']),
      totalRevenue: _parseDouble(json['total_revenue']),
      averageOrderValue: _parseDouble(json['average_order_value']),
      minOrderValue: _parseDouble(json['min_order_value']),
      maxOrderValue: _parseDouble(json['max_order_value']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class PaymentMethodStat {
  final String paymentMethod;
  final int orderCount;
  final double revenue;

  PaymentMethodStat({
    required this.paymentMethod,
    required this.orderCount,
    required this.revenue,
  });

  factory PaymentMethodStat.fromJson(Map<String, dynamic> json) {
    return PaymentMethodStat(
      paymentMethod: json['payment_method'] ?? '',
      orderCount: _parseInt(json['order_count']),
      revenue: _parseDouble(json['revenue']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class DailyStat {
  final String date;
  final int orders;
  final double revenue;

  DailyStat({required this.date, required this.orders, required this.revenue});

  factory DailyStat.fromJson(Map<String, dynamic> json) {
    return DailyStat(
      date: json['date'] ?? '',
      orders: _parseInt(json['orders']),
      revenue: _parseDouble(json['revenue']),
    );
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
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
