# 📱 AppPos Trong Hùng - Hướng Dẫn Dự Án

> **Đây là gì?** Ứng dụng bán hàng (POS) giống như máy tính tiền trong các cửa hàng

## 🎯 Dự Án Này Làm Gì?

**AppPos Trong Hùng** là một ứng dụng di động giúp quản lý cửa hàng bán hàng, giống như:

- 🏪 Máy tính tiền trong siêu thị
- 📊 Sổ sách ghi chép doanh thu
- 📦 Kho hàng theo dõi sản phẩm
- 💳 Máy thanh toán đa hình thức

### ⚡ Tính năng chính:

1. **Bán hàng**: Tạo đơn hàng, tính tiền, in hóa đơn
2. **Quản kho**: Thêm/sửa/xóa sản phẩm và danh mục
3. **Thu ngân**: Nhận tiền mặt, chuyển khoản, MoMo
4. **Báo cáo**: Xem doanh thu theo ngày/tháng
5. **Cài đặt**: Thông tin cửa hàng, tài khoản

## 🛠️ Công Nghệ Sử Dụng

| Công nghệ        | Mô tả dễ hiểu             | Vai trò                                |
| ---------------- | ------------------------- | -------------------------------------- |
| **Flutter**      | Framework tạo app di động | Xây dựng giao diện và logic app        |
| **Dart**         | Ngôn ngữ lập trình        | Viết code cho toàn bộ app              |
| **Node.js**      | Server backend            | Xử lý dữ liệu, API, database           |
| **SQLite/MySQL** | Database                  | Lưu trữ sản phẩm, đơn hàng, khách hàng |

### 📱 App chạy được trên:

- ✅ **Android** (điện thoại, máy tính bảng)
- ✅ **iPhone/iPad**
- ✅ **Website** (trình duyệt)
- ✅ **Windows** (máy tính để bàn)
- ✅ **Mac** và **Linux**

## 📁 Cấu Trúc Thư Mục (Như Tủ Hồ Sơ)

Tưởng tượng dự án như một tủ hồ sơ văn phòng:

```
📂 lib/ (Thư mục chính - chứa toàn bộ code)
├── 📄 main.dart                    # File khởi động app (như công tắc điện)
├── 📂 screens/                     # Các màn hình (như các trang sổ)
├── 📂 models/                      # Định nghĩa dữ liệu (như form mẫu)
├── 📂 services/                    # Kết nối API (như điện thoại liên lạc)
├── 📂 providers/                   # Quản lý trạng thái (như bộ nhớ tạm)
├── 📂 widgets/                     # Thành phần UI (như tem, nhãn dán)
└── 📂 config/                      # Cài đặt (như sổ ghi chú quan trọng)
```

## 🖥️ Các Màn Hình Chính (14 màn hình)

### 🔐 **Nhóm Đăng Nhập/Đăng Ký**

| Màn hình                      | Chức năng         | Giống như             |
| ----------------------------- | ----------------- | --------------------- |
| `login_screen.dart`           | Đăng nhập vào app | Cửa ra vào cửa hàng   |
| `register_screen.dart`        | Tạo tài khoản mới | Đăng ký làm nhân viên |
| `forgot_password_screen.dart` | Quên mật khẩu     | Lấy lại chìa khóa     |

### 🏪 **Nhóm Bán Hàng (POS)**

| Màn hình                   | Chức năng       | Giống như               |
| -------------------------- | --------------- | ----------------------- |
| `order_screen.dart`        | Tạo đơn hàng    | Quầy tính tiền          |
| `cart_screen.dart`         | Xem giỏ hàng    | Giỏ đựng hàng của khách |
| `checkout_screen.dart`     | Thanh toán      | Máy tính tiền           |
| `momo_payment_screen.dart` | Thanh toán MoMo | Máy quét QR MoMo        |

### ⚙️ **Nhóm Quản Lý**

| Màn hình                          | Chức năng         | Giống như            |
| --------------------------------- | ----------------- | -------------------- |
| `management_screen.dart`          | Trang chủ quản lý | Bàn làm việc của sếp |
| `product_management_screen.dart`  | Quản lý sản phẩm  | Sổ kho hàng          |
| `category_management_screen.dart` | Quản lý danh mục  | Sắp xếp kệ hàng      |
| `order_management_screen.dart`    | Xem đơn hàng      | Sổ ghi chép bán hàng |

### 📊 **Nhóm Báo Cáo & Cài Đặt**

| Màn hình               | Chức năng         | Giống như           |
| ---------------------- | ----------------- | ------------------- |
| `reports_page.dart`    | Báo cáo doanh thu | Sổ sách kế toán     |
| `settings_screen.dart` | Cài đặt cửa hàng  | Hồ sơ cửa hàng      |
| `main_screen.dart`     | Màn hình chính    | Sảnh chính cửa hàng |

