import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';

class CartWidget extends StatelessWidget {
  final CartProvider cartProvider;
  final VoidCallback onCheckout;

  const CartWidget({
    super.key,
    required this.cartProvider,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(left: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.shopping_cart, color: Colors.brown[600]),
                const SizedBox(width: 8),
                Text(
                  'Giỏ hàng',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[800],
                  ),
                ),
                const Spacer(),
                if (cartProvider.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.brown[600],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${cartProvider.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Cart items
          Expanded(
            child: cartProvider.isEmpty
                ? _buildEmptyCart(context)
                : _buildCartItems(context, formatter),
          ),

          // Total and checkout
          if (cartProvider.isNotEmpty)
            _buildCheckoutSection(context, formatter),
        ],
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Giỏ hàng trống',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm sản phẩm vào giỏ hàng',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems(BuildContext context, NumberFormat formatter) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cartProvider.items.length,
      itemBuilder: (context, index) {
        final item = cartProvider.items[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product name and remove button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => cartProvider.removeItem(item.productId),
                    icon: const Icon(Icons.close, size: 20),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Price and quantity controls
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    '${formatter.format(item.price.toInt())} VNĐ',
                    style: TextStyle(
                      color: Colors.brown[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // Quantity controls
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => cartProvider.updateItemQuantity(
                                item.productId,
                                item.quantity - 1,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.remove, size: 16),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                '${item.quantity}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () => cartProvider.updateItemQuantity(
                                item.productId,
                                item.quantity + 1,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                child: const Icon(Icons.add, size: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Subtotal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Thành tiền:'),
                  Text(
                    '${formatter.format(item.subtotal.toInt())} VNĐ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Note input
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Ghi chú',
                  hintText: 'Thêm ghi chú cho món này...',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
                onChanged: (value) => cartProvider.updateItemNote(
                  item.productId,
                  value.isEmpty ? null : value,
                ),
                controller: TextEditingController(text: item.note ?? ''),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCheckoutSection(BuildContext context, NumberFormat formatter) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Column(
        children: [
          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tổng cộng:',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${formatter.format(cartProvider.totalAmount.toInt())} VNĐ',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[600],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Checkout button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.brown[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Clear cart button
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => _showClearCartDialog(context),
              child: Text(
                'Xóa tất cả',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xóa giỏ hàng'),
          content: const Text(
            'Bạn có chắc chắn muốn xóa tất cả sản phẩm trong giỏ hàng?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                cartProvider.clearCart();
                Navigator.of(context).pop();
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red[600])),
            ),
          ],
        );
      },
    );
  }
}
