import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;
  String? _successMessage;

  // Stages: email -> code -> password
  int _currentStep = 0;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.forgotPassword(
        _emailController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          setState(() {
            _currentStep = 1; // Go to verification step
            _successMessage = 'Mã xác nhận đã được gửi đến email của bạn';
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Gửi mã thất bại';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.verifyResetCode(
        _emailController.text.trim(),
        _codeController.text.trim(),
      );

      if (mounted) {
        if (result['success']) {
          setState(() {
            _currentStep = 2;
            _successMessage = 'Mã xác nhận đúng. Vui lòng nhập mật khẩu mới';
          });
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Mã xác nhận không đúng';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await AuthService.resetPassword(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      print('🔑 Reset password result: $result');

      if (mounted) {
        // Nếu không có lỗi exception nghĩa là API call thành công
        // Kiểm tra success field hoặc giả định thành công nếu không có exception
        if (result['success'] == true ||
            (result['success'] == null && result['message'] != null)) {
          // Show success dialog and go back to login
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Thành công'),
              content: const Text(
                'Mật khẩu đã được đặt lại thành công. Vui lòng đăng nhập với mật khẩu mới.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to login
                  },
                  child: const Text('Đăng nhập'),
                ),
              ],
            ),
          );
        } else {
          setState(() {
            _errorMessage = result['message'] ?? 'Đặt lại mật khẩu thất bại';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Quên mật khẩu'),
        backgroundColor: Colors.orange[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress indicator
                Container(
                  margin: const EdgeInsets.only(bottom: 32),
                  child: Row(
                    children: [
                      _buildStepIndicator(0, 'Email', _currentStep >= 0),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _currentStep >= 1
                              ? Colors.orange
                              : Colors.grey[300],
                        ),
                      ),
                      _buildStepIndicator(1, 'Mã', _currentStep >= 1),
                      Expanded(
                        child: Container(
                          height: 2,
                          color: _currentStep >= 2
                              ? Colors.orange
                              : Colors.grey[300],
                        ),
                      ),
                      _buildStepIndicator(2, 'Mật khẩu', _currentStep >= 2),
                    ],
                  ),
                ),

                // Form content based on current step
                if (_currentStep == 0) _buildEmailStep(),
                if (_currentStep == 1) _buildCodeStep(),
                if (_currentStep == 2) _buildPasswordStep(),

                // Messages
                if (_errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red[200]!),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: TextStyle(color: Colors.red[600]),
                    ),
                  ),
                ],

                if (_successMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: Text(
                      _successMessage!,
                      style: TextStyle(color: Colors.green[600]),
                    ),
                  ),
                ],

                const SizedBox(height: 32),

                // Action button
                ElevatedButton(
                  onPressed: _isLoading ? null : _getCurrentAction(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_getCurrentButtonText()),
                ),

                if (_currentStep > 0) ...[
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _currentStep--;
                        _errorMessage = null;
                        _successMessage = null;
                      });
                    },
                    child: const Text('Quay lại'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label, bool isActive) {
    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.orange[600] : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              '${step + 1}',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.orange[600] : Colors.grey[600],
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập email của bạn',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Chúng tôi sẽ gửi mã xác nhận đến email này',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@email.com',
            prefixIcon: const Icon(Icons.email),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập email';
            }
            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
              return 'Email không hợp lệ';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCodeStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập mã xác nhận',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Vui lòng kiểm tra email ${_emailController.text} và nhập mã xác nhận 6 chữ số',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _codeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Mã xác nhận',
            hintText: '123456',
            prefixIcon: const Icon(Icons.security),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng nhập mã xác nhận';
            }
            if (value.length != 6) {
              return 'Mã xác nhận phải có 6 chữ số';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Đặt mật khẩu mới',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Nhập mật khẩu mới cho tài khoản của bạn',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        TextFormField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            hintText: 'Nhập mật khẩu mới',
            prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
        TextFormField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            hintText: 'Nhập lại mật khẩu',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Vui lòng xác nhận mật khẩu mới';
            }
            if (value != _passwordController.text) {
              return 'Mật khẩu xác nhận không khớp';
            }
            return null;
          },
        ),
      ],
    );
  }

  VoidCallback? _getCurrentAction() {
    switch (_currentStep) {
      case 0:
        return _sendResetCode;
      case 1:
        return _verifyCode;
      case 2:
        return _resetPassword;
      default:
        return null;
    }
  }

  String _getCurrentButtonText() {
    switch (_currentStep) {
      case 0:
        return 'Gửi mã xác nhận';
      case 1:
        return 'Xác nhận mã';
      case 2:
        return 'Đặt lại mật khẩu';
      default:
        return '';
    }
  }
}
