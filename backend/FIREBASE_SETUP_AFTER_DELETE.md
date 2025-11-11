# Hướng dẫn Setup Firebase sau khi xóa Project

## ⚠️ Tình huống
Bạn đã xóa Firebase project cũ (`nut-ecom-app`) và cần tạo lại từ đầu.

---

## 📋 BƯỚC 1: Tạo Firebase Project Mới

### 1.1. Truy cập Firebase Console
1. Vào: https://console.firebase.google.com/
2. Đăng nhập bằng tài khoản Google của bạn

### 1.2. Tạo Project Mới
1. Click **"Add project"** hoặc **"Create a project"**
2. Điền thông tin:
   - **Project name:** `nut-ecom-app` (hoặc tên bạn muốn)
   - **Project ID:** Firebase sẽ tự tạo (VD: `nut-ecom-app-12345`)
   - Click **"Continue"**
3. **Google Analytics:** 
   - Bạn có thể bật hoặc tắt (tùy chọn)
   - Click **"Continue"** hoặc **"Create project"**
4. Chờ vài giây → Project được tạo thành công
5. Click **"Continue"** để vào project

✅ **Checkpoint:** Đã có Firebase project mới

---

## 📋 BƯỚC 2: Bật Firestore Database

### 2.1. Tạo Firestore Database
1. Trong Firebase Console, vào menu bên trái
2. Click **"Firestore Database"**
3. Click **"Create database"**
4. Chọn **"Start in test mode"** (cho development)
   - ⚠️ **Lưu ý:** Test mode cho phép đọc/ghi trong 30 ngày. Sau đó cần cấu hình rules.
5. Chọn **Location:** Chọn region gần nhất (VD: `asia-southeast1` - Singapore)
6. Click **"Enable"**
7. Chờ vài giây → Firestore đã được tạo

✅ **Checkpoint:** Firestore Database đã được bật

---

## 📋 BƯỚC 3: Lấy Service Account Key (Cho Backend)

### 3.1. Tạo Service Account
1. Trong Firebase Console, click vào **⚙️ Settings** (góc trên bên phải)
2. Chọn **"Project settings"**
3. Vào tab **"Service accounts"**
4. Click **"Generate new private key"**
5. Click **"Generate key"** trong popup cảnh báo
6. File JSON sẽ được tải xuống (VD: `nut-ecom-app-xxxxx-firebase-adminsdk-xxxxx.json`)

✅ **Checkpoint:** Đã có Service Account Key file

### 3.2. Lấy JSON String cho Environment Variable
1. Mở file JSON vừa tải về bằng text editor
2. Copy toàn bộ nội dung JSON
3. **Quan trọng:** JSON này phải là một dòng string khi đặt vào environment variable
4. Lưu lại để dùng cho Bước 4

**Ví dụ format:**
```json
{"type":"service_account","project_id":"nut-ecom-app-12345","private_key_id":"abc123...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"firebase-adminsdk-xxxxx@nut-ecom-app-12345.iam.gserviceaccount.com","client_id":"123456789","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-xxxxx%40nut-ecom-app-12345.iam.gserviceaccount.com"}
```

✅ **Checkpoint:** Đã có JSON string của Service Account

---

## 📋 BƯỚC 4: Cập nhật Backend trên Render

### 4.1. Thêm Environment Variable trên Render
1. Vào Render Dashboard: https://dashboard.render.com/
2. Chọn service backend của bạn
3. Vào tab **"Environment"** (menu bên trái)
4. Tìm hoặc thêm biến:
   - **Key:** `FIREBASE_SERVICE_ACCOUNT_KEY`
   - **Value:** Paste toàn bộ JSON string từ Bước 3.2
   - ⚠️ **QUAN TRỌNG:** 
     - Phải là một dòng JSON (không có line breaks)
     - Nếu JSON có line breaks trong `private_key`, phải giữ nguyên `\n`
     - Hoặc escape đúng cách
5. Click **"Save Changes"**

### 4.2. Redeploy
1. Render sẽ tự động trigger deploy khi bạn save environment variable
2. Hoặc vào tab **"Manual Deploy"** → Click **"Deploy latest commit"**
3. Chờ deploy hoàn thành
4. Kiểm tra logs để đảm bảo không có lỗi

✅ **Checkpoint:** Backend đã được cấu hình với Firebase mới

---

## 📋 BƯỚC 5: Cập nhật Frontend (Flutter App)

### 5.1. Lấy Firebase Config cho Flutter

**Cho Android:**
1. Trong Firebase Console, vào **⚙️ Settings** → **"Project settings"**
2. Scroll xuống phần **"Your apps"**
3. Click icon **Android** (🟢)
4. Nếu chưa có app, click **"Add app"** → Chọn **Android**
5. Điền thông tin:
   - **Android package name:** Lấy từ `frontend/android/app/build.gradle` (tìm `applicationId`)
   - Click **"Register app"**
