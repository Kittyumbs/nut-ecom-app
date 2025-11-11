import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order.dart' as models;

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'orders';

  // Create order
  Future<String> createOrder(models.Order order) async {
    try {
      final docRef = await _firestore.collection(_collectionName).add(order.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Get all orders
  Stream<List<models.Order>> getOrders() {
    return _firestore
        .collection(_collectionName)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return models.Order.fromJson(data);
      }).toList();
    });
  }

  // Get order by ID
  Future<models.Order?> getOrderById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return models.Order.fromJson(data);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting order: $e');
    }
  }

  // Update order
  Future<void> updateOrder(String id, models.Order order) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        ...order.toJson(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating order: $e');
    }
  }

  // Delete order
  Future<void> deleteOrder(String id) async {
    try {
      await _firestore.collection(_collectionName).doc(id).delete();
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

  // Update order status
  Future<void> updateOrderStatus(String id, String status) async {
    try {
      await _firestore.collection(_collectionName).doc(id).update({
        'status': status,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Get orders by status
  Stream<List<models.Order>> getOrdersByStatus(String status) {
    return _firestore
        .collection(_collectionName)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return models.Order.fromJson(data);
      }).toList();
    });
  }
}

