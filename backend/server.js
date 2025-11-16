const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
require('dotenv').config();

const orderRoutes = require('./routes/orders');
const uploadRoutes = require('./routes/upload');
const { initializeFirebase } = require('./config/firebase');
const { initializeDrive } = require('./config/google_drive');

const app = express();
const PORT = process.env.PORT || 3000;

// Initialize Firebase Admin
initializeFirebase();

// Initialize Google Drive
initializeDrive();

// Middleware
app.use(helmet());
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok', message: 'Server is running' });
});

// API Routes
app.use('/api/orders', orderRoutes);
app.use('/api/upload', uploadRoutes);

// Debug: Log all routes
console.log('Registered routes:');
console.log('  - /api/orders');
console.log('  - /api/upload/image');
console.log('  - /api/upload/transaction-image');

// Error handling middleware
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(err.status || 500).json({
    error: {
      message: err.message || 'Internal Server Error',
      status: err.status || 500,
    },
  });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    error: {
      message: 'Route not found',
      status: 404,
    },
  });
});

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`);
});

module.exports = app;

