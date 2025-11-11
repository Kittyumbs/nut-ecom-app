# Nut E-Commerce Order Management App

Ứng dụng quản lý đơn hàng nội bộ với Flutter frontend, Node.js/Express backend, và Firestore database.

## Cấu trúc dự án

```
nut_ecom_app/
├── frontend/          # Flutter application
│   ├── lib/
│   │   ├── models/       # Data models
│   │   ├── services/     # Firestore service
│   │   ├── providers/    # State management
│   │   └── screens/      # UI screens
│   └── pubspec.yaml
│
├── backend/           # Node.js/Express API
│   ├── config/        # Firebase config
│   ├── routes/        # API routes
│   └── server.js
│
└── README.md
```

## Công nghệ sử dụng

- **Frontend**: Flutter 3.0+
- **Backend**: Node.js/Express (deploy trên Render)
- **Database**: Firestore (Firebase)

## Tính năng

- ✅ Quản lý đơn hàng (CRUD)
- ✅ Real-time updates từ Firestore
- ✅ Quản lý trạng thái đơn hàng
- ✅ RESTful API backend
- ✅ Responsive UI

## Bắt đầu

### 1. Setup Firebase

1. Tạo project mới trên [Firebase Console](https://console.firebase.google.com/)
2. Bật Firestore Database
3. Tạo Service Account và lấy private key

### 2. Setup Backend

Xem hướng dẫn chi tiết trong [backend/README.md](./backend/README.md)

### 3. Setup Frontend

Xem hướng dẫn chi tiết trong [frontend/README.md](./frontend/README.md)

## Development

### Backend
```bash
cd backend
npm install
npm run dev
```

### Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## Deploy

### Backend (Render)
1. Push code lên GitHub/GitLab
2. Tạo Web Service trên Render
3. Cấu hình environment variables
4. Deploy

### Frontend
- Build APK/IPA cho mobile
- Hoặc build web app

## License

ISC