### 🆕 **Mới Thêm**

| Màn hình                         | Chức năng         | Ghi chú                 |
| -------------------------------- | ----------------- | ----------------------- |
| `daily_orders_screen.dart`       | Đơn hàng hôm nay  | Xem bán được gì hôm nay |
| `daily_order_detail_screen.dart` | Chi tiết đơn hàng | Xem từng đơn cụ thể     |

## 📦 Các File Dữ Liệu (Models) - 10 files

> **Models = Khuôn mẫu** giống như form đơn, giúp định nghĩa dữ liệu có cấu trúc gì

### ✅ **File Đang Dùng Tốt**

| File               | Lưu trữ gì           | Ví dụ dễ hiểu                               |
| ------------------ | -------------------- | ------------------------------------------- |
| `product.dart`     | Thông tin sản phẩm   | Tên: "Cà phê", Giá: 25.000đ, Kệ: "Đồ uống"  |
| `order.dart`       | Thông tin đơn hàng   | Đơn #001, Tổng: 50.000đ, Khách: "Anh Nam"   |
| `category.dart`    | Nhóm sản phẩm        | "Đồ uống", "Bánh kẹo", "Văn phòng phẩm"     |
| `user.dart`        | Thông tin người dùng | Tên: "Thu ngân A", Quyền: "Nhân viên"       |
| `shop_info.dart`   | Thông tin cửa hàng   | Tên: "Cửa hàng ABC", ĐC: "123 Nguyễn Văn A" |
| `momo_models.dart` | Thanh toán MoMo      | Mã QR, link thanh toán, kết quả             |
| `daily_order.dart` | Đơn hàng hôm nay     | **MỚI** - Đơn bán trong ngày                |

### ⚠️ **File Có Vấn Đề (Trùng Lặp)**

| File                 | Vấn đề                  | Giải pháp         |
| -------------------- | ----------------------- | ----------------- |
| `report.dart`        | Quá phức tạp, 300+ dòng | ❌ **SẼ XÓA**     |
| `report_models.dart` | Đơn giản, 80 dòng       | ✅ **ĐÃ GIỮ LẠI** |

**Tại sao trùng lặp?** Có 2 file cùng làm một việc (báo cáo) nhưng 1 file quá phức tạp, 1 file đơn giản.

## 🔧 Các File Kết Nối API (Services) - 11 files

> **Services = Nhân viên giao tiếp** giống như nhân viên liên lạc với kho, ngân hàng, khách hàng

### 🏪 **Nhóm Cốt Lõi**

| Service                 | Nhiệm vụ            | Ví dụ việc làm                         |
| ----------------------- | ------------------- | -------------------------------------- |
| `auth_service.dart`     | Đăng nhập/đăng xuất | Kiểm tra mật khẩu, lưu phiên đăng nhập |
| `product_service.dart`  | Quản lý sản phẩm    | Thêm/sửa/xóa sản phẩm trong kho        |
| `order_service.dart`    | Quản lý đơn hàng    | Tạo đơn mới, xem lịch sử bán hàng      |
| `category_service.dart` | Quản lý danh mục    | Tạo/sửa nhóm sản phẩm                  |

### 💳 **Nhóm Thanh Toán**

| Service                 | Nhiệm vụ         | Ví dụ việc làm                       |
| ----------------------- | ---------------- | ------------------------------------ |
| `payment_service.dart`  | Xử lý thanh toán | Nhận tiền mặt, xác nhận chuyển khoản |
| `momo_api_service.dart` | Thanh toán MoMo  | Tạo mã QR, kiểm tra thanh toán       |

### 📊 **Nhóm Báo Cáo & Cài Đặt**

| Service                     | Nhiệm vụ                   | Ví dụ việc làm                           |
| --------------------------- | -------------------------- | ---------------------------------------- |
| `reports_service.dart`      | Báo cáo bán hàng           | Doanh thu hôm nay, top sản phẩm bán chạy |
| `shop_info_service.dart`    | Thông tin cửa hàng         | Tên, địa chỉ, số điện thoại cửa hàng     |
| `daily_orders_service.dart` | **MỚI** - Đơn hàng hôm nay | Xem đơn bán trong ngày                   |

## 🎛️ Quản Lý Trạng Thái (Providers)

| Provider             | Chức năng        | Ví dụ dễ hiểu                           |
| -------------------- | ---------------- | --------------------------------------- |
| `cart_provider.dart` | Quản lý giỏ hàng | Giống như cái giỏ đựng hàng khi mua sắm |

**Làm gì?**

- ➕ Thêm sản phẩm vào giỏ
- ➖ Bớt/xóa sản phẩm khỏi giỏ
- 🧮 Tự động tính tổng tiền
- 🗑️ Xóa sạch giỏ sau khi thanh toán

