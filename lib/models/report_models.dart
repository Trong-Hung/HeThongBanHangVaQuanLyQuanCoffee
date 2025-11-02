/// Models cho báo cáo theo đúng API response

class ReportStatistics {
  final int totalOrders;
  final double totalRevenue;
  final double avgOrderValue;
  final double minOrderValue;
  final double maxOrderValue;

  ReportStatistics({
    required this.totalOrders,
    required this.totalRevenue,
    required this.avgOrderValue,
    required this.minOrderValue,
    required this.maxOrderValue,
  });

  factory ReportStatistics.fromJson(Map<String, dynamic> json) {
    return ReportStatistics(
      totalOrders: json['totalOrders'] ?? 0,
      totalRevenue: (json['totalRevenue'] ?? 0).toDouble(),
      avgOrderValue: (json['avgOrderValue'] ?? 0).toDouble(),
      minOrderValue: (json['minOrderValue'] ?? 0).toDouble(),
      maxOrderValue: (json['maxOrderValue'] ?? 0).toDouble(),
    );
  }
}

class OrderItem {
  final int id;
  final double totalAmount;
  final String paymentMethod;
  final DateTime createdAt;
  final String note;
  final int itemCount;
  final String itemsSummary;

  OrderItem({
    required this.id,
    required this.totalAmount,
    required this.paymentMethod,
    required this.createdAt,
    required this.note,
    required this.itemCount,
    required this.itemsSummary,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paymentMethod: json['paymentMethod'] ?? '',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      note: json['note'] ?? '',
      itemCount: json['itemCount'] ?? 0,
      itemsSummary: json['itemsSummary'] ?? '',
    );
  }
}

class PaymentBreakdown {
  final String method;
  final int orderCount;
  final double totalAmount;
  final double percentage;

  PaymentBreakdown({
    required this.method,
    required this.orderCount,
    required this.totalAmount,
    required this.percentage,
  });

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      method: json['method'] ?? '',
      orderCount: json['orderCount'] ?? 0,
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class DailyReport {
  final String date;
  final ReportStatistics statistics;
  final List<OrderItem> orders;
  final List<PaymentBreakdown> paymentBreakdown;

  DailyReport({
    required this.date,
    required this.statistics,
    required this.orders,
    required this.paymentBreakdown,
  });

  factory DailyReport.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return DailyReport(
      date: data['date'] ?? '',
      statistics: ReportStatistics.fromJson(data['statistics'] ?? {}),
      orders: (data['orders'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      paymentBreakdown: (data['paymentBreakdown'] as List<dynamic>? ?? [])
          .map(
            (item) => PaymentBreakdown.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
