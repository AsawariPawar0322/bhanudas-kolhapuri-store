import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/product.dart';

class ApiService {
  final String baseUrl = 'http://localhost:8000/api';

  // PRODUCTS
  Future<List<Product>> getProducts({String? category}) async {
    try {
      final url = category != null ? '$baseUrl/products?category=$category' : '$baseUrl/products';
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Product.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error: $e');
      return [];
    }
  }

  // Get all orders
  Future<List<dynamic>> getOrders() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/orders'));
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, String status) async {
    try {
      final response = await http.put(Uri.parse('$baseUrl/orders/$orderId?status=$status'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Create new order
  Future<bool> createOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(orderData),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // Simple login
  Future<Map<String, dynamic>?> login(String username, String role) async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/login?username=$username&role=$role'));
      if (response.statusCode == 200) return json.decode(response.body);
      return null;
    } catch (e) {
      return null;
    }
  }
}
