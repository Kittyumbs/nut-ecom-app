# Nut E-Commerce Order Management - Backend API

## Mô tả
Backend API sử dụng Node.js/Express để quản lý đơn hàng, kết nối với Firestore database. Được thiết kế để deploy trên Render.

## Yêu cầu
- Node.js >= 18.0.0
- npm hoặc yarn
- Firebase project với Firestore enabled

## Cài đặt

1. Cài đặt dependencies:
```bash
npm install
```

2. Cấu hình environment variables:
   - Copy file `.env.example` thành `.env`
   - Cập nhật các giá trị trong `.env`:
     - **Firebase (chọn một trong hai):**
       - `FIREBASE_SERVICE_ACCOUNT_KEY`: JSON string của service account key từ Firebase (khuyến nghị cho production)
       - Hoặc `FIREBASE_PROJECT_ID`: Project ID cho local development với emulator
     - **Google Drive (tùy chọn - cho upload ảnh):**
       - `GOOGLE_CLIENT_ID`: OAuth2 Client ID từ Google Cloud Console
       - `GOOGLE_CLIENT_SECRET`: OAuth2 Client Secret
       - `GOOGLE_REFRESH_TOKEN`: OAuth2 Refresh Token
     - **Server:**
       - `PORT`: Port để chạy server (mặc định: 3000)

3. Lấy Firebase Service Account Key:
   - Vào Firebase Console > Project Settings > Service Accounts
   - Click "Generate new private key"
   - Copy nội dung JSON và đặt vào biến môi trường `FIREBASE_SERVICE_ACCOUNT_KEY` (cho Render)
   - Hoặc lưu file vào `serviceAccountKey.json` (cho local development)

4. Chạy server:
```bash
# Development mode (với nodemon)
npm run dev

# Production mode
npm start
```

## API Endpoints

### Health Check
- `GET /health` - Kiểm tra trạng thái server

### Orders
- `GET /api/orders` - Lấy danh sách đơn hàng
  - Query params: `status`, `limit`, `offset`
- `GET /api/orders/:id` - Lấy chi tiết đơn hàng
- `POST /api/orders` - Tạo đơn hàng mới
- `PUT /api/orders/:id` - Cập nhật đơn hàng
- `PATCH /api/orders/:id/status` - Cập nhật trạng thái đơn hàng
- `DELETE /api/orders/:id` - Xóa đơn hàng

## Deploy lên Render

1. Tạo Web Service mới trên Render
2. Kết nối repository GitHub/GitLab
3. Cấu hình:
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Environment Variables** (trong Render Dashboard > Environment):
     - `PORT`: Render tự động set (không cần set thủ công)
     - `FIREBASE_SERVICE_ACCOUNT_KEY`: JSON string của service account key (bắt buộc nếu dùng Firebase)
     - `GOOGLE_CLIENT_ID`: OAuth2 Client ID (bắt buộc nếu dùng upload ảnh)
     - `GOOGLE_CLIENT_SECRET`: OAuth2 Client Secret (bắt buộc nếu dùng upload ảnh)
     - `GOOGLE_REFRESH_TOKEN`: OAuth2 Refresh Token (bắt buộc nếu dùng upload ảnh)
     
   **Lưu ý:** Server sẽ vẫn chạy được nếu thiếu Firebase hoặc Google Drive credentials, nhưng các tính năng tương ứng sẽ không hoạt động.
4. Deploy

## Cấu trúc thư mục

```
backend/
├── config/
│   └── firebase.js        # Firebase configuration
├── routes/
│   └── orders.js          # Order routes
├── server.js              # Express server
├── package.json
├── .env.example
└── README.md
```

## Order Model

```json
{
  "id": "string",
  "customerName": "string",
  "customerEmail": "string",
  "customerPhone": "string",
  "items": [
    {
      "productId": "string",
      "productName": "string",
      "quantity": "number",
      "price": "number",
      "subtotal": "number"
    }
  ],
  "totalAmount": "number",
  "status": "pending|processing|completed|cancelled",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "notes": "string (optional)"
}
```

