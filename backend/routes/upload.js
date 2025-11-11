const express = require('express');
const multer = require('multer');
const { uploadFile } = require('../config/google_drive');

const router = express.Router();

// Cấu hình multer để lưu file vào memory
const upload = multer({
  storage: multer.memoryStorage(),
  limits: {
    fileSize: 10 * 1024 * 1024, // 10MB
  },
  fileFilter: (req, file, cb) => {
    // Chỉ cho phép upload ảnh
    if (file.mimetype.startsWith('image/')) {
      cb(null, true);
    } else {
      cb(new Error('Chỉ cho phép upload file ảnh'), false);
    }
  },
});

/**
 * POST /api/upload/image
 * Upload ảnh lên Google Drive và trả về URL công khai
 */
router.post('/image', upload.single('image'), async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        error: {
          message: 'Không có file được upload',
          status: 400,
        },
      });
    }

    // Lấy thông tin file
    const fileBuffer = req.file.buffer;
    const originalName = req.file.originalname;
    const mimeType = req.file.mimetype;

    // Tạo tên file unique
    const timestamp = Date.now();
    const fileName = `product_${timestamp}_${originalName}`;

    // Upload lên Drive
    const imageUrl = await uploadFile(fileBuffer, fileName, mimeType);

    res.json({
      success: true,
      imageUrl: imageUrl,
      message: 'Upload ảnh thành công',
    });
  } catch (error) {
    console.error('Error in upload route:', error);
    res.status(500).json({
      error: {
        message: error.message || 'Lỗi upload ảnh',
        status: 500,
      },
    });
  }
});

module.exports = router;

