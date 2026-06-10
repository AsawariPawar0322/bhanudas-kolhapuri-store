import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/order.dart';
import '../models/prediction.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class AppProvider extends ChangeNotifier {
  // Connection State
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  // Loading States
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Inventory State
  int _currentStock = 142;
  int get currentStock => _currentStock;

  // Data
  Prediction? _todayPrediction;
  Prediction? get todayPrediction => _todayPrediction;

  List<ForecastDay> _weeklyForecast = [];
  List<ForecastDay> get weeklyForecast => _weeklyForecast;

  List<Order> _orders = [];
  List<Order> get orders => _orders;

  List<Order> _offlineQueue = [];
  List<Order> get offlineQueue => _offlineQueue;

  List<ProductionRecommendation> _recommendations = [];
  List<ProductionRecommendation> get recommendations => _recommendations;

  ImpactStats? _impactStats;
  ImpactStats? get impactStats => _impactStats;

  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorage = LocalStorageService();

  AppProvider() {
    _init();
  }

  Future<void> _init() async {
    // Listen to connectivity changes
    Connectivity().onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
      if (_isOnline) {
        syncOfflineData();
      }
    });

    // Load initial data
    await loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try to load from API
      _todayPrediction = await _apiService.getTodayPrediction();
      _weeklyForecast = await _apiService.getWeeklyForecast();
      _orders = await _apiService.getOrders();
      _recommendations = await _apiService.getRecommendations();
      _impactStats = await _apiService.getImpactStats();

      // Cache locally for offline use
      await _localStorage.cacheData(_todayPrediction!, _weeklyForecast, _orders);
    } catch (e) {
      // Load from cache if API fails
      final cachedData = await _localStorage.getCachedData();
      if (cachedData != null) {
        _todayPrediction = cachedData['prediction'];
        _weeklyForecast = cachedData['forecast'];
        _orders = cachedData['orders'];
      }
    }

    // Load offline queue
    _offlineQueue = await _localStorage.getOfflineQueue();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createOrder(Order order) async {
    if (_isOnline) {
      try {
        final newOrder = await _apiService.createOrder(order);
        _orders.insert(0, newOrder);
      } catch (e) {
        // If API fails, add to offline queue
        order.synced = false;
        _offlineQueue.add(order);
        await _localStorage.addToOfflineQueue(order);
      }
    } else {
      // Add to offline queue
      order.synced = false;
      _offlineQueue.add(order);
      _orders.insert(0, order);
      await _localStorage.addToOfflineQueue(order);
    }
    notifyListeners();
  }

  Future<void> syncOfflineData() async {
    if (_offlineQueue.isEmpty || !_isOnline) return;

    try {
      final syncedCount = await _apiService.syncOrders(_offlineQueue);
      if (syncedCount > 0) {
        _offlineQueue.clear();
        await _localStorage.clearOfflineQueue();
        await loadData(); // Refresh data
      }
    } catch (e) {
      // Keep in queue if sync fails
    }
    notifyListeners();
  }

  void setOnlineStatus(bool status) {
    _isOnline = status;
    notifyListeners();
  }

  void addStock(int count) {
    _currentStock += count;
    notifyListeners();
  }

  Future<void> updateOrderStatus(String orderId, String status, {int? completionDays}) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_isOnline) {
        final updatedOrder = await _apiService.updateOrderStatus(orderId, status, completionDays: completionDays);
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index] = updatedOrder;
        }
      } else {
        // Offline-first updates
        final index = _orders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _orders[index].status = status;
          if (completionDays != null) {
            _orders[index].completionDays = completionDays;
          }
          _orders[index].synced = false;
        }
      }
      
      // Re-cache updated orders list
      if (_todayPrediction != null) {
        await _localStorage.cacheData(_todayPrediction!, _weeklyForecast, _orders);
      }
    } catch (e) {
      // Offline fallback on connection/API error
      final index = _orders.indexWhere((o) => o.id == orderId);
      if (index != -1) {
        _orders[index].status = status;
        if (completionDays != null) {
          _orders[index].completionDays = completionDays;
        }
        _orders[index].synced = false;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

// Models
class ForecastDay {
  final String date;
  final String day;
  final bool isToday;
  final int demand;
  final bool isPeak;

  ForecastDay({
    required this.date,
    required this.day,
    required this.isToday,
    required this.demand,
    required this.isPeak,
  });

  factory ForecastDay.fromJson(Map<String, dynamic> json) {
    return ForecastDay(
      date: json['date'],
      day: json['day'],
      isToday: json['is_today'] ?? false,
      demand: json['demand'],
      isPeak: json['is_peak'] ?? false,
    );
  }
}

class ProductionRecommendation {
  final String color;
  final String hex;
  final int quantity;
  final String priority;

  ProductionRecommendation({
    required this.color,
    required this.hex,
    required this.quantity,
    required this.priority,
  });

  factory ProductionRecommendation.fromJson(Map<String, dynamic> json) {
    return ProductionRecommendation(
      color: json['color'],
      hex: json['hex'],
      quantity: json['quantity'],
      priority: json['priority'],
    );
  }
}

class ImpactStats {
  final int wastePreventedKg;
  final int wasteReductionPercent;
  final int productionAccuracy;
  final int carbonSavedKg;
  final int incomeGrowthPercent;
  final int artisansConnected;

  ImpactStats({
    required this.wastePreventedKg,
    required this.wasteReductionPercent,
    required this.productionAccuracy,
    required this.carbonSavedKg,
    required this.incomeGrowthPercent,
    required this.artisansConnected,
  });

  factory ImpactStats.fromJson(Map<String, dynamic> json) {
    return ImpactStats(
      wastePreventedKg: json['waste_prevented_kg'],
      wasteReductionPercent: json['waste_reduction_percent'],
      productionAccuracy: json['production_accuracy'],
      carbonSavedKg: json['carbon_saved_kg'],
      incomeGrowthPercent: json['income_growth_percent'],
      artisansConnected: json['artisans_connected'],
    );
  }
}
