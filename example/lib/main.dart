import 'package:example/async_get/async_get_page.dart';
import 'package:example/caching/caching_page.dart';
import 'package:example/global_state/global_state_page.dart';
import 'package:example/pagination/pagination_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Mutation Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Mutation Demo Home Page'),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(AsyncGetPage.createRoute());
                },
                child: const Text("async get")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(PaginationPage.createRoute());
                },
                child: const Text("pagination")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(CachingPage.createRoute());
                },
                child: const Text("caching")),
            TextButton(
                onPressed: () {
                  Navigator.of(context).push(GlobalStatePage.createRoute());
                },
                child: const Text("global state"))
          ],
        ),
      ),
    );
  }
}
