import 'package:flutter/material.dart';
import '../models/product.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAddToCart;

  const ProductCard({
    Key? key,
    required this.product,
    required this.onAddToCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80, // Giảm height để tránh overflow
      margin: const EdgeInsets.all(4),
      child: Card(
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              // Hình ảnh sản phẩm
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: Colors.grey[200],
                ),
                child: const Icon(Icons.coffee, size: 30, color: Colors.brown),
              ),
              const SizedBox(width: 12),

              // Thông tin sản phẩm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Tên sản phẩm
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Giá sản phẩm
                    Text(
                      '${product.price.toInt()}đ',
                      style: const TextStyle(
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Nút thêm vào giỏ hàng
              Container(
                width: 50,
                height: 30,
                child: ElevatedButton(
                  onPressed: onAddToCart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.brown[600],
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    textStyle: const TextStyle(fontSize: 10),
                  ),
                  child: const Text('Thêm'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
