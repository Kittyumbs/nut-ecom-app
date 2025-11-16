const express = require('express');
const multer = require('multer');
const { uploadFile, findOrCreateFolder } = require('../config/google_drive');

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

/**
 * POST /api/upload/transaction-image
 * Upload ảnh transaction lên Google Drive trong folder "transactions"
 * Tên file: /transactions/161125 [dd/mm/yy]/hình_n +1
 */
router.post('/transaction-image', upload.single('image'), async (req, res) => {
  console.log('=== TRANSACTION IMAGE UPLOAD REQUEST ===');
  console.log('Method:', req.method);
  console.log('URL:', req.url);
  console.log('Body:', req.body);
  console.log('File:', req.file ? 'Present' : 'Missing');
  console.log('Content-Type:', req.headers['content-type']);
  
  try {
    if (!req.file) {
      console.log('ERROR: No file in request');
      return res.status(400).json({
        error: {
          message: 'Không có file được upload',
          status: 400,
        },
      });
    }

    // Lấy thông tin file
    const fileBuffer = req.file.buffer;
    const mimeType = req.file.mimetype;
    
    // Lấy thông tin từ query params hoặc body
    const dateStr = req.body.date || req.query.date; // Format: "161125" (dd/mm/yy)
    const imageNumber = req.body.imageNumber || req.query.imageNumber || '1'; // Số thứ tự ảnh

    // Tạo tên file theo format: /transactions/161125 [dd/mm/yy]/hình_n +1
    // Ví dụ: /transactions/161125/hình_1.jpg
    const now = new Date();
    const day = String(now.getDate()).padStart(2, '0');
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const year = String(now.getFullYear()).slice(-2);
    const dateFolder = dateStr || `${day}${month}${year}`; // Format: 161125
    
    // Tạo folder path: transactions/161125
    const folderPath = `transactions/${dateFolder}`;
    
    // Tìm hoặc tạo folder "transactions" (ở root)
    const transactionsFolderId = await findOrCreateFolder('transactions');
    
    // Tìm hoặc tạo subfolder theo ngày (161125) bên trong folder "transactions"
    const dateFolderId = await findOrCreateFolder(dateFolder, transactionsFolderId);
    
    // Tạo tên file: hình_n.jpg (n là số thứ tự)
    const fileExtension = mimeType.split('/')[1] || 'jpg';
    const fileName = `hình_${imageNumber}.${fileExtension}`;

    // Upload file vào folder ngày
    const imageUrl = await uploadFile(fileBuffer, fileName, mimeType, dateFolderId);

    res.json({
      success: true,
      imageUrl: imageUrl,
      fileName: `${folderPath}/${fileName}`,
      message: 'Upload ảnh transaction thành công',
    });
  } catch (error) {
    console.error('Error in transaction-image upload route:', error);
    res.status(500).json({
      error: {
        message: error.message || 'Lỗi upload ảnh transaction',
        status: 500,
      },
    });
  }
});

module.exports = router;

