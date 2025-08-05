import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';

abstract class CartRemoteDataSource {
  Future<List<ProductModel>> searchProducts(String query, String token, String companyId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final http.Client client;

  CartRemoteDataSourceImpl({required this.client});

  @override
  Future<List<ProductModel>> searchProducts(String query, String token, String companyId) async {
    try {
      final url = Uri.parse('http://196.190.251.122:8086/api/Products/search/invoice-items?searchTerm=$query&companyId=$companyId');
      
      debugPrint("CartRemoteDataSource: Calling URL: $url");

      final response = await client.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          
          return data.map((product) => ProductModel.fromJson(product)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Invalid response structure from API');
        }
      } else {
        debugPrint("CartRemoteDataSource: API Error ${response.statusCode} - ${response.body}");
        throw Exception('Failed to load products from API. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }
} 