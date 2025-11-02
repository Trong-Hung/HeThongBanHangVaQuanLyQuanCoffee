import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/login_screen.dart';
import 'screens/main_screen.dart';
import 'screens/reports_page.dart';
import 'services/auth_service.dart';
import 'providers/cart_provider.dart';

void main() {
  // Tắt debug error overlays
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return const SizedBox.shrink();
  };

  // Tắt debug mode
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const PosApp());
}

class PosApp extends StatelessWidget {
  const PosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => CartProvider())],
      child: MaterialApp(
        title: 'POS Coffee Shop',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.brown,
          appBarTheme: AppBarTheme(
            backgroundColor: Colors.brown[600],
            foregroundColor: Colors.white,
          ),
        ),
        home: const AuthWrapper(),
        routes: {'/reports': (context) => const ReportsPage()},
        builder: (context, child) {
          // Tắt error widgets và debug overlays
          ErrorWidget.builder = (FlutterErrorDetails details) {
            return const SizedBox.shrink();
          };

          return MediaQuery(
            data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
            child: Banner(
              message: '',
              location: BannerLocation.topStart,
              child: child!,
            ),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final token = await AuthService.getToken();
      final isLoggedIn = await AuthService.isLoggedIn();
      print('🔐 Auth check - Token: ${token != null ? "EXISTS" : "NULL"}');
      print('🔐 Auth check - Is logged in: $isLoggedIn');
      setState(() {
        _isLoggedIn = isLoggedIn;
        _isLoading = false;
      });
    } catch (e) {
      print('🔐 Auth check error: $e');
      setState(() {
        _isLoggedIn = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.brown[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Đang khởi động...'),
            ],
          ),
        ),
      );
    }

    return _isLoggedIn ? const MainScreen() : const LoginScreen();
  }
}
