import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/product.dart';
import '../models/category.dart';
import '../models/shop_info.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';
import '../services/auth_service.dart';
import '../providers/cart_provider.dart';
import '../widgets/product_card.dart';
import 'cart_screen.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  List<Product> _products = [];
  List<Category> _categories = [];
  bool _isLoading = true;
  String? _errorMessage;
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Check if user is authenticated before making API calls
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('⚠️ User not authenticated, skipping API calls');
        setState(() {
          _isLoading = false;
          _errorMessage = 'Vui lòng đăng nhập để tiếp tục';
        });
        return;
      }

      print('Loading categories...');
      final categoriesResponse = await CategoryService.getCategories();
      print('Categories loaded: ${categoriesResponse.data.length}');

      print('Loading products...');
      final productsResponse = await ProductService.getProducts(
        limit: 50,
        categoryId: null,
        isActive: true,
      );
      print('Products loaded: ${productsResponse.data.length}');

      setState(() {
        _categories = categoriesResponse.data;
        _products = productsResponse.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        _errorMessage = 'Lỗi kết nối API: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _filterByCategory(int? categoryId) async {
    setState(() {
      _selectedCategoryId = categoryId;
      _isLoading = true;
    });

    try {
      print('Filtering by category: $categoryId');
      final productsResponse = await ProductService.getProducts(
        limit: 50,
        categoryId: categoryId,
        isActive: true,
      );
      print('Filtered products count: ${productsResponse.data.length}');

      setState(() {
        _products = productsResponse.data;
        _isLoading = false;
      });
    } catch (e) {
      print('Filter error: $e');
      // If filter fails, show message but keep current products
      setState(() {
        _isLoading = false;
        _selectedCategoryId = null; // Reset category filter
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              categoryId != null
                  ? 'Lỗi lọc danh mục - Hiển thị tất cả sản phẩm'
                  : 'Lỗi tải sản phẩm: ${e.toString()}',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  void _addToCart(CartProvider cartProvider, Product product) {
    final cartItem = CartItem(
      productId: product.id,
      productName: product.name,
      price: product.price,
      quantity: 1,
    );

    cartProvider.addItem(cartItem);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm ${product.name} vào giỏ hàng'),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt hàng'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CartScreen(),
                        ),
                      );
                    },
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          return Column(
            children: [
              // Category filter
              Container(
                height: 60,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    // All categories
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: const Text('Tất cả'),
                        selected: _selectedCategoryId == null,
                        onSelected: (_) => _filterByCategory(null),
                        backgroundColor: Colors.grey[200],
                        selectedColor: Colors.brown[100],
                      ),
                    ),
                    // Category chips
                    ..._categories.map(
                      (category) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(category.name),
                          selected: _selectedCategoryId == category.id,
                          onSelected: (_) => _filterByCategory(category.id),
                          backgroundColor: Colors.grey[200],
                          selectedColor: Colors.brown[100],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Products grid
              Expanded(child: _buildProductsGrid(cartProvider)),
            ],
          );
        },
      ),
      floatingActionButton: Consumer<CartProvider>(
        builder: (context, cart, child) {
          if (cart.itemCount == 0) return const SizedBox();

          return FloatingActionButton.extended(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CartScreen()),
              );
            },
            backgroundColor: Colors.brown[600],
            foregroundColor: Colors.white,
            icon: const Icon(Icons.shopping_cart),
            label: Text('Giỏ hàng (${cart.itemCount})'),
          );
        },
      ),
    );
  }

  Widget _buildProductsGrid(CartProvider cartProvider) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Lỗi tải dữ liệu',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_basket_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Không tìm thấy sản phẩm nào trong danh mục này',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    // Filter only available and active products for display
    final availableProducts = _products
        .where((product) => product.isActive && product.isAvailable)
        .toList();

    if (availableProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline, size: 64, color: Colors.orange[400]),
            const SizedBox(height: 16),
            Text(
              'Không có sản phẩm khả dụng',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(color: Colors.orange[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tất cả sản phẩm hiện đang hết hàng hoặc tạm ngừng bán',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 4.5,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: availableProducts.length,
      itemBuilder: (context, index) {
        final product = availableProducts[index];
        return ProductCard(
          product: product,
          onAddToCart: () => _addToCart(cartProvider, product),
        );
      },
    );
  }
}
