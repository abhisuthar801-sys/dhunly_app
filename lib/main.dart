import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFast()));

class DhunlyFast extends StatefulWidget {
  const DhunlyFast({super.key});
  @override
  State<DhunlyFast> createState() => _DhunlyFastState();
}

class _DhunlyFastState extends State<DhunlyFast> {
  final player = AudioPlayer();
  bool isPlaying = false;
  String currentTitle = "Select a Song";
  String currentArtist = "Dhunly Hits";

  // Fast Direct Links (MP3)
  final List<Map<String, String>> onlineSongs = [
    {
      'title': 'Heeriye (Fast Stream)',
      'artist': 'Arijit Singh',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
    },
    {
      'title': 'Pehle Bhi Main',
      'artist': 'Animal',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
    },
    {
      'title': 'Lofi Study',
      'artist': 'Relaxing',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'
    },
  ];

  Future<void> playSong(String url, String title, String artist) async {
    setState(() {
      currentTitle = title;
      currentArtist = artist;
      isPlaying = true;
    });
    await player.stop();
    await player.play(UrlSource(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      appBar: AppBar(
        title: const Text("Dhunly Premium"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Player Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const CircleAvatar(radius: 30, child: Icon(Icons.music_note)),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(currentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      Text(currentArtist, style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 40),
                  onPressed: () {
                    if (isPlaying) { player.pause(); } else { player.resume(); }
                    setState(() => isPlaying = !isPlaying);
                  },
                )
              ],
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Align(alignment: Alignment.centerLeft, child: Text("Direct Online Songs", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: onlineSongs.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(Icons.play_arrow, color: Colors.blueAccent),
                  title: Text(onlineSongs[index]['title']!, style: const TextStyle(color: Colors.white)),
                  subtitle: Text(onlineSongs[index]['artist']!, style: const TextStyle(color: Colors.white54)),
                  onTap: () => playSong(onlineSongs[index]['url']!, onlineSongs[index]['title']!, onlineSongs[index]['artist']!),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
