# 🏪 AppPOS - Ứng Dụng Quản Lý Bán Hàng

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

Ứng dụng Point of Sale (POS) được phát triển bằng Flutter, hỗ trợ quản lý bán hàng toàn diện cho các cửa hàng nhỏ và vừa.

## 📱 Tính Năng Chính

### 🛒 **Quản Lý Bán Hàng**

- Tạo đơn hàng nhanh chóng
- Quản lý giỏ hàng trực quan
- Tính toán tự động thuế và giảm giá
- In hóa đơn và xuất PDF

### 📦 **Quản Lý Sản Phẩm**

- Thêm/sửa/xóa sản phẩm
- Quản lý danh mục sản phẩm
- Theo dõi tồn kho
- Upload hình ảnh sản phẩm

### 💰 **Thanh Toán Đa Dạng**

- Thanh toán tiền mặt
- Thanh toán MoMo
- Thanh toán chuyển khoản
- Lịch sử giao dịch

### 📊 **Báo Cáo & Thống Kê**

- Báo cáo doanh thu hàng ngày
- Thống kê sản phẩm bán chạy
- Phân tích phương thức thanh toán
- Xuất báo cáo Excel/PDF

### 👥 **Quản Lý Người Dùng**

- Đăng nhập/đăng ký
- Phân quyền người dùng
- Quản lý thông tin cửa hàng
- Bảo mật dữ liệu

## 🚀 Cài Đặt

### Yêu Cầu Hệ Thống

- Flutter SDK 3.35.3 trở lên
- Dart 3.0.0 trở lên
- Android Studio hoặc VS Code
- Android SDK (cho build Android)

### Cài Đặt Dependencies

```bash
# Clone repository
git clone https://github.com/tronghungdev/apppos_tronghung.git
cd apppos_tronghung

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
```

### Cấu Hình API

1. Tạo file `lib/config/api_config.dart` (nếu chưa có)
2. Cập nhật base URL của API server:

```dart
class ApiConfig {
  static const String baseUrl = 'YOUR_API_SERVER_URL';
  // ... other configurations
}
```

## 🏗️ Kiến Trúc Dự Án

```
lib/
├── config/           # Cấu hình API và app
├── constants/        # Constants và themes
├── models/          # Data models
├── providers/       # State management
├── screens/         # UI screens
├── services/        # API services
├── utils/           # Utilities
└── widgets/         # Reusable widgets
```

### 📂 **Thư Mục Chính**

- **models/**: Chứa các data model (Product, Order, User, etc.)
- **services/**: API services và business logic
- **screens/**: Các màn hình của ứng dụng
- **providers/**: State management với Provider pattern
- **widgets/**: Components tái sử dụng

## 🛠️ Công Nghệ Sử Dụng

| Công nghệ              | Mô tả                | Phiên bản |
| ---------------------- | -------------------- | --------- |
| **Flutter**            | UI Framework         | 3.35.3    |
| **Dart**               | Programming Language | 3.0+      |
| **HTTP**               | API Communication    | ^1.1.0    |
| **Provider**           | State Management     | ^6.0.0    |
| **Shared Preferences** | Local Storage        | ^2.0.0    |

## 📱 Screenshots

| Màn Hình Chính                | Quản Lý Sản Phẩm                      | Giỏ Hàng                      |
| ----------------------------- | ------------------------------------- | ----------------------------- |
| ![Main](screenshots/main.png) | ![Products](screenshots/products.png) | ![Cart](screenshots/cart.png) |

## 🔧 Phát Triển

### Chạy Tests

```bash
# Chạy unit tests
flutter test

# Chạy integration tests
flutter drive --target=test_driver/app.dart
```

### Build Production

```bash
# Build APK
flutter build apk --release

# Build App Bundle
flutter build appbundle --release
```

### Code Style

Dự án tuân theo [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style):

```bash
# Format code
flutter format .

# Analyze code
flutter analyze
```

## 🚦 API Endpoints

### Authentication

- `POST /api/auth/login` - Đăng nhập
- `POST /api/auth/register` - Đăng ký
- `POST /api/auth/logout` - Đăng xuất

### Products

- `GET /api/products` - Lấy danh sách sản phẩm
- `POST /api/products` - Tạo sản phẩm mới
- `PUT /api/products/:id` - Cập nhật sản phẩm
- `DELETE /api/products/:id` - Xóa sản phẩm

### Orders

- `GET /api/orders` - Lấy danh sách đơn hàng
- `POST /api/orders` - Tạo đơn hàng mới
- `GET /api/orders/stats` - Thống kê đơn hàng

## 🤝 Đóng Góp

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

## 📄 License

Dự án này được phân phối dưới MIT License. Xem `LICENSE` file để biết thêm thông tin.

## 👨‍💻 Tác Giả

**Trọng Hùng**

- GitHub: [@tronghungdev](https://github.com/tronghungdev)
- Email: tronghung.dev@gmail.com

## 🙏 Cảm Ơn

- [Flutter Team](https://flutter.dev/) - Framework tuyệt vời
- [Dart Team](https://dart.dev/) - Ngôn ngữ lập trình mạnh mẽ
- Cộng đồng Flutter Việt Nam

## 📞 Hỗ Trợ

Nếu bạn gặp vấn đề hoặc có câu hỏi, vui lòng:

1. Kiểm tra [Issues](https://github.com/tronghungdev/apppos_tronghung/issues)
2. Tạo issue mới nếu chưa có
3. Liên hệ trực tiếp qua email

---

⭐ **Đừng quên star repository nếu bạn thấy hữu ích!** ⭐
