import 'package:flutter/material.dart';

void main() => runApp(DhunlyApp());

class DhunlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        app: AppBar(title: Text('Dhunly Music'), backgroundColor: Colors.red),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.music_note, size: 100, color: Colors.red),
              Text('Playing your favorite music...', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
