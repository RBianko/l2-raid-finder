import 'package:flutter/material.dart';

import 'presentation/home.dart';

void main() {
  runApp(const RaidFinder());
}

class RaidFinder extends StatelessWidget {
  const RaidFinder({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
      ),
      home: const Material(
        color: Colors.black38,
        child: Home(),
      ),
    );
  }
}
