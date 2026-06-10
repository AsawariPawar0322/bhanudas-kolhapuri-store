import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order.dart';
import '../models/prediction.dart';
import '../providers/app_provider.dart';

class LocalStorageService {
  static const String _predictionKey = 'cached_prediction';
  static const String _forecastKey = 'cached_forecast';
  static const String _ordersKey = 'cached_orders';
  static const String _offlineQueueKey = 'offline_queue';
  static const String _lastSyncKey = 'last_sync';

  // Cache data for offline use
  Future<void> cacheData(
    Prediction prediction,
    List<ForecastDay> forecast,
    List<Order> orders,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Note: In production, you would serialize these properly
    await prefs.setString(_ordersKey, json.encode(
      orders.map((e) => e.toJson()).toList()
    ));
    
    await prefs.setString(_lastSyncKey, DateTime.now().toIso8601String());
  }

  // Get cached data
  Future<Map<String, dynamic>?> getCachedData() async {
    final prefs = await SharedPreferences.getInstance();
    
    final ordersJson = prefs.getString(_ordersKey);
    
    if (ordersJson != null) {
      final ordersList = (json.decode(ordersJson) as List)
          .map((e) => Order.fromJson(e))
          .toList();
      
      return {
        'orders': ordersList,
        // Add prediction and forecast parsing as needed
      };
    }
    
    return null;
  }

  // Offline Queue Management
  Future<void> addToOfflineQueue(Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_offlineQueueKey);
    
    List<Map<String, dynamic>> queue = [];
    if (queueJson != null) {
      queue = List<Map<String, dynamic>>.from(json.decode(queueJson));
    }
    
    queue.add(order.toJson());
    await prefs.setString(_offlineQueueKey, json.encode(queue));
  }

  Future<List<Order>> getOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_offlineQueueKey);
    
    if (queueJson != null) {
      final List<dynamic> queue = json.decode(queueJson);
      return queue.map((e) => Order.fromJson(e)).toList();
    }
    
    return [];
  }

  Future<void> clearOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineQueueKey);
  }

  // Get last sync time
  Future<DateTime?> getLastSyncTime() async {
    final prefs = await SharedPreferences.getInstance();
    final syncTime = prefs.getString(_lastSyncKey);
    
    if (syncTime != null) {
      return DateTime.parse(syncTime);
    }
    
    return null;
  }
}
