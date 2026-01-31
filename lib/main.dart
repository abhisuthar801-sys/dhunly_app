import 'package:flutter/material.dart';
import 'dart:ui'; // Ye glass effect ke liye zaroori hai
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyGlassPro()));

class DhunlyGlassPro extends StatefulWidget {
  const DhunlyGlassPro({super.key});
  @override
  State<DhunlyGlassPro> createState() => _DhunlyGlassProState();
}

class _DhunlyGlassProState extends State<DhunlyGlassPro> {
  List songs = [];
  bool isLoading = false;
  String currentSongName = "Select a Song";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic Colors
          Positioned(top: -50, left: -50, child: _circleColor(Colors.blue.withOpacity(0.4))),
          Positioned(bottom: 100, right: -50, child: _circleColor(Colors.purple.withOpacity(0.4))),
          
          // The Magic Blur (Glass Effect)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70),
            child: Container(color: Colors.transparent),
          ),

          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                const Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 6)),
                _buildSearchBar(),
                if (isLoading) const Padding(padding: EdgeInsets.only(top: 10), child: CircularProgressIndicator(color: Colors.white)),
                _buildSongList(),
                _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleColor(Color color) {
    return Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: TextField(
              onSubmitted: (v) => searchSongs(v),
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "Search your vibe...",
                hintStyle: TextStyle(color: Colors.white38),
                prefixIcon: Icon(Icons.search, color: Colors.white70),
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(15),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() {
    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          var song = songs[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
            ),
            child: ListTile(
              leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(song['image'].last['url'])),
              title: Text(song['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
              subtitle: Text(song['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
              onTap: () => setState(() {
                currentSongName = song['name'];
                currentImg = song['image'].last['url'];
              }),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
            const SizedBox(width: 15),
            Expanded(child: Text(currentSongName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600), maxLines: 1)),
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
          ],
        ),
      ),
    );
  }
}
