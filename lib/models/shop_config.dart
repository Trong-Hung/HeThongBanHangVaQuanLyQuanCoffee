class ShopConfig {
  final int id;
  final int userId;
  final String shopName;
  final String shopAddress;
  final String shopPhone;
  final String? shopEmail;
  final String? shopLogo;
  final String defaultCurrency;
  final double taxRate;
  final String? receiptFooter;
  final Map<String, String> businessHours;
  final ShopFeatures features;
  final DateTime createdAt;
  final DateTime updatedAt;

  ShopConfig({
    required this.id,
    required this.userId,
    required this.shopName,
    required this.shopAddress,
    required this.shopPhone,
    this.shopEmail,
    this.shopLogo,
    required this.defaultCurrency,
    required this.taxRate,
    this.receiptFooter,
    required this.businessHours,
    required this.features,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ShopConfig.fromJson(Map<String, dynamic> json) {
    return ShopConfig(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      shopName: json['shop_name'] ?? '',
      shopAddress: json['shop_address'] ?? '',
      shopPhone: json['shop_phone'] ?? '',
      shopEmail: json['shop_email'],
      shopLogo: json['shop_logo'],
      defaultCurrency: json['default_currency'] ?? 'VND',
      taxRate: double.tryParse(json['tax_rate']?.toString() ?? '0') ?? 0.0,
      receiptFooter: json['receipt_footer'],
      businessHours: Map<String, String>.from(json['business_hours'] ?? {}),
      features: ShopFeatures.fromJson(json['features'] ?? {}),
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updated_at'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shop_name': shopName,
      'shop_address': shopAddress,
      'shop_phone': shopPhone,
      'shop_email': shopEmail,
      'default_currency': defaultCurrency,
      'tax_rate': taxRate,
      'receipt_footer': receiptFooter,
      'business_hours': businessHours,
      'features': features.toJson(),
    };
  }
}

class ShopFeatures {
  final bool autoPrintReceipt;
  final bool enableLoyaltyProgram;
  final bool requireCustomerInfo;
  final bool enableTableService;

  ShopFeatures({
    required this.autoPrintReceipt,
    required this.enableLoyaltyProgram,
    required this.requireCustomerInfo,
    required this.enableTableService,
  });

  factory ShopFeatures.fromJson(Map<String, dynamic> json) {
    return ShopFeatures(
      autoPrintReceipt: json['auto_print_receipt'] ?? false,
      enableLoyaltyProgram: json['enable_loyalty_program'] ?? false,
      requireCustomerInfo: json['require_customer_info'] ?? false,
      enableTableService: json['enable_table_service'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auto_print_receipt': autoPrintReceipt,
      'enable_loyalty_program': enableLoyaltyProgram,
      'require_customer_info': requireCustomerInfo,
      'enable_table_service': enableTableService,
    };
  }
}

class ShopConfigResponse {
  final bool success;
  final String message;
  final ShopConfig data;

  ShopConfigResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ShopConfigResponse.fromJson(Map<String, dynamic> json) {
    return ShopConfigResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ShopConfig.fromJson(json['data'] ?? {}),
    );
  }
}
