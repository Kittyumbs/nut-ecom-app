const admin = require('firebase-admin');

let firestore;

const initializeFirebase = () => {
  try {
    // For Render deployment, use service account from environment variable
    if (process.env.FIREBASE_SERVICE_ACCOUNT_KEY) {
      const serviceAccount = JSON.parse(process.env.FIREBASE_SERVICE_ACCOUNT_KEY);
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      firestore = admin.firestore();
      console.log('Firebase Admin initialized successfully with service account from environment');
      return;
    }
    
    if (process.env.FIREBASE_PROJECT_ID) {
      // Alternative: Initialize with project ID (for local development with emulator)
      admin.initializeApp({
        projectId: process.env.FIREBASE_PROJECT_ID,
      });
      firestore = admin.firestore();
      console.log('Firebase Admin initialized successfully with project ID');
      return;
    }
    
    // For local development, try to use a service account file
    // Make sure to add serviceAccountKey.json to .gitignore
    try {
      const serviceAccount = require('../serviceAccountKey.json');
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount),
      });
      firestore = admin.firestore();
      console.log('Firebase Admin initialized successfully with service account file');
      return;
    } catch (fileError) {
      // File not found or invalid - this is OK for production if using env vars
      if (fileError.code === 'MODULE_NOT_FOUND') {
        console.warn('⚠️  Firebase credentials not found. Firebase features will be disabled.');
        console.warn('   To enable Firebase, set FIREBASE_SERVICE_ACCOUNT_KEY or FIREBASE_PROJECT_ID environment variable.');
        console.warn('   Or add serviceAccountKey.json file for local development.');
        // Don't throw error - allow server to start without Firebase
        return;
      }
      throw fileError;
    }
  } catch (error) {
    console.error('Error initializing Firebase Admin:', error);
    // Only throw if it's a critical error (not just missing credentials)
    if (error.code !== 'MODULE_NOT_FOUND') {
      throw error;
    }
    console.warn('⚠️  Firebase initialization failed. Server will continue without Firebase features.');
  }
};

const getFirestore = () => {
  if (!firestore) {
    throw new Error('Firestore not initialized. Please set FIREBASE_SERVICE_ACCOUNT_KEY or FIREBASE_PROJECT_ID environment variable, or add serviceAccountKey.json file for local development.');
  }
  return firestore;
};

module.exports = {
  initializeFirebase,
  getFirestore,
  admin,
};

