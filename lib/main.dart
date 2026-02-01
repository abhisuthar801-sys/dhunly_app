import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFinalTest()));

class DhunlyFinalTest extends StatefulWidget {
  const DhunlyFinalTest({super.key});
  @override
  State<DhunlyFinalTest> createState() => _DhunlyFinalTestState();
}

class _DhunlyFinalTestState extends State<DhunlyFinalTest> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  String currentSong = "Ready to Play";
  
  // YE LINKS 100% CHALENGE (Direct MP3 Files)
  final List<Map<String, String>> staticSongs = [
    {
      'name': 'Punjabi Bass Mix',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200'
    },
    {
      'name': 'Lofi Beats Dhunly',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'img': 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=200'
    },
    {
      'name': 'Slow Chill Vibe',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      'img': 'https://images.unsplash.com/photo-1459749411177-042180ce673c?w=200'
    }
  ];

  void playDirect(String url, String name) async {
    try {
      await _player.stop();
      // Yahan hum UrlSource use kar rahe hain jo direct MP3 stream karta hai
      await _player.play(UrlSource(url));
      setState(() {
        currentSong = name;
        isPlaying = true;
      });
    } catch (e) {
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Premium Logo/Background Effect
          Positioned(top: -50, left: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.4)))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 30),
                const Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900, letterSpacing: 10)),
                const Text("STABLE VERSION 1.0", style: TextStyle(color: Colors.white54, fontSize: 10)),
                
                const Padding(
                  padding: EdgeInsets.all(30),
                  child: Icon(Icons.music_note, color: Colors.blueAccent, size: 80),
                ),

                const Text("Tap to Test Audio", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: staticSongs.length,
                    itemBuilder: (context, i) => Card(
                      color: Colors.white10,
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 40),
                        title: Text(staticSongs[i]['name']!, style: const TextStyle(color: Colors.white)),
                        onTap: () => playDirect(staticSongs[i]['url']!, staticSongs[i]['name']!),
                      ),
                    ),
                  ),
                ),

                // Control Bar
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                  child: Row(
                    children: [
                      const Icon(Icons.graphic_eq, color: Colors.white),
                      const SizedBox(width: 15),
                      Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      IconButton(
                        icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
                        onPressed: () {
                          if (isPlaying) _player.pause(); else _player.resume();
                          setState(() => isPlaying = !isPlaying);
                        },
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
