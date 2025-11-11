# Nut E-Commerce Order Management - Flutter Frontend

## Mô tả
Ứng dụng Flutter để quản lý đơn hàng, kết nối với Firestore database.

## Yêu cầu
- Flutter SDK >= 3.0.0
- Dart SDK >= 3.0.0
- Firebase project đã được thiết lập

## Cài đặt

1. Cài đặt dependencies:
```bash
flutter pub get
```

2. Cấu hình Firebase:
   - Tạo project trên Firebase Console
   - Tải file `google-services.json` (Android) và `GoogleService-Info.plist` (iOS)
   - Đặt vào thư mục tương ứng:
     - Android: `android/app/google-services.json`
     - iOS: `ios/Runner/GoogleService-Info.plist`
   - Cập nhật `lib/firebase_options.dart` với thông tin từ Firebase project

3. Chạy ứng dụng:
```bash
flutter run
```

## Cấu trúc thư mục

```
lib/
├── main.dart                 # Entry point
├── firebase_options.dart     # Firebase configuration
├── models/
│   └── order.dart           # Order data models
├── services/
│   └── firestore_service.dart  # Firestore service layer
├── providers/
│   └── order_provider.dart  # State management
└── screens/
    ├── home_screen.dart
    ├── order_list_screen.dart
    ├── add_order_screen.dart
    └── order_detail_screen.dart
```

## Tính năng
- Xem danh sách đơn hàng
- Tạo đơn hàng mới
- Xem chi tiết đơn hàng
- Cập nhật trạng thái đơn hàng
- Xóa đơn hàng
- Real-time updates từ Firestore

