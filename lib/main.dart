import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyMasterApp()));

class DhunlyMasterApp extends StatefulWidget {
  const DhunlyMasterApp({super.key});
  @override
  State<DhunlyMasterApp> createState() => _DhunlyMasterAppState();
}

class _DhunlyMasterAppState extends State<DhunlyMasterApp> {
  final AudioPlayer _player = AudioPlayer();
  List cloudSongs = [];
  bool isPlaying = false;
  bool isLoading = true;
  String currentSong = "Dhunly: Select Vibe";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  @override
  void initState() {
    super.initState();
    fetchCloudLibrary(); // App khulte hi database se gaane uthayega
  }

  // --- DATABASE FETCH (External JSON) ---
  Future<void> fetchCloudLibrary() async {
    try {
      // Ye mera banaya hua database link hai, isme hum 100+ gaane dalenge
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/6e584a7e-1234-4321-abcd-example")); 
      // Note: Abhi ke liye niche static list hai jab tak link active na ho
      setState(() {
        cloudSongs = [
          {'title': 'Sidhu Legend', 'artist': 'Sidhu Moose Wala', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200'},
          {'title': 'Soft Lofi', 'artist': 'Dhunly Beats', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 'img': 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=200'},
          {'title': 'Punjabi Vibe', 'artist': 'Karan Aujla', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3', 'img': 'https://images.unsplash.com/photo-1514525253344-f856d3a7611a?w=200'},
        ];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playMusic(var s) async {
    await _player.stop();
    await _player.play(UrlSource(s['url']));
    setState(() {
      currentSong = s['title'];
      currentImg = s['img'];
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _backgroundGlow(),
          SafeArea(
            child: Column(
              children: [
                _headerWithLogo(),
                _categoryTabs(),
                if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueAccent)),
                _songLibrary(),
                _premiumMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGlow() => Positioned(top: -100, left: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15))));

  Widget _headerWithLogo() => Padding(
    padding: const EdgeInsets.all(25),
    child: Row(
      children: [
        // AAPKA CHUNA HUA LOGO ICON
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: Colors.blueAccent, borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 30),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text("Premium Experience", style: TextStyle(color: Colors.white38, fontSize: 10)),
          ],
        ),
      ],
    ),
  );

  Widget _categoryTabs() => Container(
    height: 40,
    margin: const EdgeInsets.only(bottom: 10),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: ['Trending', 'Punjabi', 'Lofi', 'New Hits'].map((cat) => Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
        child: Text(cat, style: const TextStyle(color: Colors.white70, fontSize: 12)),
      )).toList(),
    ),
  );

  Widget _songLibrary() => Expanded(
    child: ListView.builder(
      itemCount: cloudSongs.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, i) => ListTile(
        contentPadding: const EdgeInsets.only(bottom: 15),
        leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(cloudSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(cloudSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(cloudSongs[i]['artist'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
        trailing: const Icon(Icons.more_vert, color: Colors.white30),
        onTap: () => playMusic(cloudSongs[i]),
      ),
    ),
  );

  Widget _premiumMiniPlayer() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: const Color(0xFF121212),
      border: Border(top: BorderSide(color: Colors.blueAccent.withOpacity(0.3))),
    ),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
        const SizedBox(width: 15),
        Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.blueAccent, size: 45),
          onPressed: () {
            isPlaying ? _player.pause() : _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        ),
      ],
    ),
  );
}
