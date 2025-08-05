import 'dart:math';
import 'package:dio/dio.dart';
import '../../../core/constants/app_constants.dart';
import '../../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> searchProducts(String query, String token, String companyId);
  Future<ProductModel> createProduct(ProductModel product, String token, String companyId);
  Future<List<ProductModel>> getProducts(String token, String companyId);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final Dio dio;

  ProductRemoteDataSourceImpl(this.dio);

  @override
  Future<List<ProductModel>> searchProducts(String query, String token, String companyId) async {
    try {
      print('DEBUG: Searching products with query: $query, companyId: $companyId');
      print('DEBUG: Token: ${token.isNotEmpty ? 'Present' : 'Missing'}');
      print('DEBUG: Token length: ${token.length}');
      print('DEBUG: Token starts with: ${token.isNotEmpty ? token.substring(0, min(20, token.length)) : 'N/A'}');
      
      // Check if we have valid parameters
      if (query.isEmpty || companyId.isEmpty) {
        print('DEBUG: Invalid parameters - query: "$query", companyId: "$companyId"');
        throw Exception('Query and companyId are required');
      }
      
      // Use the correct parameter name as per the original working code
      String url;
      if (companyId.isNotEmpty) {
        url = 'http://196.190.251.122:8086/api/Products/search/invoice-items?searchTerm=${Uri.encodeComponent(query)}&companyId=${Uri.encodeComponent(companyId)}';
      } else {
        url = 'http://196.190.251.122:8086/api/Products/search/invoice-items?searchTerm=${Uri.encodeComponent(query)}';
      }
      print('DEBUG: Full URL: $url');
      
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      print('DEBUG: HTTP Request: GET $url');
      print('DEBUG: Request Headers: ${response.requestOptions.headers}');
      print('DEBUG: Request Data: ${response.requestOptions.data}');
      print('DEBUG: HTTP Response: ${response.statusCode}');
      print('DEBUG: Response Data: ${response.data}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          print('DEBUG: Found ${data.length} products in response');
          
          if (data.isEmpty) {
            print('DEBUG: No products found for query: "$query"');
            print('DEBUG: This might indicate:');
            print('DEBUG: 1. No products exist in the database');
            print('DEBUG: 2. Search query format is incorrect');
            print('DEBUG: 3. Company ID is incorrect');
            print('DEBUG: 4. API endpoint is not working as expected');
            
            // Return empty list instead of mock data
            print('DEBUG: Returning empty list - no products found');
            return [];
          }
          
          return data.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          print('DEBUG: Invalid response structure: ${responseData}');
          throw Exception(responseData['message'] ?? 'Invalid response structure from API');
        }
      } else {
        print('DEBUG: HTTP error: ${response.statusCode}');
        print('DEBUG: Error Response: ${response.data}');
        
        // Handle specific error cases
        if (response.statusCode == 400) {
          final errorData = response.data;
          if (errorData is Map && errorData['message'] != null) {
            throw Exception(errorData['message']);
          }
        }
        
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Product search error: $e');
      // Re-throw the error instead of returning mock data
      print('DEBUG: Re-throwing API error');
      rethrow;
    }
  }

  // Mock data for testing - similar to your original working code
  List<ProductModel> _getMockProducts(String query) {
    final mockProducts = [
      ProductModel(
        id: '1',
        name: 'Test Product 1',
        description: 'This is a test product for debugging',
        price: 99.99,
        stock: 100,
        category: 'Test Category',
        image: 'https://via.placeholder.com/150',
        barcode: 'TEST123456',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: '2',
        name: 'Sample Item',
        description: 'A sample product for testing',
        price: 49.99,
        stock: 50,
        category: 'Sample Category',
        image: 'https://via.placeholder.com/150',
        barcode: 'SAMPLE789',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: '3',
        name: 'Debug Product',
        description: 'Product for debugging purposes',
        price: 29.99,
        stock: 25,
        category: 'Debug Category',
        image: 'https://via.placeholder.com/150',
        barcode: 'DEBUG456',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: '4',
        name: 'Coffee Beans',
        description: 'Premium coffee beans for brewing',
        price: 15.99,
        stock: 200,
        category: 'Beverages',
        image: 'https://via.placeholder.com/150',
        barcode: 'COFFEE001',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ProductModel(
        id: '5',
        name: 'Tea Leaves',
        description: 'Organic tea leaves',
        price: 12.50,
        stock: 150,
        category: 'Beverages',
        image: 'https://via.placeholder.com/150',
        barcode: 'TEA002',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
    
    // Filter mock products based on query
    return mockProducts.where((product) => 
      product.name.toLowerCase().contains(query.toLowerCase()) ||
      product.description.toLowerCase().contains(query.toLowerCase()) ||
      product.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  @override
  Future<ProductModel> createProduct(ProductModel product, String token, String companyId) async {
    try {
      final url = 'http://196.190.251.122:8086/api/Products';
      
      final response = await dio.post(
        url,
        data: product.toJson(),
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] != null) {
          return ProductModel.fromJson(responseData['data']);
        } else {
          throw Exception(responseData['message'] ?? 'Invalid response structure from API');
        }
      } else {
        throw Exception('Failed to create product. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Product creation failed: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProducts(String token, String companyId) async {
    try {
      final url = 'http://196.190.251.122:8086/api/Products?company_id=${Uri.encodeComponent(companyId)}';
      
      final response = await dio.get(
        url,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = response.data;
        
        if (responseData['success'] == true && responseData['data'] is List) {
          final List<dynamic> data = responseData['data'];
          return data.map((json) => ProductModel.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Invalid response structure from API');
        }
      } else {
        throw Exception('Failed to load products. Status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Get products failed: $e');
    }
  }
} 