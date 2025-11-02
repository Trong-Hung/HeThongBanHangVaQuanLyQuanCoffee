import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderManagementScreen extends StatefulWidget {
  const OrderManagementScreen({super.key});

  @override
  State<OrderManagementScreen> createState() => _OrderManagementScreenState();
}

class _OrderManagementScreenState extends State<OrderManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Order> _orders = [];
  OrderStats? _orderStats;
  bool _isLoading = true;
  String? _errorMessage;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print('📋 Loading orders and stats...');
      
      // Load orders
      final ordersResponse = await OrderService.getOrders(limit: 50);
      print('📋 Orders loaded: ${ordersResponse.data.length}');

      // Load order statistics with better error handling  
      OrderStats? orderStats;
      try {
        final statsResponse = await OrderService.getOrderStats();
        orderStats = statsResponse.data;
        print('📋 Order stats loaded successfully');
      } catch (statsError) {
        print('📋 Failed to load order stats: $statsError');
        // Continue without stats - don't fail the whole screen
      }

      if (mounted) {
        setState(() {
          _orders = ordersResponse.data;
          _orderStats = orderStats;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('📋 Load data error: $e');
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _showOrderDetails(Order order) async {
    try {
      // Get detailed order with items
      final detailedOrder = await OrderService.getOrder(order.id);

      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => _OrderDetailsDialog(order: detailedOrder),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải chi tiết đơn hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Đơn hàng'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Đơn hàng', icon: Icon(Icons.receipt_long)),
            Tab(text: 'Thống kê', icon: Icon(Icons.analytics)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildOrdersList(), _buildStatistics()],
      ),
    );
  }

  Widget _buildOrdersList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi: $_errorMessage'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Chưa có đơn hàng nào'),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm đơn hàng...',
              prefixIcon: Icon(Icons.search),
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              // TODO: Implement search
            },
          ),
        ),

        // Orders list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _orders.length,
            itemBuilder: (context, index) {
              final order = _orders[index];
              return _buildOrderCard(order);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.brown[100],
          child: Text(
            '#${order.id}',
            style: TextStyle(
              color: Colors.brown[600],
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          '${formatter.format(order.totalAmount.toInt())} VNĐ',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Thanh toán: ${_getPaymentMethodText(order.paymentMethod)}'),
            Text('Ngày: ${dateFormat.format(order.orderDate)}'),
            Text('NV: ${order.username}'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: _getStatusColor(order.status),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _getStatusText(order.status),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        onTap: () => _showOrderDetails(order),
      ),
    );
  }

  Widget _buildStatistics() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null || _orderStats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Lỗi tải thống kê: ${_errorMessage ?? 'Không có dữ liệu'}'),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _loadData, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    final formatter = NumberFormat('#,###', 'vi_VN');
    final stats = _orderStats!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tổng quan',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Tổng đơn hàng',
                          stats.overview.totalOrders.toString(),
                          Icons.receipt_long,
                          Colors.blue,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Tổng doanh thu',
                          '${formatter.format(stats.overview.totalRevenue.toInt())} VNĐ',
                          Icons.attach_money,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem(
                          'Đơn hàng TB',
                          '${formatter.format(stats.overview.averageOrderValue.toInt())} VNĐ',
                          Icons.trending_up,
                          Colors.orange,
                        ),
                      ),
                      Expanded(
                        child: _buildStatItem(
                          'Đơn hàng cao nhất',
                          '${formatter.format(stats.overview.maxOrderValue.toInt())} VNĐ',
                          Icons.star,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Payment Methods
          if (stats.paymentMethods.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Phương thức thanh toán',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...stats.paymentMethods.map(
                      (method) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(_getPaymentMethodText(method.paymentMethod)),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${method.orderCount} đơn',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${formatter.format(method.revenue.toInt())} VNĐ',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Daily Stats
          if (stats.dailyStats.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thống kê theo ngày',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...stats.dailyStats.map(
                      (daily) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat(
                                'dd/MM/yyyy',
                              ).format(DateTime.parse(daily.date)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${daily.orders} đơn',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  '${formatter.format(daily.revenue.toInt())} VNĐ',
                                  style: TextStyle(
                                    color: Colors.green[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tiền mặt';
      case 'card':
        return 'Thẻ';
      case 'bank_transfer':
        return 'Chuyển khoản';
      default:
        return paymentMethod;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'preparing':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

class _OrderDetailsDialog extends StatelessWidget {
  final Order order;

  const _OrderDetailsDialog({required this.order});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###', 'vi_VN');
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');

    return AlertDialog(
      title: Text('Đơn hàng #${order.id}'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Order info
            Text('Ngày: ${dateFormat.format(order.orderDate)}'),
            Text('Nhân viên: ${order.username}'),
            Text('Thanh toán: ${_getPaymentMethodText(order.paymentMethod)}'),
            Text('Trạng thái: ${_getStatusText(order.status)}'),
            if (order.note != null && order.note!.isNotEmpty)
              Text('Ghi chú: ${order.note}'),
            const SizedBox(height: 16),

            // Order items
            if (order.items != null && order.items!.isNotEmpty) ...[
              const Text(
                'Chi tiết đơn hàng:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...order.items!.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName ?? 'Sản phẩm #${item.productId}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (item.note != null && item.note!.isNotEmpty)
                              Text(
                                'Ghi chú: ${item.note}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('x${item.quantity}'),
                      const SizedBox(width: 8),
                      Text(
                        '${formatter.format((item.totalPrice ?? (item.unitPrice * item.quantity)).toInt())} VNĐ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(),
            ],

            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${formatter.format(order.totalAmount.toInt())} VNĐ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.brown[600],
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Đóng'),
        ),
      ],
    );
  }

  String _getPaymentMethodText(String paymentMethod) {
    switch (paymentMethod.toLowerCase()) {
      case 'cash':
        return 'Tiền mặt';
      case 'card':
        return 'Thẻ';
      case 'bank_transfer':
        return 'Chuyển khoản';
      default:
        return paymentMethod;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ xử lý';
      case 'preparing':
        return 'Đang chuẩn bị';
      case 'completed':
        return 'Hoàn thành';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return status;
    }
  }
}
