import 'dart:convert';

class ShopInfo {
  final int? id;
  final String shopName;
  final String address;
  final String phone;
  final BankInfo? bankInfo;
  final String? logoUrl;
  final DateTime? updatedAt;
  final DateTime? createdAt;

  ShopInfo({
    this.id,
    required this.shopName,
    required this.address,
    required this.phone,
    this.bankInfo,
    this.logoUrl,
    this.updatedAt,
    this.createdAt,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      id: json['id'],
      shopName: json['shop_name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      bankInfo: _parseBankInfo(json['bank_info']),
      logoUrl: json['logo_url'],
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  static BankInfo? _parseBankInfo(dynamic bankInfoData) {
    if (bankInfoData == null) return null;

    try {
      // If it's already a Map, use it directly
      if (bankInfoData is Map<String, dynamic>) {
        return BankInfo.fromJson(bankInfoData);
      }

      // If it's a String, parse it as JSON first
      if (bankInfoData is String) {
        final Map<String, dynamic> bankInfoMap =
            jsonDecode(bankInfoData) as Map<String, dynamic>;
        return BankInfo.fromJson(bankInfoMap);
      }

      return null;
    } catch (e) {
      print('⚠️ Error parsing bank_info: $e');
      return null;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'shop_name': shopName,
      'address': address,
      'phone': phone,
      'bank_info': bankInfo?.toJson(),
      'logo_url': logoUrl,
      'updated_at': updatedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }
}

class BankInfo {
  final String bankName;
  final String accountNumber;
  final String accountName;

  BankInfo({
    required this.bankName,
    required this.accountNumber,
    required this.accountName,
  });

  factory BankInfo.fromJson(Map<String, dynamic> json) {
    return BankInfo(
      bankName: json['bank_name'] ?? '',
      accountNumber: json['account_number'] ?? '',
      accountName: json['account_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bank_name': bankName,
      'account_number': accountNumber,
      'account_name': accountName,
    };
  }
}

class ShopInfoResponse {
  final bool success;
  final String message;
  final ShopInfo data;

  ShopInfoResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ShopInfoResponse.fromJson(Map<String, dynamic> json) {
    return ShopInfoResponse(
      success: json['success'],
      message: json['message'],
      data: ShopInfo.fromJson(json['data']),
    );
  }
}

class CartItem {
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String? note;

  CartItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.note,
  });

  double get subtotal => price * quantity;

  CartItem copyWith({
    int? productId,
    String? productName,
    double? price,
    int? quantity,
    String? note,
  }) {
    return CartItem(
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'note': note,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'],
      productName: json['product_name'],
      price: json['price'].toDouble(),
      quantity: json['quantity'],
      note: json['note'],
    );
  }
}

// Models for registration
class RegisterResponse {
  final bool success;
  final String message;
  final RegisterData data;

  RegisterResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    return RegisterResponse(
      success: json['success'],
      message: json['message'],
      data: RegisterData.fromJson(json['data']),
    );
  }
}

class RegisterData {
  final RegisterUser user;
  final ShopInfo shopInfo;

  RegisterData({required this.user, required this.shopInfo});

  factory RegisterData.fromJson(Map<String, dynamic> json) {
    return RegisterData(
      user: RegisterUser.fromJson(json['user']),
      shopInfo: ShopInfo.fromJson(json['shop_info']),
    );
  }
}

class RegisterUser {
  final int id;
  final String username;
  final String fullName;
  final String role;
  final DateTime createdAt;

  RegisterUser({
    required this.id,
    required this.username,
    required this.fullName,
    required this.role,
    required this.createdAt,
  });

  factory RegisterUser.fromJson(Map<String, dynamic> json) {
    return RegisterUser(
      id: json['id'],
      username: json['username'],
      fullName: json['full_name'],
      role: json['role'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'full_name': fullName,
      'role': role,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
