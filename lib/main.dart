import 'package:flutter/material.dart';

void main() => runApp(const DhunlyApp());

class DhunlyApp extends StatelessWidget {
  const DhunlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'DHUNLY',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 50,
              fontWeight: FontWeight.bold,
              letterSpacing: 5,
            ),
          ),
        ),
      ),
    );
  }
}
