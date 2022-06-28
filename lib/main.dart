import 'package:flutter/material.dart';
import 'package:flutter_http/client/model.dart';
import 'package:flutter_http/client/todo_client.dart';

void main() {
  final TodoClient todoClient = TodoClient('https://jsonplaceholder.typicode.com/');

  runApp(HttpClientExample(todoClient));
}

class HttpClientExample extends StatelessWidget {
  final TodoClient todoClient;

  const HttpClientExample(this.todoClient, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter HTTP Client Example',
      home: TodoPage(todoClient),
    );
  }
}

class TodoPage extends StatelessWidget {
  final TodoClient todoClient;

  const TodoPage(this.todoClient, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<Todo>>(
                future: todoClient.getTodos(),
                builder: (context, data) {
                  if (data.hasError) {
                    return const Icon(Icons.error, color: Colors.red);
                  }
                  if (data.hasData) {
                    return Text('No. of todos: ${data.data?.length}');
                  }
                  return const CircularProgressIndicator();
                }),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
                child: const Text('Create Todo'),
                onPressed: () async {
                  var messenger = ScaffoldMessenger.of(context);

                  messenger.showSnackBar(SnackBar(
                    content: Row(
                      children: const [
                        SizedBox(
                          child: CircularProgressIndicator(strokeWidth: 2.0),
                          height: 12.0,
                          width: 12.0,
                        ),
                        SizedBox(width: 12.0),
                        Text('Creating todo'),
                      ],
                    ),
                    duration: const Duration(minutes: 1),
                  ));

                  var todo = await todoClient.createTodo('A todo title');
                  await Future.delayed(const Duration(seconds: 5));
                  messenger.clearSnackBars();

                  messenger.showSnackBar(SnackBar(
                    content: Text('Created: ${todo.title}'),
                  ));
                }),
          )
        ],
      ),
    );
  }
}
