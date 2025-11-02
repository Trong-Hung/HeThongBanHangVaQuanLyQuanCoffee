class DailyOrder {
  final int dailyId;
  final int orderId;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final String? note;
  final String workStatus;
  final DateTime? completedAt;
  final int itemCount;
  final String itemsSummary;

  DailyOrder({
    required this.dailyId,
    required this.orderId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    this.note,
    required this.workStatus,
    this.completedAt,
    required this.itemCount,
    required this.itemsSummary,
  });

  factory DailyOrder.fromJson(Map<String, dynamic> json) {
    // Debug: Log payment method parsing
    final paymentMethod = json['paymentMethod'] ?? '';
    print(
      '🔄 Parsing DailyOrder ${json['orderId']}: paymentMethod = "$paymentMethod"',
    );

    return DailyOrder(
      dailyId: json['dailyId'] ?? 0,
      orderId: json['orderId'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: paymentMethod,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      note: json['note'],
      workStatus: json['workStatus'] ?? 'IN_PROGRESS',
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
      itemCount: json['itemCount'] ?? 0,
      itemsSummary: json['itemsSummary'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'dailyId': dailyId,
      'orderId': orderId,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt.toIso8601String(),
      'note': note,
      'workStatus': workStatus,
      'completedAt': completedAt?.toIso8601String(),
      'itemCount': itemCount,
      'itemsSummary': itemsSummary,
    };
  }

  bool get isInProgress => workStatus == 'IN_PROGRESS';
  bool get isCompleted => workStatus == 'COMPLETED';

  String get statusText => isCompleted ? 'Làm xong' : 'Đang làm';

  String get paymentMethodText {
    // Debug: Log payment method conversion
    final result = switch (paymentMethod) {
      'CASH' => 'Tiền mặt',
      'CARD' => 'Thẻ',
      'BANK_TRANSFER' => 'Chuyển khoản',
      _ => paymentMethod,
    };
    print('💳 Converting paymentMethod "$paymentMethod" → "$result"');
    return result;
  }
}

class DailyOrderDetail {
  final DailyOrder order;
  final List<OrderItem> items;
  final UserInfo userInfo;

  DailyOrderDetail({
    required this.order,
    required this.items,
    required this.userInfo,
  });

  factory DailyOrderDetail.fromJson(Map<String, dynamic> json) {
    return DailyOrderDetail(
      order: DailyOrder.fromJson(json['order'] ?? {}),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      userInfo: UserInfo.fromJson(json['userInfo'] ?? {}),
    );
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String name;
  final int quantity;
  final double unitPrice;
  final double currentPrice;
  final String? itemNote;
  final double itemTotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    required this.currentPrice,
    this.itemNote,
    required this.itemTotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      productId: json['productId'] ?? 0,
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      currentPrice: (json['currentPrice'] ?? 0).toDouble(),
      itemNote: json['itemNote'],
      itemTotal: (json['itemTotal'] ?? 0).toDouble(),
    );
  }
}

class UserInfo {
  final String username;
  final String name;

  UserInfo({required this.username, required this.name});

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(username: json['username'] ?? '', name: json['name'] ?? '');
  }
}

class DailyStats {
  final int totalOrders;
  final int inProgressCount;
  final int completedCount;
  final double totalRevenue;

  DailyStats({
    required this.totalOrders,
    required this.inProgressCount,
    required this.completedCount,
    required this.totalRevenue,
  });

  factory DailyStats.fromJson(Map<String, dynamic> json) {
    return DailyStats(
      totalOrders: json['totalOrders'] ?? 0,
      inProgressCount: json['inProgressCount'] ?? 0,
      completedCount: json['completedCount'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
    );
  }
}

class DailyOrdersResponse {
  final List<DailyOrder> orders;
  final DailyStats stats;
  final String workDate;

  DailyOrdersResponse({
    required this.orders,
    required this.stats,
    required this.workDate,
  });

  factory DailyOrdersResponse.fromJson(Map<String, dynamic> json) {
    return DailyOrdersResponse(
      orders: (json['orders'] as List<dynamic>? ?? [])
          .map((order) => DailyOrder.fromJson(order))
          .toList(),
      stats: DailyStats.fromJson(json['stats'] ?? {}),
      workDate: json['workDate'] ?? '',
    );
  }
}
