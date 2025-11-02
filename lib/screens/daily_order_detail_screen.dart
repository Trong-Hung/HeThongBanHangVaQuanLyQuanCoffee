import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_order.dart';
import '../services/daily_orders_service.dart';

class DailyOrderDetailScreen extends StatefulWidget {
  final int orderId;

  const DailyOrderDetailScreen({super.key, required this.orderId});

  @override
  State<DailyOrderDetailScreen> createState() => _DailyOrderDetailScreenState();
}

class _DailyOrderDetailScreenState extends State<DailyOrderDetailScreen> {
  DailyOrderDetail? _orderDetail;
  bool _isLoading = true;
  String? _error;
  bool _isUpdating = false;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '',
    decimalDigits: 0,
  );

  final DateFormat _timeFormat = DateFormat('HH:mm dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _loadOrderDetail();
  }

  Future<void> _loadOrderDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final detail = await DailyOrdersService.getOrderDetail(widget.orderId);

      if (mounted) {
        setState(() {
          _orderDetail = detail;
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

  Future<void> _completeOrder() async {
    if (_isUpdating || _orderDetail == null) return;

    try {
      setState(() => _isUpdating = true);

      await DailyOrdersService.completeOrder(widget.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đánh dấu hoàn thành thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Trả về true để refresh danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _restartOrder() async {
    if (_isUpdating || _orderDetail == null) return;

    try {
      setState(() => _isUpdating = true);

      await DailyOrdersService.restartOrder(widget.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Chuyển về đang làm thành công'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.of(context).pop(true); // Trả về true để refresh danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Future<void> _deleteOrder() async {
    if (_isUpdating || _orderDetail == null) return;

    // Xác nhận xóa
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text(
          'Bạn có chắc muốn xóa đơn hàng này khỏi danh sách hôm nay?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      setState(() => _isUpdating = true);

      await DailyOrdersService.deleteFromToday(widget.orderId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Xóa đơn hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true); // Trả về true để refresh danh sách
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chi tiết đơn hàng #${widget.orderId}'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
        actions: [
          if (_orderDetail != null)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'delete':
                    _deleteOrder();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Xóa khỏi danh sách'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomBar(),
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
              onPressed: _loadOrderDetail,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_orderDetail == null) {
      return const Center(child: Text('Không có dữ liệu'));
    }

    return RefreshIndicator(
      onRefresh: _loadOrderDetail,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOrderInfo(),
            const SizedBox(height: 20),
            _buildOrderItems(),
            const SizedBox(height: 20),
            _buildUserInfo(),
            const SizedBox(height: 100), // Space for bottom bar
          ],
        ),
      ),
    );
  }

  Widget _buildOrderInfo() {
    final order = _orderDetail!.order;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thông tin đơn hàng',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Mã đơn hàng:', '#${order.orderId}'),
            _buildInfoRow(
              'Tổng tiền:',
              '${_currencyFormat.format(order.totalAmount)} đ',
            ),
            _buildInfoRow('Phương thức:', order.paymentMethodText),
            _buildInfoRow(
              'Thời gian tạo:',
              _timeFormat.format(order.createdAt),
            ),
            if (order.completedAt != null)
              _buildInfoRow(
                'Hoàn thành lúc:',
                _timeFormat.format(order.completedAt!),
              ),
            if (order.note != null && order.note!.isNotEmpty)
              _buildInfoRow('Ghi chú:', order.note!),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItems() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chi tiết sản phẩm (${_orderDetail!.items.length} món)',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ..._orderDetail!.items.map((item) => _buildItemRow(item)),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(OrderItem item) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                if (item.itemNote != null && item.itemNote!.isNotEmpty)
                  Text(
                    'Ghi chú: ${item.itemNote}',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'x${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_currencyFormat.format(item.unitPrice)} đ',
              textAlign: TextAlign.right,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '${_currencyFormat.format(item.itemTotal)} đ',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.brown,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Thông tin khách hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Tên khách hàng:', _orderDetail!.userInfo.name),
            _buildInfoRow('Tài khoản:', _orderDetail!.userInfo.username),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomBar() {
    if (_orderDetail == null) return null;

    final order = _orderDetail!.order;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          if (order.isInProgress) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _completeOrder,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check_circle),
                label: const Text('Hoàn thành'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUpdating ? null : _restartOrder,
                icon: _isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: const Text('Làm lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
