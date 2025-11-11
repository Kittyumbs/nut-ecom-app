/// VÍ DỤ: Cách sử dụng Google Drive Service
/// 
/// Bước 1: Import service
/// ```dart
/// import 'package:nut_ecom_app/services/google_drive_service.dart';
/// ```
/// 
/// Bước 2: Khởi tạo service
/// ```dart
/// final driveService = GoogleDriveService();
/// ```
/// 
/// Bước 3: Đăng nhập Google (lần đầu tiên)
/// ```dart
/// final account = await driveService.signIn();
/// if (account == null) {
///   // Người dùng hủy đăng nhập
///   return;
/// }
/// print('Đã đăng nhập: ${account.email}');
/// ```
/// 
/// Bước 4: Upload ảnh lên Drive
/// ```dart
/// // Giả sử bạn đã có ảnh từ ImagePicker
/// final imagePicker = ImagePicker();
/// final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
/// 
/// if (pickedFile != null) {
///   // Đọc bytes từ file
///   final bytes = await pickedFile.readAsBytes();
///   
///   // Upload lên Drive
///   try {
///     final imageUrl = await driveService.uploadImage(
///       fileName: 'product_${DateTime.now().millisecondsSinceEpoch}.jpg',
///       mimeType: 'image/jpeg',
///       bytes: bytes,
///     );
///     
///     print('URL ảnh: $imageUrl');
///     // Lưu imageUrl vào Firestore
///   } catch (e) {
///     print('Lỗi upload: $e');
///   }
/// }
/// ```
/// 
/// 
/// === GIẢI THÍCH SCOPE ===
/// 
/// Scope = Quyền truy cập mà app xin từ Google
/// 
/// Khi bạn gọi `driveService.signIn()`, Google sẽ hiển thị dialog:
/// "App muốn truy cập:
///  - Email của bạn
///  - Google Drive (để đọc/ghi file)"
/// 
/// Người dùng phải đồng ý thì app mới có quyền upload file.
/// 
/// Scope 'https://www.googleapis.com/auth/drive.file' nghĩa là:
/// - Chỉ truy cập file do app này tạo (không thấy file khác)
/// - Có thể đọc/ghi/xóa file do app tạo
/// 
/// Nếu muốn truy cập toàn bộ Drive của user, dùng:
/// 'https://www.googleapis.com/auth/drive'
/// (Nhưng không khuyến nghị vì quyền quá rộng)

