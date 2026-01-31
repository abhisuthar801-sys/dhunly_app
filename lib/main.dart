import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyAllInOne()));

class DhunlyAllInOne extends StatefulWidget {
  const DhunlyAllInOne({super.key});
  @override
  State<DhunlyAllInOne> createState() => _DhunlyAllInOneState();
}

class _DhunlyAllInOneState extends State<DhunlyAllInOne> {
  final AudioPlayer player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  
  String currentSong = "Dhunly Vibe";
  String currentArtist = "Ready to Play";
  String currentImg = "https://images.unsplash.com/photo-1614613535308-eb5fbd3d2c17?w=500&q=80";

  // --- Search Function (New & Improved) ---
  Future<void> searchSongs(String query) async {
    setState(() => isLoading = true);
    try {
      final response = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query"));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          songs = data['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  // --- Play Function ---
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
          // Glassy Background
          Positioned(top: -50, left: -50, child: _orb(Colors.blue.withOpacity(0.4))),
          Positioned(bottom: 0, right: -50, child: _orb(Colors.purple.withOpacity(0.4))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 6)),
                
                // Search Bar (Feature 1)
                _buildSearchBar(),

                if (isLoading) const LinearProgressIndicator(color: Colors.blueAccent),

                // Song List (Feature 2)
                Expanded(
                  child: songs.isEmpty ? _buildDirectLinks() : _buildSearchResults(),
                ),

                // Glass Mini Player (Feature 3)
                _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.all(20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
          child: TextField(
            onSubmitted: (v) => searchSongs(v),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: "Search anything...",
              hintStyle: TextStyle(color: Colors.white38),
              prefixIcon: Icon(Icons.search, color: Colors.blueAccent),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(15),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildSearchResults() => ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    itemCount: songs.length,
    itemBuilder: (context, index) {
      var s = songs[index];
      return _songTile(
        s['name'], 
        s['artists']['primary'][0]['name'], 
        s['image'].last['url'], 
        s['downloadUrl'].last['url']
      );
    },
  );

  Widget _buildDirectLinks() => Column(
    children: [
      const Padding(
        padding: EdgeInsets.all(20),
        child: Align(alignment: Alignment.centerLeft, child: Text("Direct Fast Links", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
      ),
      _songTile("Fast Track 1", "Dhunly Cloud", "https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=200", "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"),
      _songTile("Fast Track 2", "Dhunly Cloud", "https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=200", "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"),
    ],
  );

  Widget _songTile(String name, String artist, String img, String url) => Container(
    margin: const EdgeInsets.only(bottom: 10, left: 20, right: 20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
    child: ListTile(
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(img, width: 50, height: 50, fit: BoxFit.cover)),
      title: Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
      subtitle: Text(artist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      onTap: () => playMusic(url, name, artist, img),
    ),
  );

  Widget _buildMiniPlayer() => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
    child: Container(
      padding: const EdgeInsets.all(15),
      color: Colors.white.withOpacity(0.05),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
          const SizedBox(width: 15),
          Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 40),
            onPressed: () {
              if (isPlaying) { player.pause(); } else { player.resume(); }
              setState(() => isPlaying = !isPlaying);
            },
          ),
        ],
      ),
    ),
  );
}
