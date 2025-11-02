# 🏪 Hệ Thống Bán Hàng Và Quản Lý Quán Coffee

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Android](https://img.shields.io/badge/Android-3DDC84?style=for-the-badge&logo=android&logoColor=white)

Ứng dụng Point of Sale (POS) được phát triển bằng Flutter, hỗ trợ quản lý bán hàng toàn diện cho các cửa hàng nhỏ và vừa.

## 📱 Tính Năng Chính

### 🛒 **Quản Lý Bán Hàng**

- Tạo đơn hàng nhanh chóng
- Quản lý giỏ hàng trực quan
- Tính toán tự động thuế và giảm giá
- Lưu đơn 

### 📦 **Quản Lý Sản Phẩm**

- Thêm/sửa/xóa sản phẩm
- Quản lý danh mục sản phẩm


### 💰 **Thanh Toán Đa Dạng**

- Thanh toán tiền mặt
- Thanh toán MoMo
- Thanh toán chuyển khoản
- Lịch sử giao dịch

### 📊 **Báo Cáo & Thống Kê**

- Báo cáo doanh thu hàng ngày
- Phân tích phương thức thanh toán

### 👥 **Quản Lý Người Dùng**

- Đăng nhập/đăng ký
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
git clone https://github.com/Trong-Hung/HeThongBanHangVaQuanLyQuanCoffee.git

# Cài đặt dependencies
flutter pub get

# Chạy ứng dụng
flutter run
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


## 👨‍💻 Tác Giả

**Trọng Hùng**

- GitHub: [@trong-hung](https://github.com/Trong-Hung)
- Email: tronghung.dev@gmail.com

## 📞 Hỗ Trợ

Nếu bạn gặp vấn đề hoặc có câu hỏi, vui lòng:

1. Kiểm tra [Issues](https://github.com/tronghungdev/apppos_tronghung/issues)
2. Tạo issue mới nếu chưa có
3. Liên hệ trực tiếp qua email: votronghung.work@gmail.com

---

⭐ **Đừng quên star repository nếu bạn thấy hữu ích!** ⭐
