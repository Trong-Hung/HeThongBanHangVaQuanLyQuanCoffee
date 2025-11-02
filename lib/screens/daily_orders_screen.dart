import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_order.dart';
import '../services/daily_orders_service.dart';
import 'daily_order_detail_screen.dart';

class DailyOrdersScreen extends StatefulWidget {
  const DailyOrdersScreen({super.key});

  @override
  State<DailyOrdersScreen> createState() => _DailyOrdersScreenState();
}

class _DailyOrdersScreenState extends State<DailyOrdersScreen> {
  DailyOrdersResponse? _dailyOrders;
  bool _isLoading = true;
  String? _error;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  final DateFormat _timeFormat = DateFormat('HH:mm');

  @override
  void initState() {
    super.initState();
    _loadDailyOrders();
  }

  Future<void> _loadDailyOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final orders = await DailyOrdersService.getDailyOrders();

      if (mounted) {
        setState(() {
          _dailyOrders = orders;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _navigateToDetail(int orderId) async {
    final result = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (context) => DailyOrderDetailScreen(orderId: orderId),
      ),
    );

    // Nếu có thay đổi, reload danh sách
    if (result == true) {
      _loadDailyOrders();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đơn hàng hôm nay'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadDailyOrders,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_error',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyOrders,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_dailyOrders == null || _dailyOrders!.orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Chưa có đơn hàng nào hôm nay',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDailyOrders,
              child: const Text('Làm mới'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDailyOrders,
      child: Column(
        children: [
          _buildStatsCard(),
          Expanded(child: _buildOrdersList()),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    if (_dailyOrders == null) return const SizedBox.shrink();

    final stats = _dailyOrders!.stats;

    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                'Thống kê hôm nay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown[600],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Tổng đơn',
                      stats.totalOrders.toString(),
                      Icons.receipt_long,
                      Colors.blue,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Đang làm',
                      stats.inProgressCount.toString(),
                      Icons.hourglass_top,
                      Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Làm xong',
                      stats.completedCount.toString(),
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.brown[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.attach_money, color: Colors.brown[600]),
                    const SizedBox(width: 8),
                    Text(
                      'Doanh thu: ${_currencyFormat.format(stats.totalRevenue)} đ',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.brown[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildOrdersList() {
    final orders = _dailyOrders!.orders;

    // Sắp xếp: Đang làm lên trên, Làm xong xuống dưới
    final sortedOrders = List<DailyOrder>.from(orders)
      ..sort((a, b) {
        if (a.workStatus != b.workStatus) {
          // IN_PROGRESS lên trước COMPLETED
          if (a.workStatus == 'IN_PROGRESS') return -1;
          if (b.workStatus == 'IN_PROGRESS') return 1;
        }
        // Cùng trạng thái thì sắp xếp theo thời gian tạo (mới nhất lên trước)
        return b.createdAt.compareTo(a.createdAt);
      });

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      itemCount: sortedOrders.length,
      itemBuilder: (context, index) {
        return _buildOrderCard(sortedOrders[index]);
      },
    );
  }

  Widget _buildOrderCard(DailyOrder order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        onTap: () => _navigateToDetail(order.orderId),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Đơn hàng #${order.orderId}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: order.isCompleted ? Colors.green : Colors.orange,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      order.statusText,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    _timeFormat.format(order.createdAt),
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.payment, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    order.paymentMethodText,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                order.itemsSummary,
                style: const TextStyle(fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.itemCount} món',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${_currencyFormat.format(order.totalAmount)} đ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown[600],
                    ),
                  ),
                ],
              ),
              if (order.note != null && order.note!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  width: double.infinity,
                  child: Text(
                    'Ghi chú: ${order.note}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