6. Tải file `google-services.json`
7. Thay thế file cũ: `frontend/android/app/google-services.json`

**Cho iOS:**
1. Click icon **iOS** (🍎)
2. Nếu chưa có app, click **"Add app"** → Chọn **iOS**
3. Điền thông tin:
   - **iOS bundle ID:** Lấy từ Xcode project
   - Click **"Register app"**
4. Tải file `GoogleService-Info.plist`
5. Thay thế file cũ: `frontend/ios/Runner/GoogleService-Info.plist`

**Cho Web:**
1. Click icon **Web** (</>)
2. Nếu chưa có app, click **"Add app"** → Chọn **Web**
3. Điền **App nickname** (tùy chọn)
4. Click **"Register app"**
5. Copy các giá trị: `apiKey`, `appId`, `messagingSenderId`, `projectId`, `authDomain`, `storageBucket`

### 5.2. Cập nhật firebase_options.dart

1. Mở file: `frontend/lib/firebase_options.dart`
2. Cập nhật các giá trị từ Firebase Console:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'YOUR_NEW_API_KEY',           // Từ Firebase Console
  appId: 'YOUR_NEW_APP_ID',              // Từ Firebase Console
  messagingSenderId: 'YOUR_SENDER_ID',   // Từ Firebase Console
  projectId: 'YOUR_NEW_PROJECT_ID',      // Từ Firebase Console
  authDomain: 'YOUR_PROJECT_ID.firebaseapp.com',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  measurementId: 'G-XXXXXXXXXX',         // Từ Firebase Console (nếu có)
);

static const FirebaseOptions android = FirebaseOptions(
  apiKey: 'YOUR_NEW_ANDROID_API_KEY',
  appId: 'YOUR_NEW_ANDROID_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_NEW_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
);

static const FirebaseOptions ios = FirebaseOptions(
  apiKey: 'YOUR_NEW_IOS_API_KEY',
  appId: 'YOUR_NEW_IOS_APP_ID',
  messagingSenderId: 'YOUR_SENDER_ID',
  projectId: 'YOUR_NEW_PROJECT_ID',
  storageBucket: 'YOUR_PROJECT_ID.appspot.com',
  iosBundleId: 'YOUR_BUNDLE_ID',
);
```

3. Lưu file

### 5.3. Cập nhật firebase.json (nếu cần)

1. Mở file: `frontend/firebase.json`
2. Cập nhật `projectId` và `appId` mới
3. Hoặc chạy lệnh để regenerate:
```bash
cd frontend
flutterfire configure
```

### 5.4. Test Frontend
1. Chạy app:
```bash
cd frontend
flutter pub get
flutter run
```

2. Kiểm tra xem app có kết nối được với Firestore không

✅ **Checkpoint:** Frontend đã được cập nhật với Firebase mới

---

## 📋 BƯỚC 6: Test Tổng Thể

### 6.1. Test Backend
1. Truy cập: `https://your-backend-url.onrender.com/health`
2. Kiểm tra logs trên Render xem có lỗi không
3. Test API tạo order:
```bash
curl -X POST https://your-backend-url.onrender.com/api/orders \
  -H "Content-Type: application/json" \
  -d '{"customerName":"Test","customerEmail":"test@test.com","customerPhone":"123456789","items":[{"productName":"Test Product","quantity":1,"price":100}],"totalAmount":100}'
```

### 6.2. Test Frontend
1. Chạy app Flutter
2. Thử tạo order mới
3. Kiểm tra xem order có được lưu vào Firestore không
4. Kiểm tra xem order có hiển thị trong danh sách không

✅ **Checkpoint:** Hệ thống đã hoạt động với Firebase project mới

---

## ❓ Câu hỏi thường gặp

**Q: Service Account Key có format như thế nào?**
A: Là một JSON object, khi đặt vào environment variable phải là một dòng string. Có thể dùng tool online để minify JSON.

**Q: Làm sao biết đã cấu hình đúng?**
A: 
- Backend: Kiểm tra logs trên Render, không có lỗi "Firebase Admin initialization failed"
- Frontend: App chạy được và có thể đọc/ghi Firestore

**Q: Có cần cập nhật Firestore Security Rules không?**
A: Có, sau 30 ngày test mode sẽ hết hạn. Cần cấu hình rules phù hợp với app của bạn.

**Q: Dữ liệu cũ có còn không?**
A: Không, vì project đã bị xóa nên tất cả dữ liệu đã mất. Bạn cần tạo lại dữ liệu.

---

## ✅ Tổng kết

Sau khi hoàn thành các bước trên, bạn đã có:
- ✅ Firebase project mới
- ✅ Firestore Database đã được bật
- ✅ Backend đã được cấu hình với Service Account mới
- ✅ Frontend đã được cập nhật với credentials mới
- ✅ Hệ thống đã hoạt động bình thường

