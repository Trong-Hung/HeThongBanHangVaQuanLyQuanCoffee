import 'package:flutter/material.dart';
import '../models/shop_info.dart';
import '../models/shop_config.dart';
import '../models/user.dart';
import '../services/shop_info_service.dart';
import '../services/shop_config_service.dart';
import '../services/auth_service.dart';
import '../screens/main_screen.dart';
import 'reports_page.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ShopInfo? _shopInfo;
  ShopConfig? _shopConfig;
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if user is authenticated before making API calls
      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('⚠️ User not authenticated, skipping API calls');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Load shop info first (required)
      final shopInfo = await ShopInfoService.getShopInfo();
      final user = await AuthService.getStoredUser();

      // Try to load shop config (optional)
      ShopConfig? shopConfig;
      try {
        shopConfig = await ShopConfigService.getShopConfig();
      } catch (e) {
        print('⚠️ Could not load shop config: $e');
        // Shop config is optional, continue without it
      }

      setState(() {
        _shopInfo = shopInfo;
        _shopConfig = shopConfig;
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        backgroundColor: Colors.brown[600],
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop info section
                  _buildShopInfoSection(),

                  const SizedBox(height: 24),

                  // User info section
                  _buildUserInfoSection(),

                  const SizedBox(height: 24),

                  // Settings section
                  _buildSettingsSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildShopInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.store, color: Colors.brown[600]),
                const SizedBox(width: 8),
                Text(
                  'Thông tin cửa hàng',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_shopInfo != null) ...[
              _buildInfoRow(
                icon: Icons.business,
                label: 'Tên cửa hàng',
                value: _shopInfo!.shopName,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Địa chỉ',
                value: _shopInfo!.address,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.phone,
                label: 'Số điện thoại',
                value: _shopInfo!.phone,
              ),

              // Show additional config info if available
              if (_shopConfig != null) ...[
                if (_shopConfig!.shopEmail?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.email,
                    label: 'Email',
                    value: _shopConfig!.shopEmail!,
                  ),
                ],
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.attach_money,
                  label: 'Đơn vị tiền tệ',
                  value: _shopConfig!.defaultCurrency,
                ),
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.receipt,
                  label: 'Thuế suất',
                  value: '${_shopConfig!.taxRate}%',
                ),
                if (_shopConfig!.receiptFooter?.isNotEmpty == true) ...[
                  const SizedBox(height: 12),
                  _buildInfoRow(
                    icon: Icons.note,
                    label: 'Ghi chú hóa đơn',
                    value: _shopConfig!.receiptFooter!,
                  ),
                ],
              ],

              if (_shopInfo!.bankInfo != null) ...[
                const SizedBox(height: 12),
                _buildInfoRow(
                  icon: Icons.account_balance,
                  label: 'Ngân hàng',
                  value:
                      '${_shopInfo!.bankInfo!.bankName}\n${_shopInfo!.bankInfo!.accountNumber}\n${_shopInfo!.bankInfo!.accountName}',
                ),
              ],
            ] else ...[
              const Text('Không thể tải thông tin cửa hàng'),
            ],

            const SizedBox(height: 16),

            // Business Hours Section (if available)
            if (_shopConfig != null &&
                _shopConfig!.businessHours.isNotEmpty) ...[
              Row(
                children: [
                  Icon(Icons.access_time, color: Colors.brown[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Giờ mở cửa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildBusinessHoursDisplay(_shopConfig!.businessHours),
              const SizedBox(height: 16),
            ],

            // Features Section (if available)
            if (_shopConfig != null) ...[
              Row(
                children: [
                  Icon(Icons.featured_play_list, color: Colors.brown[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Tính năng',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildFeaturesDisplay(_shopConfig!.features),
              const SizedBox(height: 16),
            ],

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _editShopInfo,
                icon: const Icon(Icons.edit),
                label: const Text('Chỉnh sửa thông tin'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.brown[600]),
                const SizedBox(width: 8),
                Text(
                  'Thông tin tài khoản',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (_currentUser != null) ...[
              _buildInfoRow(
                icon: Icons.account_circle,
                label: 'Tên đăng nhập',
                value: _currentUser!.username,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.admin_panel_settings,
                label: 'Vai trò',
                value: _currentUser!.role,
              ),
              const SizedBox(height: 12),
              _buildInfoRow(
                icon: Icons.calendar_today,
                label: 'Ngày tạo',
                value: _currentUser!.createdAt.toString().split(' ')[0],
              ),
            ] else ...[
              const Text('Không thể tải thông tin người dùng'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.brown[600]),
                const SizedBox(width: 8),
                Text(
                  'Cài đặt',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Change password
            ListTile(
              leading: const Icon(Icons.lock),
              title: const Text('Đổi mật khẩu'),
              subtitle: const Text('Thay đổi mật khẩu đăng nhập'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _changePassword,
            ),

            const Divider(),

            // Reports
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Báo cáo thống kê'),
              subtitle: const Text('Xem doanh thu và phân tích'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ReportsPage()),
                );
              },
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[600]),
              title: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red[600]),
              ),
              subtitle: const Text('Thoát khỏi ứng dụng'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessHoursDisplay(Map<String, String> businessHours) {
    final dayLabels = {
      'monday': 'Thứ 2',
      'tuesday': 'Thứ 3',
      'wednesday': 'Thứ 4',
      'thursday': 'Thứ 5',
      'friday': 'Thứ 6',
      'saturday': 'Thứ 7',
      'sunday': 'Chủ nhật',
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: businessHours.entries.map((entry) {
            final dayLabel = dayLabels[entry.key] ?? entry.key;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(
                      dayLabel,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                  Text(entry.value),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildFeaturesDisplay(ShopFeatures features) {
    final featureList = [
      {'label': 'Tự động in hóa đơn', 'enabled': features.autoPrintReceipt},
      {
        'label': 'Chương trình khách hàng thân thiết',
        'enabled': features.enableLoyaltyProgram,
      },
      {
        'label': 'Bắt buộc thông tin khách hàng',
        'enabled': features.requireCustomerInfo,
      },
      {'label': 'Dịch vụ tại bàn', 'enabled': features.enableTableService},
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: featureList.map((feature) {
            final enabled = feature['enabled'] as bool;
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Icon(
                    enabled ? Icons.check_circle : Icons.cancel,
                    color: enabled ? Colors.green : Colors.grey,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    feature['label'] as String,
                    style: TextStyle(
                      color: enabled ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      ],
    );
  }

  void _editShopInfo() {
    if (_shopInfo == null) return;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _EditShopInfoDialog(
          shopInfo: _shopInfo!,
          onSaved: () {
            _loadData(); // Reload data after edit
          },
        );
      },
    );
  }

  void _changePassword() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return _ChangePasswordDialog();
      },
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Đăng xuất'),
          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                if (mounted) {
                  // Use AuthHelper.logout for proper navigation
                  AuthHelper.logout(context);
                }
              },
              child: Text(
                'Đăng xuất',
                style: TextStyle(color: Colors.red[600]),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChangePasswordDialog extends StatefulWidget {
  @override
  State<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends State<_ChangePasswordDialog> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _showCurrentPassword = false;
  bool _showNewPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Current password
            TextFormField(
              controller: _currentPasswordController,
              obscureText: !_showCurrentPassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showCurrentPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showCurrentPassword = !_showCurrentPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu hiện tại';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // New password
            TextFormField(
              controller: _newPasswordController,
              obscureText: !_showNewPassword,
              decoration: InputDecoration(
                labelText: 'Mật khẩu mới',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showNewPassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showNewPassword = !_showNewPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mật khẩu mới';
                }
                if (value.length < 6) {
                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Confirm password
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_showConfirmPassword,
              decoration: InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _showConfirmPassword = !_showConfirmPassword;
                    });
                  },
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng xác nhận mật khẩu mới';
                }
                if (value != _newPasswordController.text) {
                  return 'Mật khẩu xác nhận không khớp';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _changePassword,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Đổi mật khẩu'),
        ),
      ],
    );
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.changePassword(
        _currentPasswordController.text,
        _newPasswordController.text,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi đổi mật khẩu: $e'),
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
}

class _EditShopInfoDialog extends StatefulWidget {
  final ShopInfo shopInfo;
  final VoidCallback onSaved;

  const _EditShopInfoDialog({required this.shopInfo, required this.onSaved});

  @override
  State<_EditShopInfoDialog> createState() => _EditShopInfoDialogState();
}

class _EditShopInfoDialogState extends State<_EditShopInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameController;
  late final TextEditingController _addressController;
  late final TextEditingController _phoneController;
  late final TextEditingController _bankNameController;
  late final TextEditingController _accountNumberController;
  late final TextEditingController _accountNameController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _shopNameController = TextEditingController(text: widget.shopInfo.shopName);
    _addressController = TextEditingController(text: widget.shopInfo.address);
    _phoneController = TextEditingController(text: widget.shopInfo.phone);
    _bankNameController = TextEditingController(
      text: widget.shopInfo.bankInfo?.bankName ?? '',
    );
    _accountNumberController = TextEditingController(
      text: widget.shopInfo.bankInfo?.accountNumber ?? '',
    );
    _accountNameController = TextEditingController(
      text: widget.shopInfo.bankInfo?.accountName ?? '',
    );
  }

  @override
  void dispose() {
    _shopNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _bankNameController.dispose();
    _accountNumberController.dispose();
    _accountNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Chỉnh sửa thông tin cửa hàng'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Shop name
              TextFormField(
                controller: _shopNameController,
                decoration: const InputDecoration(
                  labelText: 'Tên cửa hàng *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập tên cửa hàng';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Address
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bank info section
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin ngân hàng (tùy chọn)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Bank name
                    TextFormField(
                      controller: _bankNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên ngân hàng',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Account number
                    TextFormField(
                      controller: _accountNumberController,
                      decoration: const InputDecoration(
                        labelText: 'Số tài khoản',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),

                    // Account name
                    TextFormField(
                      controller: _accountNameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên chủ tài khoản',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveShopInfo,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Lưu'),
        ),
      ],
    );
  }

  Future<void> _saveShopInfo() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare bank info if any field is filled
      Map<String, String>? bankInfo;
      if (_bankNameController.text.isNotEmpty ||
          _accountNumberController.text.isNotEmpty ||
          _accountNameController.text.isNotEmpty) {
        bankInfo = {
          'bank_name': _bankNameController.text.trim(),
          'account_number': _accountNumberController.text.trim(),
          'account_name': _accountNameController.text.trim(),
        };
      }

      await ShopInfoService.updateShopInfo(
        shopName: _shopNameController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        bankInfo: bankInfo,
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin cửa hàng thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi cập nhật thông tin: $e'),
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
}
