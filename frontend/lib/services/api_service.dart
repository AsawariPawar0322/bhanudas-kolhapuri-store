import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';
import '../models/prediction.dart';
import '../providers/app_provider.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://localhost:8000';
  
  // Headers
  Map<String, String> get headers => {
    'Content-Type': 'application/json',
  };

  // GET Today's Prediction
  Future<Prediction> getTodayPrediction() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/predictions/today'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return Prediction.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load prediction');
    }
  }

  // GET Weekly Forecast
  Future<List<ForecastDay>> getWeeklyForecast() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/predictions/weekly'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['forecast'] as List)
          .map((e) => ForecastDay.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load forecast');
    }
  }

  // GET Production Recommendations
  Future<List<ProductionRecommendation>> getRecommendations() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/predictions/recommendations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['recommendations'] as List)
          .map((e) => ProductionRecommendation.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load recommendations');
    }
  }

  // GET Orders
  Future<List<Order>> getOrders({String? status}) async {
    String url = '$baseUrl/api/orders';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load orders');
    }
  }

  // POST Create Order
  Future<Order> createOrder(Order order) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/orders'),
      headers: headers,
      body: json.encode(order.toJson()),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Order.fromJson(data['order']);
    } else {
      throw Exception('Failed to create order');
    }
  }

  // POST Sync Offline Orders
  Future<int> syncOrders(List<Order> orders) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/sync'),
      headers: headers,
      body: json.encode({
        'orders': orders.map((e) => e.toJson()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['synced_count'];
    } else {
      throw Exception('Failed to sync orders');
    }
  }

  // GET Impact Stats
  Future<ImpactStats> getImpactStats() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/impact'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return ImpactStats.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load impact stats');
    }
  }

  // GET Upcoming Festivals
  Future<List<Map<String, dynamic>>> getUpcomingFestivals() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/festivals/upcoming'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return List<Map<String, dynamic>>.from(json.decode(response.body));
    } else {
      throw Exception('Failed to load festivals');
    }
  }

  // PUT Update Order Status (Query Parameters)
  Future<Order> updateOrderStatus(String orderId, String status, {int? completionDays}) async {
    String url = '$baseUrl/api/orders/$orderId?status=$status';
    if (completionDays != null) {
      url += '&completion_days=$completionDays';
    }

    final response = await http.put(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Order.fromJson(data['order']);
    } else {
      throw Exception('Failed to update order status');
    }
  }
}

