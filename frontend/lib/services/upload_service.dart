import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';

/// Service để upload ảnh lên backend, backend sẽ upload lên Google Drive
class UploadService {
  // URL của backend API
  // Thay đổi theo môi trường (development/production)
  static const String baseUrl = 'http://localhost:3000'; // Development
  // static const String baseUrl = 'https://your-backend-url.com'; // Production

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

