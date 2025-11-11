const { google } = require('googleapis');

let driveClient = null;

/**
 * Khởi tạo Google Drive client với OAuth2
 * Cần có: GOOGLE_CLIENT_ID, GOOGLE_CLIENT_SECRET, GOOGLE_REFRESH_TOKEN
 */
const initializeDrive = () => {
  try {
    const clientId = process.env.GOOGLE_CLIENT_ID;
    const clientSecret = process.env.GOOGLE_CLIENT_SECRET;
    const refreshToken = process.env.GOOGLE_REFRESH_TOKEN;

    if (!clientId || !clientSecret || !refreshToken) {
      console.warn('Google Drive credentials chưa được cấu hình. Upload ảnh sẽ không hoạt động.');
      return null;
    }

    const { OAuth2Client } = require('google-auth-library');
    const oauth2Client = new OAuth2Client(
      clientId,
      clientSecret,
      'urn:ietf:wg:oauth:2.0:oob' // Redirect URI (không dùng cho server-side)
    );

    oauth2Client.setCredentials({
      refresh_token: refreshToken,
    });

    driveClient = google.drive({
      version: 'v3',
      auth: oauth2Client,
    });

    console.log('Google Drive client initialized successfully');
    return driveClient;
  } catch (error) {
    console.error('Error initializing Google Drive:', error);
    return null;
  }
};

/**
 * Lấy Drive client (khởi tạo nếu chưa có)
 */
const getDriveClient = () => {
  if (!driveClient) {
    return initializeDrive();
  }
  return driveClient;
};

/**
 * Upload file lên Google Drive và set quyền public
 * @param {Buffer} fileBuffer - Buffer của file
 * @param {String} fileName - Tên file
 * @param {String} mimeType - MIME type (VD: 'image/jpeg')
 * @returns {Promise<String>} - URL công khai của file
 */
const uploadFile = async (fileBuffer, fileName, mimeType) => {
  const drive = getDriveClient();
  
  if (!drive) {
    throw new Error('Google Drive client chưa được khởi tạo. Vui lòng cấu hình credentials.');
  }

  try {
    // Upload file
    const fileMetadata = {
      name: fileName,
      mimeType: mimeType,
    };

    const media = {
      mimeType: mimeType,
      body: fileBuffer,
    };

    const response = await drive.files.create({
      requestBody: fileMetadata,
      media: media,
      fields: 'id,webViewLink,webContentLink',
    });

    const fileId = response.data.id;

    if (!fileId) {
      throw new Error('Không tạo được file trên Drive');
    }

    // Set quyền public (anyone can view)
    await drive.permissions.create({
      fileId: fileId,
      requestBody: {
        role: 'reader',
        type: 'anyone',
      },
    });

    // Trả về URL công khai để hiển thị ảnh trực tiếp
    // Format: https://drive.google.com/uc?export=view&id=FILE_ID
    return `https://drive.google.com/uc?export=view&id=${fileId}`;
  } catch (error) {
    console.error('Error uploading file to Drive:', error);
    throw new Error(`Lỗi upload file lên Drive: ${error.message}`);
  }
};

module.exports = {
  initializeDrive,
  getDriveClient,
  uploadFile,
};

