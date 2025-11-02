// MoMo Payment Models
// Based on API documentation: http://localhost:3000/api/momo

/// Request model for creating MoMo QR code
class MomoQRRequest {
  final List<MomoOrderItem> items;
  final String? note;

  MomoQRRequest({
    required this.items,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      if (note != null) 'note': note,
    };
  }
}

/// Order item for MoMo request
class MomoOrderItem {
  final int productId;
  final int quantity;
  final String? note;

  MomoOrderItem({
    required this.productId,
    required this.quantity,
    this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'quantity': quantity,
      if (note != null) 'note': note,
    };
  }
}

/// Response model for MoMo QR creation
class MomoQRResponse {
  final QRInfo qrInfo;
  final OrderPreview orderPreview;
  final TempOrderData tempOrderData;

  MomoQRResponse({
    required this.qrInfo,
    required this.orderPreview,
    required this.tempOrderData,
  });

  factory MomoQRResponse.fromJson(Map<String, dynamic> json) {
    return MomoQRResponse(
      qrInfo: QRInfo.fromJson(json['qr_info']),
      orderPreview: OrderPreview.fromJson(json['order_preview']),
      tempOrderData: TempOrderData.fromJson(json['temp_order_data']),
    );
  }
}

/// QR code information
class QRInfo {
  final String qrCodeUrl;
  final String payUrl;
  final String deeplink;
  final double amount;
  final String orderId;
  final String orderInfo;

  QRInfo({
    required this.qrCodeUrl,
    required this.payUrl,
    required this.deeplink,
    required this.amount,
    required this.orderId,
    required this.orderInfo,
  });

  factory QRInfo.fromJson(Map<String, dynamic> json) {
    return QRInfo(
      qrCodeUrl: json['qr_code_url'],
      payUrl: json['pay_url'],
      deeplink: json['deeplink'],
      amount: double.parse(json['amount'].toString()),
      orderId: json['order_id'],
      orderInfo: json['order_info'],
    );
  }
}

/// Order preview from MoMo response
class OrderPreview {
  final List<OrderPreviewItem> items;
  final double totalAmount;
  final String? note;
  final String paymentMethod;

  OrderPreview({
    required this.items,
    required this.totalAmount,
    this.note,
    required this.paymentMethod,
  });

  factory OrderPreview.fromJson(Map<String, dynamic> json) {
    return OrderPreview(
      items: (json['items'] as List)
          .map((item) => OrderPreviewItem.fromJson(item))
          .toList(),
      totalAmount: double.parse(json['total_amount'].toString()),
      note: json['note'],
      paymentMethod: json['payment_method'],
    );
  }
}

/// Order preview item
class OrderPreviewItem {
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final String? note;

  OrderPreviewItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    this.note,
  });

  factory OrderPreviewItem.fromJson(Map<String, dynamic> json) {
    return OrderPreviewItem(
      productId: json['product_id'],
      productName: json['product_name'],
      quantity: json['quantity'],
      unitPrice: double.parse(json['unit_price'].toString()),
      subtotal: double.parse(json['subtotal'].toString()),
      note: json['note'],
    );
  }
}

/// Temporary order data for confirmation
class TempOrderData {
  final String orderId;
  final int userId;
  final List<Map<String, dynamic>> items;
  final double totalAmount;
  final String? note;
  final Map<String, dynamic> momoData;
  final String createdAt;

  TempOrderData({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.totalAmount,
    this.note,
    required this.momoData,
    required this.createdAt,
  });

  factory TempOrderData.fromJson(Map<String, dynamic> json) {
    return TempOrderData(
      orderId: json['orderId'],
      userId: json['userId'],
      items: List<Map<String, dynamic>>.from(json['items']),
      totalAmount: double.parse(json['totalAmount'].toString()),
      note: json['note'],
      momoData: Map<String, dynamic>.from(json['momoData']),
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'userId': userId,
      'items': items,
      'totalAmount': totalAmount,
      if (note != null) 'note': note,
      'momoData': momoData,
      'createdAt': createdAt,
    };
  }
}

/// Request model for confirming payment
class ConfirmPaymentRequest {
  final TempOrderData tempOrderData;

  ConfirmPaymentRequest({
    required this.tempOrderData,
  });

  Map<String, dynamic> toJson() {
    return {
      'temp_order_data': tempOrderData.toJson(),
    };
  }
}

/// Response model for payment confirmation
class PaymentConfirmResponse {
  final ConfirmedOrder order;
  final List<ConfirmedOrderItem> items;
  final OrderSummary summary;

  PaymentConfirmResponse({
    required this.order,
    required this.items,
    required this.summary,
  });

  factory PaymentConfirmResponse.fromJson(Map<String, dynamic> json) {
    return PaymentConfirmResponse(
      order: ConfirmedOrder.fromJson(json['order']),
      items: (json['items'] as List)
          .map((item) => ConfirmedOrderItem.fromJson(item))
          .toList(),
      summary: OrderSummary.fromJson(json['summary']),
    );
  }
}

/// Confirmed order details
class ConfirmedOrder {
  final int id;
  final int userId;
  final String totalAmount;
  final String paymentMethod;
  final String paymentMethodDisplay;
  final String orderDate;
  final String status;
  final String? note;
  final String createdAt;
  final String momoOrderId;

  ConfirmedOrder({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
    required this.orderDate,
    required this.status,
    this.note,
    required this.createdAt,
    required this.momoOrderId,
  });

  factory ConfirmedOrder.fromJson(Map<String, dynamic> json) {
    return ConfirmedOrder(
      id: json['id'],
      userId: json['user_id'],
      totalAmount: json['total_amount'],
      paymentMethod: json['payment_method'],
      paymentMethodDisplay: json['payment_method_display'],
      orderDate: json['order_date'],
      status: json['status'],
      note: json['note'],
      createdAt: json['created_at'],
      momoOrderId: json['momo_order_id'],
    );
  }
}

/// Confirmed order item
class ConfirmedOrderItem {
  final int id;
  final int productId;
  final int quantity;
  final String unitPrice;
  final String? note;

  ConfirmedOrderItem({
    required this.id,
    required this.productId,
    required this.quantity,
    required this.unitPrice,
    this.note,
  });

  factory ConfirmedOrderItem.fromJson(Map<String, dynamic> json) {
    return ConfirmedOrderItem(
      id: json['id'],
      productId: json['product_id'],
      quantity: json['quantity'],
      unitPrice: json['unit_price'],
      note: json['note'],
    );
  }
}

/// Order summary
class OrderSummary {
  final int totalItems;
  final int totalQuantity;
  final String totalAmount;
  final String paymentMethod;
  final String paymentMethodDisplay;

  OrderSummary({
    required this.totalItems,
    required this.totalQuantity,
    required this.totalAmount,
    required this.paymentMethod,
    required this.paymentMethodDisplay,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      totalItems: json['total_items'],
      totalQuantity: json['total_quantity'],
      totalAmount: json['total_amount'],
      paymentMethod: json['payment_method'],
      paymentMethodDisplay: json['payment_method_display'],
    );
  }
}

/// Payment status response
class PaymentStatusResponse {
  final String status;
  final dynamic order; // Can be ConfirmedOrder or just orderId string

  PaymentStatusResponse({
    required this.status,
    required this.order,
  });

  factory PaymentStatusResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusResponse(
      status: json['status'],
      order: json['order'],
    );
  }
}