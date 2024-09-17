// lib/services/user_service.dart
import 'package:dio/dio.dart';

class UserService {
  final Dio _dio = Dio();
  final String _baseUrl = "https://reqres.in/api";

  Future<Map<String, dynamic>> fetchUsers(int page) async {
    final response =
        await _dio.get('$_baseUrl/users', queryParameters: {'page': page});
    return response.data;
  }
}
