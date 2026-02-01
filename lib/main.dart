import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFinal()));

class DhunlyFinal extends StatefulWidget {
  const DhunlyFinal({super.key});
  @override
  State<DhunlyFinal> createState() => _DhunlyFinalState();
}

class _DhunlyFinalState extends State<DhunlyFinal> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  String currentSong = "Select a Track";
  String currentArtist = "Dhunly Originals";
  String currentImg = "https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=500&q=80";

  // --- YE LINKS 100% WORK KARENGE ---
  final List<Map<String, String>> playlist = [
    {
      'title': 'High Energy Beats',
      'artist': 'Electronic Mix',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3',
      'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300'
    },
    {
      'title': 'Lofi Chill Night',
      'artist': 'Dhunly Special',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3',
      'img': 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300'
    },
    {
      'title': 'Deep Forest',
      'artist': 'Nature Vibe',
      'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3',
      'img': 'https://images.unsplash.com/photo-1441974231531-c6227db76b6e?w=300'
    }
  ];

  void _play(String url, String title, String artist, String img) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() {
        currentSong = title;
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
          // Background Aesthetic
          Positioned(top: -50, left: -50, child: _orb(Colors.purple.withOpacity(0.3))),
          Positioned(bottom: -50, right: -50, child: _orb(Colors.blue.withOpacity(0.3))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _header(),
                _searchBarStub(),
                _sectionTitle("Your Daily Mix"),
                _songGrid(),
                const Spacer(),
                _floatingPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _header() => const Padding(
    padding: EdgeInsets.all(20),
    child: Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 8)),
  );

  Widget _searchBarStub() => Container(
    margin: const EdgeInsets.symmetric(horizontal: 20),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
    child: const Row(children: [Icon(Icons.search, color: Colors.white54), SizedBox(width: 10), Text("What do you want to listen to?", style: TextStyle(color: Colors.white54))]),
  );

  Widget _sectionTitle(String t) => Padding(padding: const EdgeInsets.all(20), child: Text(t, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)));

  Widget _songGrid() => SizedBox(
    height: 200,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      itemCount: playlist.length,
      itemBuilder: (context, i) {
        var s = playlist[i];
        return GestureDetector(
          onTap: () => _play(s['url']!, s['title']!, s['artist']!, s['img']!),
          child: Container(
            width: 150,
            margin: const EdgeInsets.only(right: 15),
            decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(15)), child: Image.network(s['img']!, height: 120, width: 150, fit: BoxFit.cover)),
                Padding(padding: const EdgeInsets.all(10), child: Text(s['title']!, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text(s['artist']!, style: const TextStyle(color: Colors.white54, fontSize: 12))),
              ],
            ),
          ),
        );
      },
    ),
  );

  Widget _floatingPlayer() => ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        margin: const EdgeInsets.all(10),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white12)),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(currentArtist, style: const TextStyle(color: Colors.white70, fontSize: 12))])),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 40),
              onPressed: () {
                if (isPlaying) { _player.pause(); } else { _player.resume(); }
                setState(() => isPlaying = !isPlaying);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
