import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../providers/cart_provider.dart';
import '../services/order_service.dart';
import '../services/momo_api_service.dart';
import '../models/order.dart';
import '../models/momo_models.dart';
import 'momo_payment_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final CartProvider cartProvider;

  const CheckoutScreen({super.key, required this.cartProvider});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isLoading = false;
  String _selectedPaymentMethod = 'CASH'; // Suggestion: Use an enum here
  final TextEditingController _customerCashController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final NumberFormat formatter = NumberFormat('#,##0', 'en_US');
  final MomoApiService _momoService = MomoApiService();

  double get _changeAmount {
    if (_customerCashController.text.isEmpty) return 0;
    final customerCash = double.tryParse(_customerCashController.text.replaceAll(',', '')) ?? 0;
    return customerCash - widget.cartProvider.totalAmount;
  }

  @override
  void dispose() {
    _customerCashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 20),
              _buildPaymentMethodSelection(),
              const SizedBox(height: 20),
              if (_selectedPaymentMethod == 'CASH') ...[
                _buildCashPaymentForm(),
                const SizedBox(height: 20),
              ],
              // Use SizedBox instead of Spacer in a SingleChildScrollView
              const SizedBox(height: 40), 
              _buildPaymentButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- BUILDER WIDGETS ---

  Widget _buildOrderSummary() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tóm tắt đơn hàng',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...widget.cartProvider.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.quantity}x ${item.productName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${formatter.format(item.subtotal.toInt())} VNĐ',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                )),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  '${formatter.format(widget.cartProvider.totalAmount.toInt())} VNĐ',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodSelection() {
     return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hình thức thanh toán',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: 'CASH',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              title: const Text('Tiền mặt'),
              subtitle: const Text('Thanh toán bằng tiền mặt'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Radio<String>(
                value: 'MOMO',
                groupValue: _selectedPaymentMethod,
                onChanged: (value) {
                  setState(() {
                    _selectedPaymentMethod = value!;
                  });
                },
              ),
              title: const Text('MoMo'),
              subtitle: const Text('Thanh toán qua ví MoMo'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCashPaymentForm() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thông tin thanh toán tiền mặt',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _customerCashController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Tiền khách đưa (VNĐ)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.money),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số tiền khách đưa';
                  }
                  final amount = double.tryParse(value.replaceAll(',', ''));
                  if (amount == null || amount < widget.cartProvider.totalAmount) {
                    return 'Số tiền phải lớn hơn hoặc bằng tổng tiền hàng';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                },
              ),
              if (_customerCashController.text.isNotEmpty && _changeAmount >= 0) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tiền thừa:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${formatter.format(_changeAmount.toInt())} VNĐ',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentButton() {
     return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _processPayment,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(
                _selectedPaymentMethod == 'CASH' 
                    ? 'Hoàn thành thanh toán' 
                    : 'Tạo mã QR MoMo',
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  // --- LOGIC METHODS ---

  Future<void> _processPayment() async {
    if (_selectedPaymentMethod == 'CASH') {
      await _processCashPayment();
    } else if (_selectedPaymentMethod == 'MOMO') {
      await _processMoMoPayment();
    }
  }

  Future<void> _processCashPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final note = 'Tiền khách đưa: ${_customerCashController.text} VNĐ, Tiền thừa: ${formatter.format(_changeAmount.toInt())} VNĐ';
      await _createOrder('CASH', note);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Lỗi thanh toán tiền mặt: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _processMoMoPayment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final qrResponse = await _momoService.createQR(
        items: widget.cartProvider.items
            .map((item) => MomoOrderItem(
                  productId: item.productId,
                  quantity: item.quantity,
                  note: item.note,
                ))
            .toList(),
        note: 'Đơn hàng POS - ${DateTime.now().millisecondsSinceEpoch}',
      );

      if (mounted) {
        final paymentResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MomoPaymentScreen(
              qrInfo: qrResponse.qrInfo,
              tempOrderData: qrResponse.tempOrderData,
              orderPreview: qrResponse.orderPreview,
            ),
          ),
        );

        if (paymentResult == true && mounted) {
          // Payment was successful, the MomoPaymentScreen already created the order.
          // We just need to clear the cart and pop this screen.
          widget.cartProvider.clearCart();
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Thanh toán MoMo thành công!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tạo mã QR MoMo: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _createOrder(String paymentMethod, String note) async {
    try {
      final orderRequest = CreateOrderRequest(
        items: widget.cartProvider.items
            .map((item) => CreateOrderItem(
                  productId: item.productId,
                  quantity: item.quantity,
                  note: item.note,
                ))
            .toList(),
        paymentMethod: paymentMethod,
        note: note,
      );

      final response = await OrderService.createOrder(orderRequest);

      if (mounted) {
        widget.cartProvider.clearCart();
        Navigator.of(context).pop(true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đặt hàng thành công! ID: ${response.id}'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Rethrow the exception to be caught by the calling function's catch block
      throw Exception('Lỗi tạo đơn hàng: $e');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }
}