## 🔄 Cách Hoạt Động Của App (Workflow)

### 1. 🔐 **Đăng Nhập Vào App**

```
Nhân viên mở app → Nhập tên/mật khẩu → Vào màn hình chính
```

Giống như: Nhân viên quẹt thẻ vào ca làm việc

### 2. 🛒 **Bán Hàng (Quy Trình POS)**

```
1. Màn hình bán hàng → Chọn sản phẩm → Thêm vào giỏ
2. Xem giỏ hàng → Kiểm tra → Ấn thanh toán
3. Chọn hình thức: Tiền mặt/Chuyển khoản/MoMo
4. Xác nhận → In hóa đơn → Hoàn thành
```

Giống như: Quy trình tính tiền ở siêu thị

### 3. ⚙️ **Quản Lý Cửa Hàng**

```
Vào trang quản lý → Chọn mục cần quản lý:
- Sản phẩm: Thêm/sửa/xóa hàng hóa
- Danh mục: Sắp xếp kệ hàng
- Đơn hàng: Xem lịch sử bán hàng
```

### 4. 📊 **Xem Báo Cáo**

```
Vào báo cáo → Nhập mật khẩu bảo mật → Chọn ngày → Xem:
- Tổng doanh thu hôm nay
- Số đơn hàng đã bán
- Phân tích theo hình thức thanh toán
```

### 5. 🆕 **Xem Đơn Hàng Hôm Nay (Tính năng mới)**

```
Vào đơn hàng → Xem danh sách bán hôm nay → Chọn đơn → Xem chi tiết
```

## 💳 Các Hình Thức Thanh Toán

### 💵 **1. Tiền Mặt (CASH)**

- Khách đưa tiền → Nhân viên nhận → Trả lại thừa
- **Đơn giản nhất, mặc định**

### 🏦 **2. Chuyển Khoản (BANK_TRANSFER)**

- Khách chuyển khoản → Nhân viên kiểm tra → Xác nhận
- **Thủ công, cần kiểm tra**

### 📱 **3. Thanh Toán MoMo**

- App tạo mã QR → Khách quét MoMo → Thanh toán → Xác nhận
- **Tự động, hiện đại**

### 💳 **4. Thẻ Tín Dụng (CARD)**

- Khách quẹt thẻ → Nhân viên xác nhận → Hoàn tất
- **Thủ công**

## 🔗 Kết Nối Backend (API)

### 🌐 **Địa Chỉ Server**

- **Phát triển**: `http://10.0.2.2:3000` (Giả lập Android)
- **Máy tính**: `http://localhost:3000` (Máy thật)

### 🔐 **Bảo Mật**

1. **Token đăng nhập**: Như chìa khóa vào cửa hàng
2. **Token báo cáo**: Như chìa khóa két sắt (30 phút tự khóa)

### 📡 **Các Đường Dẫn API**

| Nhóm        | Đường dẫn                  | Chức năng               |
| ----------- | -------------------------- | ----------------------- |
| Đăng nhập   | `/api/auth/login`          | Đăng nhập vào hệ thống  |
| Sản phẩm    | `/api/products`            | Quản lý kho hàng        |
| Đơn hàng    | `/api/orders`              | Quản lý bán hàng        |
| Báo cáo     | `/api/reports/daily`       | Xem doanh thu           |
| MoMo        | `/api/momo/create-payment` | Tạo QR thanh toán       |
| Đơn hôm nay | `/api/daily-orders/*`      | **MỚI** - Đơn hàng ngày |

## ✅ Những Gì Đã Hoàn Thành

### 🎉 **Đã Làm Xong**

1. ✅ **Tính năng đơn hàng hôm nay** - Thêm tab mới trong thanh điều hướng
2. ✅ **Sửa QR MoMo** - Bỏ chuyển hướng web, chỉ hiển thị mã QR
3. ✅ **Debug logs** - Thêm nhật ký để theo dõi lỗi BANK_TRANSFER

### 🔧 **Đang Sửa**

1. 🐛 **Lỗi hiển thị BANK_TRANSFER** - Chỉ thấy tiền mặt thay vì 2 đơn chuyển khoản

## 🧹 Kế Hoạch Dọn Dẹp Code

### 🎯 **Ưu Tiên Cao**

#### 1. 🏷️ **Đổi Tên File (Simple Report → Report)**

**Tại sao?** Tên "simple_report" thừa chữ "simple", chỉ cần "report"

**✅ ĐÃ HOÀN THÀNH - Đã đổi tên:**

- `simple_report_models.dart` → `report_models.dart`
- `simple_reports_service.dart` → `reports_service.dart`
- `simple_reports_page.dart` → `reports_page.dart`

