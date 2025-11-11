# Hướng dẫn Test App trên Windows Desktop

## Yêu cầu

Để chạy Flutter app trên Windows desktop, bạn cần:

1. **Visual Studio 2022** (Community, Professional, hoặc Enterprise)
   - Download: https://visualstudio.microsoft.com/downloads/
   - Khi cài đặt, chọn workload: **"Desktop development with C++"**
   - Bao gồm các components:
     - MSVC v143 - VS 2022 C++ x64/x86 build tools
     - Windows 10/11 SDK
     - C++ CMake tools for Windows

## Các bước

### 1. Cài đặt Visual Studio
- Tải Visual Studio Installer
- Chọn "Desktop development with C++"
- Cài đặt

### 2. Kiểm tra Flutter
```bash
flutter doctor
```
Đảm bảo Visual Studio hiển thị ✓

### 3. Tạo Windows project (nếu chưa có)
```bash
cd frontend
flutter create --platforms=windows .
```

### 4. Chạy app trên Windows
```bash
flutter run -d windows
```

## Lưu ý

- Windows desktop app cần build lâu hơn web
- Lần đầu build có thể mất 5-10 phút
- App sẽ mở trong cửa sổ Windows riêng

## Troubleshooting

**Lỗi: Visual Studio not found**
- Cài đặt Visual Studio với workload "Desktop development with C++"
- Restart terminal/IDE sau khi cài

**Lỗi: Windows SDK not found**
- Cài đặt Windows 10/11 SDK từ Visual Studio Installer

**Build failed**
- Chạy `flutter clean`
- Chạy `flutter pub get`
- Thử lại `flutter run -d windows`

