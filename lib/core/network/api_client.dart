import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}

class ApiClient {
  String baseUrl;
  String? authToken;

  ApiClient({required this.baseUrl, this.authToken});

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (authToken != null && authToken!.isNotEmpty) 'Authorization': 'Bearer $authToken',
      };

  Future<dynamic> get(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.get(uri, headers: _headers).timeout(
            const Duration(seconds: 15),
          );
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error on GET $endpoint: $e');
    }
  }

  Future<dynamic> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .post(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error on POST $endpoint: $e');
    }
  }

  Future<dynamic> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http
          .put(
            uri,
            headers: _headers,
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(const Duration(seconds: 15));
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error on PUT $endpoint: $e');
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final response = await http.delete(uri, headers: _headers).timeout(
            const Duration(seconds: 15),
          );
      return _processResponse(response);
    } catch (e) {
      throw ApiException('Network error on DELETE $endpoint: $e');
    }
  }

  Future<String> uploadImageBytes({
    required List<int> bytes,
    required String filename,
    String folder = 'images',
  }) async {
    const endpoint = '/api/upload';
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      if (authToken != null && authToken!.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $authToken';
      }
      request.fields['folder'] = folder;

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamedResponse = await request.send().timeout(const Duration(seconds: 30));
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          final url = decoded['url'] ??
              decoded['imageUrl'] ??
              decoded['fileUrl'] ??
              decoded['location'] ??
              decoded['path'] ??
              (decoded['data'] is Map
                  ? (decoded['data']['url'] ?? decoded['data']['imageUrl'] ?? decoded['data']['fileUrl'])
                  : null);
          if (url != null && url.toString().isNotEmpty) {
            return url.toString();
          }
        }
      }
      throw ApiException('Upload failed — server returned ${response.statusCode}: ${response.body}');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Failed upload to $endpoint: $e');
    }
  }

  dynamic _processResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      try {
        return jsonDecode(response.body);
      } catch (e) {
        return response.body;
      }
    } else {
      String errorMessage = 'Server returned code ${response.statusCode}';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map && decoded.containsKey('message')) {
          errorMessage = decoded['message'];
        } else if (decoded is Map && decoded.containsKey('error')) {
          errorMessage = decoded['error'];
        }
      } catch (_) {}
      throw ApiException(errorMessage, statusCode: response.statusCode);
    }
  }
}

