import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: Text('Dhunly App Live', style: TextStyle(color: Colors.white, fontSize: 24))),
      ),
    ));
