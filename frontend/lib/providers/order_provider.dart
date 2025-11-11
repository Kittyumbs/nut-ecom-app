import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/firestore_service.dart';

class OrderProvider with ChangeNotifier {
  final FirestoreService _firestoreService;
  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  OrderProvider() : _firestoreService = FirestoreService() {
    loadOrders();
  }

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _firestoreService.getOrders().listen((orders) {
        _orders = orders;
        _isLoading = false;
        _error = null;
        notifyListeners();
      });
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createOrder(Order order) async {
    try {
      await _firestoreService.createOrder(order);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrder(Order order) async {
    try {
      await _firestoreService.updateOrder(order.id, order);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteOrder(String id) async {
    try {
      await _firestoreService.deleteOrder(id);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateOrderStatus(String id, String status) async {
    try {
      await _firestoreService.updateOrderStatus(id, status);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}

