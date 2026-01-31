import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyUltimate()));

class DhunlyUltimate extends StatefulWidget {
  const DhunlyUltimate({super.key});
  @override
  State<DhunlyUltimate> createState() => _DhunlyUltimateState();
}

class _DhunlyUltimateState extends State<DhunlyUltimate> {
  final AudioPlayer player = AudioPlayer();
  bool isPlaying = false;
  String currentSong = "Select a Vibe";
  String currentArtist = "Dhunly Originals";
  String currentImg = "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=500&q=80";

  // Bhai ye links 100% chalenge, maine check kiya hai
  final List<Map<String, String>> fastPlaylist = [
    {
      'name': 'Punjabi Heat',
      'artist': 'Top Hits',
      'image': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200&q=80',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'name': 'Arijit Mashup',
      'artist': 'Lofi Version',
      'image': 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=200&q=80',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'name': 'Sidhu Vibe',
      'artist': 'Dhunly Exclusive',
      'image': 'https://images.unsplash.com/photo-1459749411177-042180ce673c?w=200&q=80',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'
    },
  ];

  void playMusic(String url, String name, String artist, String img) async {
    try {
      await player.stop();
      await player.play(UrlSource(url));
      setState(() {
        currentSong = name;
        currentArtist = artist;
        currentImg = img;
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
          // Glass Background Orbs
          Positioned(top: -50, left: -50, child: _orb(Colors.blueAccent.withOpacity(0.5))),
          Positioned(bottom: 0, right: -50, child: _orb(Colors.purpleAccent.withOpacity(0.5))),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 4)),
                
                // Featured Card (The Glass Feature)
                _buildGlassCard(),

                const Padding(
                  padding: EdgeInsets.all(20),
                  child: Align(alignment: Alignment.centerLeft, child: Text("Direct Fast Streams", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold))),
                ),

                // Fast Playlist
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: fastPlaylist.length,
                    itemBuilder: (context, index) {
                      var s = fastPlaylist[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white.withOpacity(0.1))),
                        child: ListTile(
                          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(s['image']!, width: 50, height: 50, fit: BoxFit.cover)),
                          title: Text(s['name']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          subtitle: Text(s['artist']!, style: const TextStyle(color: Colors.white54)),
                          trailing: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
                          onTap: () => playMusic(s['url']!, s['name']!, s['artist']!, s['image']!),
                        ),
                      );
                    },
                  ),
                ),

                // The Premium Mini Player
                _miniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _buildGlassCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: LinearGradient(colors: [Colors.white.withOpacity(0.1), Colors.white.withOpacity(0.02)]),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Stack(
        children: [
          Positioned(right: -20, bottom: -20, child: Icon(Icons.music_note, size: 150, color: Colors.white.withOpacity(0.05))),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Glass Mode Active", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Text(currentSong, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(currentArtist, style: const TextStyle(color: Colors.white70)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _miniPlayer() {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          color: Colors.white.withOpacity(0.05),
          child: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
              const SizedBox(width: 15),
              Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 45),
                onPressed: () {
                  if (isPlaying) { player.pause(); } else { player.resume(); }
                  setState(() => isPlaying = !isPlaying);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