**✅ ĐÃ HOÀN THÀNH - Đã sửa import ở 4 file:**

- `main.dart`
- `management_screen.dart`
- `settings_screen.dart`
- File `reports_page.dart` (đã được đổi tên)

#### 2. 🗑️ **Xóa File Trùng Lặp**

**✅ ĐÃ HOÀN THÀNH - Vấn đề:** Có 2 file làm cùng 1 việc (báo cáo)

- `report.dart` - Phức tạp (300+ dòng) ❌ **ĐÃ XÓA**
- `report_models.dart` - Đơn giản (80 dòng) ✅ **ĐÃ GIỮ LẠI**

**✅ Đã kiểm tra:** File `order_service.dart` không sử dụng file cũ

### � **Dọn Dẹp Khác**

1. 🗂️ **Xóa thư mục build reports** - File tạm của Android
2. 🧪 **Kiểm tra test files** - Xóa test không dùng
3. 📝 **Cập nhật README.md** - Thông tin mới nhất

## 🛠️ Thông Tin Kỹ Thuật

### 📚 **Thư Viện Chính**

| Thư viện             | Làm gì         | Ví dụ                            |
| -------------------- | -------------- | -------------------------------- |
| `http`               | Gọi API        | Lấy danh sách sản phẩm từ server |
| `shared_preferences` | Lưu trữ local  | Nhớ trạng thái đăng nhập         |
| `provider`           | Quản lý state  | Cập nhật giỏ hàng realtime       |
| `qr_flutter`         | Tạo QR code    | Mã QR thanh toán MoMo            |
| `intl`               | Format ngày/số | "25.000đ", "28/12/2024"          |

### 💻 **Yêu Cầu Hệ Thống**

| Platform    | Yêu cầu tối thiểu     |
| ----------- | --------------------- |
| **Android** | Android 5.0+ (API 21) |
| **iPhone**  | iOS 11.0+             |
| **Flutter** | Phiên bản 3.0+        |
| **Dart**    | Phiên bản 3.0+        |

## 🔍 Debug & Theo Dõi

### 🪲 **Cách Theo Dõi Lỗi**

App sử dụng **emoji logs** để dễ nhận biết:

| Icon | Ý nghĩa           | Ví dụ                           |
| ---- | ----------------- | ------------------------------- |
| 🔐   | Đăng nhập/bảo mật | "🔐 Đang đăng nhập..."          |
| 📊   | Báo cáo           | "📊 Lấy doanh thu hôm nay..."   |
| 💰   | Thanh toán        | "💰 Xử lý thanh toán MoMo..."   |
| ✅   | Thành công        | "✅ Tạo đơn hàng thành công!"   |
| ❌   | Lỗi               | "❌ Không kết nối được server!" |

### 🛡️ **Xử Lý Lỗi**

- **Try-catch** ở mọi API call
- **Thông báo user-friendly** (tiếng Việt dễ hiểu)
- **Fallback UI** (giao diện dự phòng khi lỗi)

## 🏆 Tổng Kết

### 📊 **Con Số Ấn Tượng**

- **14 màn hình** hoàn chỉnh
- **11 API services** kết nối backend
- **10 data models** cho business logic
- **6 platforms** hỗ trợ (Android, iOS, Web, Windows, Mac, Linux)
- **4 phương thức** thanh toán

### 💪 **Điểm Mạnh**

- ✅ Kiến trúc module rõ ràng
- ✅ Tách biệt logic và giao diện tốt
- ✅ Xử lý lỗi toàn diện
- ✅ Tích hợp API realtime
- ✅ Đa nền tảng

### 🔧 **Cần Cải Thiện**

- 🧹 Cleanup file trùng lặp
- 🏷️ Đặt tên conventions
- 📝 Tài liệu chi tiết hơn
- 🧪 Viết test coverage

---

## 💡 Kết Luận

**AppPos Trong Hùng** là một hệ thống POS hoàn chỉnh, giống như có một **nhân viên thu ngân thông minh** có thể:

- 🛒 **Bán hàng nhanh chóng** với giao diện đơn giản
- 💳 **Nhận nhiều hình thức thanh toán** từ tiền mặt đến MoMo
- 📊 **Báo cáo chi tiết** doanh thu theo ngày
- ⚙️ **Quản lý kho hàng** dễ dàng
- 🔐 **Bảo mật tốt** với nhiều lớp xác thực

App này phù hợp cho các **cửa hàng nhỏ và vừa** cần một giải pháp POS hiện đại nhưng không quá phức tạp.

---

**📅 Tài liệu cập nhật:** 28/12/2024  
**📝 Phiên bản:** 1.0 (Dễ hiểu)  
**👨‍💻 Tác giả:** GitHub Copilot Assistant
