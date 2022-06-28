import 'package:flutter_http/client/todo_client.dart';
import 'package:http/http.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'todo_client_test.mocks.dart';

@GenerateMocks([Client])
void main() {
  var httpClient = MockClient();
  var todoClient = TodoClient('https://api.todo.com/', httpClient: httpClient);

  test('Get todos performs GET /todos request', () async {
    // Given: 2 todos have been created
    when(httpClient.get(any)).thenAnswer((_) async => Response('''
        [
          { "id": 1, "title": "Get milk", "completed": false },
          { "id": 2, "title": "Water plants", "completed": true }
        ]
        ''', 200));

    // When: get todos is called
    var todos = await todoClient.getTodos();

    // Then: the expected uri is used
    var capturedUri = verify(httpClient.get(captureAny)).captured.single as Uri;
    expect(capturedUri.toString(), 'https://api.todo.com/todos');

    // And: the response is parsed correctly
    expect(todos.length, 2);

    expect(todos[0].id, 1);
    expect(todos[0].title, 'Get milk');
    expect(todos[0].completed, false);

    expect(todos[1].id, 2);
    expect(todos[1].title, 'Water plants');
    expect(todos[1].completed, true);
  });

  test('Create todo performs POST /todos request', () async {
    // Given: the api will respond to create
    when(httpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((_) async => Response('''
          { "id": 1, "title": "Get milk", "completed": false }
        ''', 201));

    // When: create todo is called
    var todo = await todoClient.createTodo('Get milk');

    var captured = verify(httpClient.post(captureAny,
            headers: captureAnyNamed('headers'), body: captureAnyNamed('body')))
        .captured;
    var capturedUri = captured[0] as Uri;
    var capturedHeaders = captured[1] as Map<String, String>;
    var capturedBody = captured[2] as String;

    // Then: the expected uri, headers and body is used in the request
    expect(capturedUri.toString(), 'https://api.todo.com/todos');
    expect(capturedHeaders, Map.fromEntries([const MapEntry('Content-Type', 'application/json')]));
    expect(capturedBody, '{"title":"Get milk","completed":false}');

    // And: the response is parsed correctly
    expect(todo.id, 1);
    expect(todo.title, 'Get milk');
    expect(todo.completed, false);
  });
}
