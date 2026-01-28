import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Dhunly Music Ready', 
          style: TextStyle(color: Colors.red, fontSize: 24, fontWeight: FontWeight.bold)),
        ),
      ),
    ));
