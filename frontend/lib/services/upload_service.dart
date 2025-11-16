import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

/// Service để upload ảnh lên backend, backend sẽ upload lên Google Drive
class UploadService {
  // URL của backend API
  // Có thể override bằng cách set environment variable hoặc config
  static String get baseUrl {
    // Kiểm tra environment variable trước (cho production)
    const envUrl = String.fromEnvironment('BACKEND_URL');
    if (envUrl.isNotEmpty) {
      return envUrl;
    }
    
    // Mặc định: dùng Render URL (thay bằng URL thực tế của bạn)
    // TODO: Thay 'your-backend-url' bằng URL Render thực tế
    return 'https://nut-ecom-app.onrender.com';
    
    // Hoặc dùng localhost cho development
    // return 'http://localhost:3000';
  }

  /// Upload ảnh lên backend
  /// Backend sẽ upload lên Google Drive và trả về URL công khai
  /// 
  /// [imageFile]: File ảnh cần upload
  /// 
  /// Trả về URL công khai của ảnh trên Google Drive
  Future<String> uploadImage(File imageFile) async {
    try {
      // Đọc bytes từ file
      final bytes = await imageFile.readAsBytes();
      
      // Tạo multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/image'),
      );

      // Thêm file vào request
      final fileName = imageFile.path.split('/').last;
      final mimeType = _getMimeType(fileName);
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['imageUrl'] as String;
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error']['message'] ?? 'Lỗi upload ảnh');
      }
    } catch (e) {
      throw Exception('Không thể upload ảnh: $e');
    }
  }

  /// Upload ảnh từ bytes (cho Flutter Web)
  /// 
  /// [imageBytes]: Bytes của ảnh cần upload
  /// [fileName]: Tên file (tùy chọn, mặc định: 'image.jpg')
  /// 
  /// Trả về URL công khai của ảnh trên Google Drive
  Future<String> uploadImageBytes(Uint8List imageBytes, {String fileName = 'image.jpg'}) async {
    try {
      // Tạo multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/image'),
      );

      // Xác định MIME type từ tên file
      final mimeType = _getMimeType(fileName);
      
      // Thêm file vào request
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['imageUrl'] as String;
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error']['message'] ?? 'Lỗi upload ảnh');
      }
    } catch (e) {
      throw Exception('Không thể upload ảnh: $e');
    }
  }

  /// Upload ảnh transaction lên backend
  /// Backend sẽ upload lên Google Drive trong folder "transactions"
  /// 
  /// [imageFile]: File ảnh cần upload
  /// [dateStr]: Ngày theo format "ddmmyy" (VD: "161125") - tùy chọn, mặc định là ngày hiện tại
  /// [imageNumber]: Số thứ tự ảnh (VD: "1", "2", "3") - tùy chọn, mặc định là "1"
  /// 
  /// Trả về URL công khai của ảnh trên Google Drive
  Future<String> uploadTransactionImage(
    File imageFile, {
    String? dateStr,
    String imageNumber = '1',
  }) async {
    try {
      // Đọc bytes từ file
      final bytes = await imageFile.readAsBytes();
      
      // Tạo multipart request
      final url = '$baseUrl/api/upload/transaction-image';
      print('Creating request to: $url');
      
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(url),
      );

      // Thêm file vào request
      final fileName = imageFile.path.split('/').last;
      final mimeType = _getMimeType(fileName);
      
      print('Adding file: $fileName, MIME: $mimeType, Size: ${bytes.length} bytes');
      
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Thêm thông tin date và imageNumber vào body
      if (dateStr != null) {
        request.fields['date'] = dateStr;
        print('Added field: date = $dateStr');
      }
      request.fields['imageNumber'] = imageNumber;
      print('Added field: imageNumber = $imageNumber');
      
      print('Request fields: ${request.fields}');
      print('Request files count: ${request.files.length}');

      // Gửi request
      print('=== SENDING REQUEST ===');
      print('URL: $url');
      print('Date: $dateStr, ImageNumber: $imageNumber');
      print('File size: ${bytes.length} bytes');
      print('MIME type: $mimeType');
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('=== RESPONSE ===');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final imageUrl = jsonResponse['imageUrl'] as String?;
        
        if (imageUrl == null || imageUrl.isEmpty) {
          throw Exception('Backend trả về URL rỗng. Response: ${response.body}');
        }
        
        print('Upload thành công, URL: $imageUrl');
        return imageUrl;
      } else {
        String errorMessage = 'Lỗi upload ảnh transaction (HTTP ${response.statusCode})';
        try {
          final errorResponse = json.decode(response.body);
          errorMessage = errorResponse['error']?['message'] ?? 
                        errorResponse['message'] ?? 
                        errorMessage;
        } catch (_) {
          errorMessage = 'HTTP ${response.statusCode}: ${response.body}';
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Exception trong uploadTransactionImage: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Không thể upload ảnh transaction: $e');
    }
  }

  /// Upload ảnh transaction từ bytes (cho Flutter Web)
  /// 
  /// [imageBytes]: Bytes của ảnh cần upload
  /// [fileName]: Tên file (tùy chọn, mặc định: 'image.jpg')
  /// [dateStr]: Ngày theo format "ddmmyy" (VD: "161125") - tùy chọn, mặc định là ngày hiện tại
  /// [imageNumber]: Số thứ tự ảnh (VD: "1", "2", "3") - tùy chọn, mặc định là "1"
  /// 
  /// Trả về URL công khai của ảnh trên Google Drive
  Future<String> uploadTransactionImageBytes(
    Uint8List imageBytes, {
    String fileName = 'image.jpg',
    String? dateStr,
    String imageNumber = '1',
  }) async {
    try {
      // Tạo multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/upload/transaction-image'),
      );

      // Xác định MIME type từ tên file
      final mimeType = _getMimeType(fileName);
      
      // Thêm file vào request
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      );

      // Thêm thông tin date và imageNumber vào body
      if (dateStr != null) {
        request.fields['date'] = dateStr;
      }
      request.fields['imageNumber'] = imageNumber;

      // Gửi request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return jsonResponse['imageUrl'] as String;
      } else {
        final errorResponse = json.decode(response.body);
        throw Exception(errorResponse['error']['message'] ?? 'Lỗi upload ảnh transaction');
      }
    } catch (e) {
      throw Exception('Không thể upload ảnh transaction: $e');
    }
  }

  /// Xác định MIME type từ tên file
  String _getMimeType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }
}

