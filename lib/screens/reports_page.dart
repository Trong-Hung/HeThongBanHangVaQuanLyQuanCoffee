import 'package:flutter/material.dart';
import 'package:apppos_tronghung/services/reports_service.dart';
import 'package:apppos_tronghung/models/report_models.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({Key? key}) : super(key: key);

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final ReportsService _service = ReportsService();

  DailyReport? dailyReport;
  bool isLoading = false;
  bool needsPasswordAuth = true;
  DateTime selectedDate = DateTime.now();
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _checkReportTokenAndLoadData();
  }

  Future<void> _checkReportTokenAndLoadData() async {
    setState(() {
      isLoading = true;
    });

    // Kiểm tra xem đã có report token chưa
    final hasValidToken = await _service.hasValidReportToken();

    if (hasValidToken) {
      setState(() {
        needsPasswordAuth = false;
      });
      await _loadDailyReport();
    } else {
      setState(() {
        needsPasswordAuth = true;
        isLoading = false;
      });
    }
  }

  Future<void> _verifyPasswordAndLoadData(String password) async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await _service.verifyPassword(password);

      if (result['success'] == true) {
        setState(() {
          needsPasswordAuth = false;
        });
        await _loadDailyReport();
      } else {
        setState(() {
          errorMessage = result['message'] ?? 'Mật khẩu không chính xác';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _loadDailyReport() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      String dateStr = selectedDate.toIso8601String().split('T')[0];
      final response = await _service.getDailyReport(date: dateStr);

      if (response != null) {
        setState(() {
          dailyReport = DailyReport.fromJson(response);
        });
      } else {
        setState(() {
          errorMessage = 'Không thể tải báo cáo. Vui lòng kiểm tra kết nối.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Lỗi: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadDailyReport();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị form nhập mật khẩu nếu chưa xác thực
    if (needsPasswordAuth) {
      return _buildPasswordForm();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Báo cáo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _selectDate,
            tooltip: 'Chọn ngày',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDailyReport,
            tooltip: 'Tải lại',
          ),
          IconButton(
            icon: const Icon(Icons.lock_reset),
            onPressed: _clearAndRequirePassword,
            tooltip: 'Đổi mật khẩu',
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải báo cáo...'),
                ],
              ),
            )
          : errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    errorMessage!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadDailyReport,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            )
          : dailyReport == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Không có dữ liệu báo cáo'),
                ],
              ),
            )
          : _buildReportContent(),
    );
  }

  Widget _buildReportContent() {
    return RefreshIndicator(
      onRefresh: _loadDailyReport,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ngày được chọn
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.blue[700]),
                  const SizedBox(width: 8),
                  Text(
                    'Báo cáo ngày ${ReportsService.formatDate(selectedDate)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Thống kê tổng quan
            _buildStatisticsCard(),

            const SizedBox(height: 16),

            // Phân tích thanh toán
            if (dailyReport!.paymentBreakdown.isNotEmpty) ...[
              _buildPaymentBreakdownCard(),
              const SizedBox(height: 16),
            ],

            // Danh sách đơn hàng
            _buildOrdersCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    final stats = dailyReport!.statistics;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.analytics, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text(
                  'Thống kê tổng quan',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Hàng 1: Tổng đơn và Doanh thu
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Tổng đơn hàng',
                    '${stats.totalOrders}',
                    Colors.blue,
                    Icons.shopping_cart,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatItem(
                    'Doanh thu',
                    '${ReportsService.formatMoney(stats.totalRevenue)} VND',
                    Colors.green,
                    Icons.monetization_on,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.payment, color: Colors.purple[600]),
                const SizedBox(width: 8),
                const Text(
                  'Phương thức thanh toán',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...dailyReport!.paymentBreakdown.map(
              (payment) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ReportsService.getPaymentMethodName(payment.method),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            '${payment.orderCount} đơn hàng',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${ReportsService.formatMoney(payment.totalAmount)} VND',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${payment.percentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: Colors.blue[600],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildOrdersCard() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.orange[600]),
                const SizedBox(width: 8),
                Text(
                  'Đơn hàng (${dailyReport!.orders.length})',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (dailyReport!.orders.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: const Column(
                  children: [
                    Icon(
                      Icons.shopping_cart_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text('Không có đơn hàng nào trong ngày này'),
                  ],
                ),
              )
            else
              ...dailyReport!.orders.map(
                (order) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Đơn #${order.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              order.itemsSummary,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${ReportsService.getPaymentMethodName(order.paymentMethod)} • ${ReportsService.formatDate(order.createdAt)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${ReportsService.formatMoney(order.totalAmount)} VND',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordForm() {
    final TextEditingController passwordController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('🔐 Xác thực báo cáo'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Nhập mật khẩu để xem báo cáo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.password),
                errorText: errorMessage,
              ),
              onSubmitted: (value) {
                if (value.isNotEmpty) {
                  _verifyPasswordAndLoadData(value);
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (passwordController.text.isNotEmpty) {
                          _verifyPasswordAndLoadData(passwordController.text);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Xác thực', style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _clearAndRequirePassword() async {
    await _service.clearReportToken();
    setState(() {
      needsPasswordAuth = true;
      dailyReport = null;
      errorMessage = null;
    });
  }
}
