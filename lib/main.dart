import 'package:flutter/material.dart';

void main() {
  runApp(const DhunlyApp());
}

class DhunlyApp extends StatelessWidget {
  const DhunlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dhunly',
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple,
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dhunly - My Music'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 50),
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade300,
                borderRadius: BorderRadius.circular(20),
                boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 10)],
              ),
              child: const Icon(Icons.music_note, size: 100, color: Colors.white),
            ),
          ),
          const SizedBox(height: 30),
          const Text('Now Playing', style: TextStyle(fontSize: 18, color: Colors.grey)),
          const Text('Your Favorite Song', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_previous, size: 40)),
                const SizedBox(width: 20),
                CircleAvatar(
                  radius: 35,
                  backgroundColor: Colors.deepPurple,
                  child: IconButton(onPressed: () {}, icon: const Icon(Icons.play_arrow, size: 40, color: Colors.white)),
                ),
                const SizedBox(width: 20),
                IconButton(onPressed: () {}, icon: const Icon(Icons.skip_next, size: 40)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
