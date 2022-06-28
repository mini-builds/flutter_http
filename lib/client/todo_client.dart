import 'dart:convert';

import 'package:flutter_http/client/model.dart';
import 'package:http/http.dart';

class TodoClient {
  final String _apiUrl;
  final Client _httpClient;

  TodoClient(String apiUrl, {Client? httpClient})
      : _apiUrl = apiUrl.replaceAll(RegExp('\\/\$'), ''),
        _httpClient = httpClient ?? Client();

  Future<List<Todo>> getTodos() async {
    var url = Uri.parse('$_apiUrl/todos');
    var response = await _httpClient.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load todos');
    }

    return (jsonDecode(response.body) as List<dynamic>)
        .map((e) => Todo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Todo> createTodo(String title) async {
    var url = Uri.parse('$_apiUrl/todos');
    var headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'title': title, 'completed': false});
    var response = await _httpClient.post(url, headers: headers, body: body);

    if (response.statusCode != 201) {
      throw Exception('Failed to create todo');
    }

    return Todo.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
