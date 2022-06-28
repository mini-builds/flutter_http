import 'package:flutter/material.dart';
import 'package:flutter_http/client/model.dart';
import 'package:flutter_http/client/todo_client.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_http/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'widget_test.mocks.dart';

@GenerateMocks([TodoClient])
void main() {
  var todoClient = MockTodoClient();

  testWidgets('Number of todos is displayed after loading from client',
      (WidgetTester tester) async {
    when(todoClient.getTodos()).thenAnswer((_) async => [Todo(1, 'Get milk', false)]);

    // When: the app loads
    await tester.pumpWidget(HttpClientExample(todoClient));

    // Then: a progress indicator shows while the client is loading
    expect(find.byType(CircularProgressIndicator), findsWidgets);

    await tester.pump();

    // And: once the todos have loaded the count is displayed
    expect(find.text('No. of todos: 1'), findsOneWidget);

    verify(todoClient.getTodos());
  });

  testWidgets('Create todo button creates todo via client', (WidgetTester tester) async {
    when(todoClient.createTodo(argThat(equals('A todo title'))))
        .thenAnswer((_) async => Todo(1, 'A todo title', false));

    await tester.pumpWidget(HttpClientExample(todoClient));

    // When: the create todo button is clicked
    await tester.tap(find.byType(ElevatedButton));

    await tester.pumpAndSettle();

    // When: the client is used to create the todo
    verify(todoClient.createTodo(argThat(equals('A todo title'))));
  });
}
