import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/momo_models.dart';
import '../services/momo_api_service.dart';
import '../providers/cart_provider.dart';

/// Screen for displaying MoMo QR code and handling payment confirmation
class MomoPaymentScreen extends StatefulWidget {
  final QRInfo qrInfo;
  final OrderPreview orderPreview;
  final TempOrderData tempOrderData;

  const MomoPaymentScreen({
    Key? key,
    required this.qrInfo,
    required this.orderPreview,
    required this.tempOrderData,
  }) : super(key: key);

  @override
  State<MomoPaymentScreen> createState() => _MomoPaymentScreenState();
}

class _MomoPaymentScreenState extends State<MomoPaymentScreen> {
  final MomoApiService _momoService = MomoApiService();
  bool _isConfirming = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Thanh toán MoMo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple[700],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _showCancelDialog(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // QR Code Section
            _buildQRSection(),

            const SizedBox(height: 24),

            // Order Details Section
            _buildOrderDetailsSection(),

            const SizedBox(height: 24),

            // Instructions Section
            _buildInstructionsSection(),

            const SizedBox(height: 32),

            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  /// Build QR code display section
  Widget _buildQRSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        children: [
          const Text(
            '📱 Quét mã QR để thanh toán',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple,
            ),
          ),
          const SizedBox(height: 8),

          // Debug info - show QR data
          if (widget.qrInfo.payUrl.isNotEmpty)
            Text(
              'QR Data: ${widget.qrInfo.payUrl.length} characters',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),

          const SizedBox(height: 16),

          // QR Code - Display actual QR code from API
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: widget.qrInfo.payUrl.isNotEmpty
                  ? QrImageView(
                      data: widget.qrInfo.payUrl, // Use pay URL for QR code
                      version: QrVersions.auto,
                      size: 200.0,
                      backgroundColor: Colors.white,
                      errorCorrectionLevel: QrErrorCorrectLevel.M,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: Colors.black,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: Colors.black,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 60,
                          color: Colors.orange[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tạo QR',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Amount display
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.purple[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              MomoApiService.formatAmount(widget.qrInfo.amount),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Order ID
          Text(
            'Mã đơn hàng: ${widget.qrInfo.orderId}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  /// Build order details section
  Widget _buildOrderDetailsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📋 Chi tiết đơn hàng',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Order items
          ...widget.orderPreview.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (item.note != null && item.note!.isNotEmpty)
                              Text(
                                '• ${item.note}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text('x${item.quantity}'),
                      const SizedBox(width: 16),
                      Text(
                        MomoApiService.formatAmount(item.subtotal),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const Divider(),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Text(
                MomoApiService.formatAmount(widget.orderPreview.totalAmount),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),

          // Order note
          if (widget.orderPreview.note != null &&
              widget.orderPreview.note!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                'Ghi chú: ${widget.orderPreview.note}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Build instructions section
  Widget _buildInstructionsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
              const SizedBox(width: 8),
              Text(
                'Hướng dẫn thanh toán',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          const Text(
            '1. Mở ứng dụng MoMo trên điện thoại\n'
            '2. Chọn "Quét mã QR" hoặc "Chuyển tiền"\n'
            '3. Quét mã QR hiển thị trên màn hình\n'
            '4. Xác nhận thanh toán trên MoMo\n'
            '5. Sau khi thanh toán thành công, nhấn "Xác nhận" bên dưới',
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
        ],
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Column(
      children: [
        // Confirm payment button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isConfirming ? null : _confirmPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: _isConfirming
                ? const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Đang xác nhận...'),
                    ],
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle),
                      SizedBox(width: 8),
                      Text(
                        'Xác nhận đã nhận tiền',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Cancel button
        SizedBox(
          width: double.infinity,
          height: 50,
          child: OutlinedButton(
            onPressed: _isConfirming ? null : _showCancelDialog,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red[600],
              side: BorderSide(color: Colors.red[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.cancel),
                SizedBox(width: 8),
                Text(
                  'Hủy thanh toán',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Confirm payment and create order
  Future<void> _confirmPayment() async {
    setState(() {
      _isConfirming = true;
    });

    try {
      // Call API to confirm payment
      final response = await _momoService.confirmPayment(
        tempOrderData: widget.tempOrderData,
      );

      // Clear cart
      if (mounted) {
        Provider.of<CartProvider>(context, listen: false).clearCart();
      }

      // Show success and navigate
      if (mounted) {
        // Show success dialog
        _showSuccessDialog(response);
      }
    } catch (e) {
      print('Error confirming payment: $e');

      if (mounted) {
        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi xác nhận'),
            content: Text('Không thể xác nhận thanh toán:\n${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  /// Show cancel confirmation dialog
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy thanh toán?'),
        content: const Text(
          'Bạn có chắc chắn muốn hủy thanh toán MoMo? '
          'Đơn hàng sẽ không được lưu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tiếp tục thanh toán'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to checkout
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy'),
          ),
        ],
      ),
    );
  }

  /// Show success dialog after payment confirmation
  void _showSuccessDialog(PaymentConfirmResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green[600], size: 28),
            const SizedBox(width: 8),
            const Text('Thành công!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Đơn hàng #${response.order.id} đã được tạo thành công!'),
            const SizedBox(height: 8),
            Text(
              'Tổng tiền: ${MomoApiService.formatAmount(double.parse(response.order.totalAmount))}',
            ),
            Text('Phương thức: ${response.order.paymentMethodDisplay}'),
            Text('Số sản phẩm: ${response.items.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to checkout
              Navigator.of(context).pop(); // Go back to order screen
            },
            child: const Text('Hoàn tất'),
          ),
        ],
      ),
    );
  }
}
