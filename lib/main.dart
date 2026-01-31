import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: DhunlyBase(),
  ));
}

class DhunlyBase extends StatefulWidget {
  const DhunlyBase({super.key});

  @override
  State<DhunlyBase> createState() => _DhunlyBaseState();
}

class _DhunlyBaseState extends State<DhunlyBase> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Dhunly Lite"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.music_note, size: 100, color: Colors.green),
            const SizedBox(height: 20),
            const Text(
              "Music Engine Test",
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              onPressed: () async {
                if (isPlaying) {
                  await player.pause();
                } else {
                  // Sample Online MP3
                  await player.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
                }
                setState(() {
                  isPlaying = !isPlaying;
                });
              },
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
              label: Text(isPlaying ? "PAUSE" : "PLAY TEST SONG"),
            ),
          ],
        ),
      ),
    );
  }
}
