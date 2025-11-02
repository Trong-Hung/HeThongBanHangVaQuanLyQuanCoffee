import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'order_screen.dart';
import 'management_screen.dart';
import 'daily_orders_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      const OrderScreen(),
      const ManagementScreen(),
      const DailyOrdersScreen(),
      const SettingsScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Colors.brown[600],
        unselectedItemColor: Colors.grey[600],
        backgroundColor: Colors.white,
        elevation: 8,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Đơn hàng',
            tooltip: 'Màn hình POS - Tạo đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Quản lý',
            tooltip: 'Quản lý sản phẩm, danh mục, đơn hàng',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.today),
            label: 'Hôm nay',
            tooltip: 'Đơn hàng hôm nay - Theo dõi tiến độ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Cài đặt',
            tooltip: 'Thông tin cửa hàng và cài đặt',
          ),
        ],
      ),
    );
  }
}

// Helper function to check authentication and navigate
class AuthHelper {
  static Future<void> checkAuthAndNavigate(BuildContext context) async {
    final isLoggedIn = await AuthService.isLoggedIn();

    if (!isLoggedIn && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  static Future<void> logout(BuildContext context) async {
    await AuthService.logout();

    if (context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }
}
