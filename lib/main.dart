import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false, 
    home: DhunlyApp()
  ));
}

class DhunlyApp extends StatefulWidget {
  const DhunlyApp({super.key});
  @override
  State<DhunlyApp> createState() => _DhunlyAppState();
}

class _DhunlyAppState extends State<DhunlyApp> {
  final AudioPlayer player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  
  String currentSong = "Dhunly Ready";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  // 1. Search Function (Saaavn API)
  Future<void> search(String query) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query"));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // 2. Play Function
  void play(String url, String name, String img) async {
    await player.stop();
    await player.play(UrlSource(url));
    setState(() {
      currentSong = name;
      currentImg = img;
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic (Glass Look)
          Positioned(top: -50, left: -50, child: _orb(Colors.blue)),
          Positioned(bottom: -50, right: -50, child: _orb(Colors.purple)),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 5)),
                
                // --- FEATURE: SEARCH BAR ---
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    onSubmitted: (v) => search(v),
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white10,
                      hintText: "Search Song (Arijit, Sidhu...)",
                      hintStyle: const TextStyle(color: Colors.white54),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                    ),
                  ),
                ),

                if (isLoading) const LinearProgressIndicator(),

                // --- FEATURE: SONG LIST ---
                Expanded(
                  child: ListView.builder(
                    itemCount: songs.length,
                    itemBuilder: (context, index) {
                      var s = songs[index];
                      return ListTile(
                        leading: Image.network(s['image'].last['url']),
                        title: Text(s['name'], style: const TextStyle(color: Colors.white)),
                        subtitle: Text(s['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white54)),
                        onTap: () => play(s['downloadUrl'].last['url'], s['name'], s['image'].last['url']),
                      );
                    },
                  ),
                ),

                // --- FEATURE: GLASS MINI PLAYER ---
                _miniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.3)));

  Widget _miniPlayer() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white12, border: Border(top: BorderSide(color: Colors.white24))),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(currentImg)),
          const SizedBox(width: 15),
          Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white))),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 30),
            onPressed: () {
              if (isPlaying) player.pause(); else player.resume();
              setState(() => isPlaying = !isPlaying);
            },
          ),
        ],
      ),
    );
  }
}
