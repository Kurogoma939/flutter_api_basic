import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List items = [];
  String keyword = '';

  Future<dynamic> _searchRepositories() async {
    const baseUrl = 'https://api.github.com';
    const path = '/search/repositories';
    const defaultKeyword = 'flutter';

    String searchUri = '';

    // ignore: unnecessary_null_comparison
    if (keyword.isEmpty) {
      searchUri = '$baseUrl$path?q=$defaultKeyword';
    } else {
      searchUri = '$baseUrl$path?q=$keyword';
    }

    debugPrint('searchUri: $searchUri');

    try {
      final response = await http.get(Uri.parse(searchUri));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          items = responseData['items'];
        });
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
      debugPrint(searchUri);
    }
  }

  @override
  void initState() {
    super.initState();
    Future(() async {
      await _searchRepositories();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter API Demo'),
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Column(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height * 0.1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            keyword = value;
                          });
                        },
                      ),
                    ),
                    IconButton(
                        onPressed: () {
                          _searchRepositories();
                        },
                        icon: const Icon(Icons.search)),
                  ],
                ),
              ),
            ),
            _ListTileWidget(items: items),
          ],
        ),
      ),
    );
  }
}

class _ListTileWidget extends StatelessWidget {
  const _ListTileWidget({
    Key? key,
    required this.items,
  }) : super(key: key);

  final List items;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          if (items.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          final item = items[index];
          return ListTile(
            title: Text(item['full_name']),
            subtitle: Text(item['description'] ?? ''),
            leading: Image.network(item['owner']['avatar_url'] ?? ''),
          );
        },
      ),
    );
  }
}
