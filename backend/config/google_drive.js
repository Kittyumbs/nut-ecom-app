const { google } = require('googleapis');
const { Readable } = require('stream');

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
 * Tìm hoặc tạo folder trên Google Drive
 * @param {String} folderName - Tên folder
 * @param {String} parentFolderId - ID của folder cha (tùy chọn)
 * @returns {Promise<String>} - ID của folder
 */
const findOrCreateFolder = async (folderName, parentFolderId = null) => {
  const drive = getDriveClient();
  
  if (!drive) {
    throw new Error('Google Drive client chưa được khởi tạo. Vui lòng cấu hình credentials.');
  }

  try {
    // Tìm folder đã tồn tại
    let query = `mimeType='application/vnd.google-apps.folder' and name='${folderName}' and trashed=false`;
    if (parentFolderId) {
      query += ` and '${parentFolderId}' in parents`;
    }
    
    const response = await drive.files.list({
      q: query,
      fields: 'files(id, name)',
    });

    if (response.data.files && response.data.files.length > 0) {
      // Folder đã tồn tại, trả về ID
      return response.data.files[0].id;
    }

    // Folder chưa tồn tại, tạo mới
    const folderMetadata = {
      name: folderName,
      mimeType: 'application/vnd.google-apps.folder',
    };

    // Nếu có parentFolderId, thêm vào parents
    if (parentFolderId) {
      folderMetadata.parents = [parentFolderId];
    }

    const folder = await drive.files.create({
      requestBody: folderMetadata,
      fields: 'id',
    });

    if (!folder.data.id) {
      throw new Error('Không tạo được folder trên Drive');
    }

    // Set quyền public cho folder
    await drive.permissions.create({
      fileId: folder.data.id,
      requestBody: {
        role: 'reader',
        type: 'anyone',
      },
    });

    return folder.data.id;
  } catch (error) {
    console.error('Error finding/creating folder:', error);
    throw new Error(`Lỗi tìm/tạo folder: ${error.message}`);
  }
};

/**
 * Upload file lên Google Drive và set quyền public
 * @param {Buffer} fileBuffer - Buffer của file
 * @param {String} fileName - Tên file
 * @param {String} mimeType - MIME type (VD: 'image/jpeg')
 * @param {String} folderId - ID của folder (tùy chọn)
 * @returns {Promise<String>} - URL công khai của file
 */
const uploadFile = async (fileBuffer, fileName, mimeType, folderId = null) => {
  const drive = getDriveClient();
  
  if (!drive) {
    throw new Error('Google Drive client chưa được khởi tạo. Vui lòng cấu hình credentials.');
  }

  try {
    // Convert Buffer thành Stream (Google APIs yêu cầu Stream)
    const stream = Readable.from(fileBuffer);
    
    // Upload file
    const fileMetadata = {
      name: fileName,
      mimeType: mimeType,
    };

    // Nếu có folderId, thêm vào parents
    if (folderId) {
      fileMetadata.parents = [folderId];
    }

    const media = {
      mimeType: mimeType,
      body: stream,
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
  findOrCreateFolder,
};

