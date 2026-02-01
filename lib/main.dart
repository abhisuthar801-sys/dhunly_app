import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyDirectApp()));

class DhunlyDirectApp extends StatefulWidget {
  const DhunlyDirectApp({super.key});
  @override
  State<DhunlyDirectApp> createState() => _DhunlyDirectAppState();
}

class _DhunlyDirectAppState extends State<DhunlyDirectApp> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  String currentSong = "Select a Vibe";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  // --- YE LINKS GOOGLE AUR MUSIC SERVERS SE HAIN (Hamesha Chalenge) ---
  final List<Map<String, String>> superHits = [
    {
      'name': 'Soft Instrumental',
      'artist': 'Relax Mode',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300'
    },
    {
      'name': 'Night Vibe',
      'artist': 'Lofi Dhunly',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3',
      'img': 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300'
    },
    {
      'name': 'Deep Bass',
      'artist': 'Dhunly Special',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3',
      'img': 'https://images.unsplash.com/photo-1511671782779-c97d3d27a1d4?w=300'
    }
  ];

  // Ye function gaana bajane ke liye hai
  void play(String url, String name, String img) async {
    try {
      await _player.stop();
      // Yahan hum direct MP3 source hit kar rahe hain
      await _player.play(UrlSource(url));
      setState(() {
        currentSong = name;
        currentImg = img;
        isPlaying = true;
      });
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glass Aesthetic
          Positioned(top: -50, left: -50, child: _orb(Colors.blue.withOpacity(0.3))),
          Positioned(bottom: -50, right: -50, child: _orb(Colors.purple.withOpacity(0.3))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(25),
                  child: Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: 5)),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 25),
                  child: Text("All-Time Hits (Online)", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.bold)),
                ),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: superHits.length,
                    itemBuilder: (context, i) {
                      var s = superHits[i];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
                        child: ListTile(
                          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(s['img']!, width: 50, height: 50, fit: BoxFit.cover)),
                          title: Text(s['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(s['artist']!, style: const TextStyle(color: Colors.white54)),
                          trailing: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 35),
                          onTap: () => play(s['url']!, s['name']!, s['img']!),
                        ),
                      );
                    },
                  ),
                ),

                // Premium Glass Mini Player
                _miniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _miniPlayer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
          const SizedBox(width: 15),
          Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 45),
            onPressed: () {
              if (isPlaying) _player.pause(); else _player.resume();
              setState(() => isPlaying = !isPlaying);
            },
          ),
        ],
      ),
    );
  }
}
