import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:typed_data';
import 'dart:convert';

/// Service để quản lý Google Drive API
/// Admin đăng nhập một lần, access token được lưu lại
/// Client không cần đăng nhập, chỉ cần upload ảnh
class GoogleDriveService {
  static const String _accessTokenKey = 'google_drive_access_token';
  static const String _tokenExpiryKey = 'google_drive_token_expiry';
  
  // Scope để upload file lên Drive
  static const List<String> _scopes = [
    'https://www.googleapis.com/auth/drive.file',
  ];

  // Khởi tạo GoogleSignIn
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: _scopes,
  );

  /// Đăng nhập Google (chỉ admin cần làm một lần)
  /// Lưu access token để dùng sau này
  Future<bool> signIn() async {
    try {
      // Thử đăng nhập im lặng trước (nếu đã đăng nhập)
      GoogleSignInAccount? account = await _googleSignIn.signInSilently();
      
      // Nếu chưa đăng nhập, hiển thị dialog đăng nhập
      account ??= await _googleSignIn.signIn();
      
      if (account == null) {
        return false; // Người dùng hủy
      }

      // Lấy authentication từ account
      final GoogleSignInAuthentication auth = await account.authentication;
      
      // Trong google_sign_in 7.2.0, accessToken có thể nằm trong auth
      // Nếu không có, cần request lại
      String? accessToken = auth.accessToken;
      
      if (accessToken == null) {
        // Thử lấy từ serverAuthCode hoặc request lại
        // Trong trường hợp này, chúng ta cần request token từ Google
        throw Exception('Không lấy được access token. Vui lòng thử lại.');
      }

      // Lưu access token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_accessTokenKey, accessToken);
      
      // Lưu thời gian hết hạn (giả sử 1 giờ)
      final expiry = DateTime.now().add(const Duration(hours: 1));
      await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
      
      return true;
    } catch (e) {
      print('Lỗi đăng nhập Google: $e');
      return false;
    }
  }

  /// Kiểm tra xem đã đăng nhập chưa (có token chưa)
  Future<bool> isSignedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_accessTokenKey);
    if (accessToken == null) {
      // Thử kiểm tra xem GoogleSignIn có account không
      try {
        final account = await _googleSignIn.signInSilently();
        if (account != null) {
          // Có account nhưng chưa lưu token, lấy lại token
          return await signIn();
        }
      } catch (e) {
        // Không có account
      }
      return false;
    }

    // Kiểm tra token còn hạn không
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        // Token hết hạn, thử refresh
        return await _refreshAccessToken();
      }
    }

    return true;
  }

  /// Refresh access token nếu hết hạn
  Future<bool> _refreshAccessToken() async {
    try {
      // Thử đăng nhập im lặng lại để lấy token mới
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        final GoogleSignInAuthentication auth = await account.authentication;
        
        if (auth.accessToken != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_accessTokenKey, auth.accessToken!);
          final expiry = DateTime.now().add(const Duration(hours: 1));
          await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
          return true;
        }
      }
      return false;
    } catch (e) {
      print('Lỗi refresh token: $e');
      return false;
    }
  }

  /// Đăng xuất (xóa token)
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessTokenKey);
    await prefs.remove(_tokenExpiryKey);
  }

  /// Lấy access token hiện tại (hoặc refresh nếu hết hạn)
  Future<String?> _getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString(_accessTokenKey);
    
    if (accessToken == null) {
      // Thử lấy từ GoogleSignIn
      try {
        final account = await _googleSignIn.signInSilently();
        if (account != null) {
          final GoogleSignInAuthentication auth = await account.authentication;
          accessToken = auth.accessToken;
          
          if (accessToken != null) {
            // Lưu token mới
            await prefs.setString(_accessTokenKey, accessToken);
            final expiry = DateTime.now().add(const Duration(hours: 1));
            await prefs.setString(_tokenExpiryKey, expiry.toIso8601String());
          }
        }
      } catch (e) {
        // Không lấy được token
      }
      return accessToken;
    }

    // Kiểm tra token còn hạn không
    final expiryStr = prefs.getString(_tokenExpiryKey);
    if (expiryStr != null) {
      final expiry = DateTime.parse(expiryStr);
      if (DateTime.now().isAfter(expiry)) {
        // Token hết hạn, thử refresh
        final refreshed = await _refreshAccessToken();
        if (refreshed) {
          return prefs.getString(_accessTokenKey);
        }
        return null;
      }
    }

    return accessToken;
  }

  /// Tạo Drive API client từ access token
  Future<drive.DriveApi> _getDriveApi() async {
    // Lấy access token
    String? accessToken = await _getAccessToken();
    
    if (accessToken == null) {
      throw Exception('Chưa đăng nhập Google. Vui lòng đăng nhập trước.');
    }

    // Tạo HTTP client với auth headers
    final client = _GoogleAuthClient(accessToken);
    
    // Trả về Drive API client
    return drive.DriveApi(client);
  }

  /// Upload ảnh lên Google Drive và trả về URL công khai
  /// 
  /// [fileName]: Tên file (VD: "product_123.jpg")
  /// [mimeType]: Loại file (VD: "image/jpeg", "image/png")
  /// [bytes]: Dữ liệu ảnh dạng Uint8List
  /// 
  /// Trả về URL công khai để truy cập ảnh
  Future<String> uploadImage({
    required String fileName,
    required String mimeType,
    required Uint8List bytes,
  }) async {
    try {
      // Lấy Drive API client
      final driveApi = await _getDriveApi();

      // Tạo metadata cho file
      final fileMetadata = drive.File()
        ..name = fileName
        ..mimeType = mimeType;

      // Tạo media stream từ bytes
      final media = drive.Media(
        Stream.value(bytes),
        bytes.length,
        contentType: mimeType,
      );

      // Upload file lên Drive
      final createdFile = await driveApi.files.create(
        fileMetadata,
        uploadMedia: media,
        $fields: 'id,webViewLink,webContentLink',
      );

      if (createdFile.id == null) {
        throw Exception('Không tạo được file trên Drive');
      }

      // Cho phép ai có link cũng xem được (public read)
      final permission = drive.Permission()
        ..type = 'anyone'
        ..role = 'reader';

      await driveApi.permissions.create(
        permission,
        createdFile.id!,
        sendNotificationEmail: false,
      );

      // Trả về URL công khai để hiển thị ảnh trực tiếp
      // Format: https://drive.google.com/uc?export=view&id=FILE_ID
      // Link này cho phép hiển thị ảnh trực tiếp trong <img> tag
      return 'https://drive.google.com/uc?export=view&id=${createdFile.id}';
    } catch (e) {
      print('Lỗi upload ảnh lên Drive: $e');
      rethrow;
    }
  }
}

/// HTTP Client wrapper để thêm auth headers vào mọi request
class _GoogleAuthClient extends http.BaseClient {
  final String _accessToken;
  final http.Client _client = http.Client();

  _GoogleAuthClient(this._accessToken);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    // Thêm auth headers vào request
    request.headers['Authorization'] = 'Bearer $_accessToken';
    return _client.send(request);
  }

  @override
  void close() {
    _client.close();
    super.close();
  }
}
