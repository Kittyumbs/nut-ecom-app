const express = require('express');
const { body, validationResult } = require('express-validator');
const { getFirestore, admin } = require('../config/firebase');

const router = express.Router();
const COLLECTION_NAME = 'orders';

// Validation middleware
const validateOrder = [
  body('customerName').notEmpty().withMessage('Customer name is required'),
  body('customerEmail').isEmail().withMessage('Valid email is required'),
  body('customerPhone').notEmpty().withMessage('Customer phone is required'),
  body('items').isArray({ min: 1 }).withMessage('At least one item is required'),
  body('items.*.productName').notEmpty().withMessage('Product name is required'),
  body('items.*.quantity').isInt({ min: 1 }).withMessage('Quantity must be at least 1'),
  body('items.*.price').isFloat({ min: 0 }).withMessage('Price must be a positive number'),
  body('totalAmount').isFloat({ min: 0 }).withMessage('Total amount must be a positive number'),
  body('status').optional().isIn(['pending', 'processing', 'completed', 'cancelled']).withMessage('Invalid status'),
];

// Helper function to handle validation errors
const handleValidationErrors = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    return res.status(400).json({ errors: errors.array() });
  }
  next();
};

// GET /api/orders - Get all orders
router.get('/', async (req, res, next) => {
  try {
    const db = getFirestore();
    const { status, limit = 100, offset = 0 } = req.query;

    let query = db.collection(COLLECTION_NAME).orderBy('createdAt', 'desc');

    if (status) {
      query = query.where('status', '==', status);
    }

    const snapshot = await query.limit(parseInt(limit)).offset(parseInt(offset)).get();
    const orders = snapshot.docs.map((doc) => ({
      id: doc.id,
      ...doc.data(),
    }));

    res.json({
      success: true,
      data: orders,
      count: orders.length,
    });
  } catch (error) {
    next(error);
  }
});

// GET /api/orders/:id - Get order by ID
router.get('/:id', async (req, res, next) => {
  try {
    const db = getFirestore();
    const doc = await db.collection(COLLECTION_NAME).doc(req.params.id).get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Order not found',
      });
    }

    res.json({
      success: true,
      data: {
        id: doc.id,
        ...doc.data(),
      },
    });
  } catch (error) {
    next(error);
  }
});

// POST /api/orders - Create new order
router.post('/', validateOrder, handleValidationErrors, async (req, res, next) => {
  try {
    const db = getFirestore();
    const orderData = {
      ...req.body,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: null,
    };

    const docRef = await db.collection(COLLECTION_NAME).add(orderData);

    res.status(201).json({
      success: true,
      message: 'Order created successfully',
      data: {
        id: docRef.id,
        ...orderData,
      },
    });
  } catch (error) {
    next(error);
  }
});

// PUT /api/orders/:id - Update order
router.put('/:id', validateOrder, handleValidationErrors, async (req, res, next) => {
  try {
    const db = getFirestore();
    const orderRef = db.collection(COLLECTION_NAME).doc(req.params.id);
    const doc = await orderRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Order not found',
      });
    }

    const updateData = {
      ...req.body,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    await orderRef.update(updateData);

    const updatedDoc = await orderRef.get();

    res.json({
      success: true,
      message: 'Order updated successfully',
      data: {
        id: updatedDoc.id,
        ...updatedDoc.data(),
      },
    });
  } catch (error) {
    next(error);
  }
});

// PATCH /api/orders/:id/status - Update order status only
router.patch('/:id/status', [
  body('status').isIn(['pending', 'processing', 'completed', 'cancelled']).withMessage('Invalid status'),
], handleValidationErrors, async (req, res, next) => {
  try {
    const db = getFirestore();
    const orderRef = db.collection(COLLECTION_NAME).doc(req.params.id);
    const doc = await orderRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Order not found',
      });
    }

    await orderRef.update({
      status: req.body.status,
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    const updatedDoc = await orderRef.get();

    res.json({
      success: true,
      message: 'Order status updated successfully',
      data: {
        id: updatedDoc.id,
        ...updatedDoc.data(),
      },
    });
  } catch (error) {
    next(error);
  }
});

// DELETE /api/orders/:id - Delete order
router.delete('/:id', async (req, res, next) => {
  try {
    const db = getFirestore();
    const orderRef = db.collection(COLLECTION_NAME).doc(req.params.id);
    const doc = await orderRef.get();

    if (!doc.exists) {
      return res.status(404).json({
        success: false,
        error: 'Order not found',
      });
    }

    await orderRef.delete();

    res.json({
      success: true,
      message: 'Order deleted successfully',
    });
  } catch (error) {
    next(error);
  }
});

module.exports = router;

