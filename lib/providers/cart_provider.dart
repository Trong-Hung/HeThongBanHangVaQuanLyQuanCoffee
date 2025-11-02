import 'package:flutter/foundation.dart';
import '../models/shop_info.dart';

class CartProvider extends ChangeNotifier {
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get itemCount {
    return _items.fold(0, (total, item) => total + item.quantity);
  }

  double get totalAmount {
    return _items.fold(0.0, (total, item) => total + item.subtotal);
  }

  bool get isEmpty => _items.isEmpty;

  bool get isNotEmpty => _items.isNotEmpty;

  void addItem(CartItem item) {
    // Check if item already exists
    final existingIndex = _items.indexWhere(
      (existingItem) => existingItem.productId == item.productId,
    );

    if (existingIndex >= 0) {
      // Update existing item quantity
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: _items[existingIndex].quantity + item.quantity,
      );
    } else {
      // Add new item
      _items.add(item);
    }

    notifyListeners();
  }

  void removeItem(int productId) {
    _items.removeWhere((item) => item.productId == productId);
    notifyListeners();
  }

  void updateItemQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }

    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        quantity: quantity,
      );
      notifyListeners();
    }
  }

  void updateItemNote(int productId, String? note) {
    final existingIndex = _items.indexWhere(
      (item) => item.productId == productId,
    );

    if (existingIndex >= 0) {
      _items[existingIndex] = _items[existingIndex].copyWith(
        note: note,
      );
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  CartItem? getItem(int productId) {
    try {
      return _items.firstWhere((item) => item.productId == productId);
    } catch (e) {
      return null;
    }
  }

  // Get formatted total amount
  String get formattedTotal {
    return '${totalAmount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )} VNĐ';
  }

  // Generate order items for API
  List<Map<String, dynamic>> toOrderItems() {
    return _items.map((item) => {
      'product_id': item.productId,
      'quantity': item.quantity,
      'note': item.note,
    }).toList();
  }
}