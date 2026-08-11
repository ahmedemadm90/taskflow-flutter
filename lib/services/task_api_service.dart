import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/task.model.dart';

class TaskApiService {
  TaskApiService({http.Client? client, this.baseUrl = 'http://10.0.2.2:8000/api/v1'})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;
  String? _token;

  void setToken(String token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Future<List<Task>> fetchTasks() async {
    final response = await _client.get(Uri.parse('$baseUrl/tasks'), headers: _headers);
    _ensureSuccess(response);
    final payload = jsonDecode(response.body) as Map<String, dynamic>;
    final data = (payload['data'] as List<dynamic>? ?? payload['tasks'] as List<dynamic>? ?? []);
    return data.map((item) => Task.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<Task> createTask(Task task) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/tasks'),
      headers: _headers,
      body: jsonEncode(task.toJson()),
    );
    _ensureSuccess(response);
    return Task.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<void> deleteTask(String id) async {
    final response = await _client.delete(Uri.parse('$baseUrl/tasks/$id'), headers: _headers);
    _ensureSuccess(response);
  }

  void _ensureSuccess(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw TaskApiException('API request failed (${response.statusCode})');
    }
  }
}

class TaskApiException implements Exception {
  const TaskApiException(this.message);
  final String message;

  @override
  String toString() => message;
}
