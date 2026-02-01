import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFinalApp()));

class DhunlyFinalApp extends StatefulWidget {
  const DhunlyFinalApp({super.key});
  @override
  State<DhunlyFinalApp> createState() => _DhunlyFinalAppState();
}

class _DhunlyFinalAppState extends State<DhunlyFinalApp> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  int currentIndex = -1;

  String currentSong = "Dhunly Music";
  String currentArtist = "Tap to Search & Play";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  // --- Search Engine ---
  Future<void> searchMusic(String query) async {
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

  // --- Play Function ---
  void playMusic(int index) async {
    if (index < 0 || index >= songs.length) return;
    var s = songs[index];
    try {
      String url = s['downloadUrl'].last['url'];
      await _player.stop();
      await _player.play(UrlSource(url));
      setState(() {
        currentIndex = index;
        currentSong = s['name'];
        currentArtist = s['artists']['primary'][0]['name'];
        currentImg = s['image'].last['url'];
        isPlaying = true;
      });
    } catch (e) { print(e); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glass Background
          Positioned(top: -50, left: -50, child: _orb(Colors.blue.withOpacity(0.3))),
          Positioned(bottom: -50, right: -50, child: _orb(Colors.purple.withOpacity(0.3))),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 70, sigmaY: 70), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (isLoading) const LinearProgressIndicator(color: Colors.blueAccent),
                _buildSongList(),
                _buildAdvancedPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _buildHeader() => const Padding(
    padding: EdgeInsets.all(20),
    child: Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 8)),
  );

  Widget _buildSearchBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onSubmitted: (v) => searchMusic(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        hintText: "Artist ya Song search karein...",
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _buildSongList() => Expanded(
    child: ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        var s = songs[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
          child: ListTile(
            leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(s['image'].last['url'])),
            title: Text(s['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
            subtitle: Text(s['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
            onTap: () => playMusic(index),
          ),
        );
      },
    ),
  );

  Widget _buildAdvancedPlayer() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
            const SizedBox(width: 15),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1), Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 12))])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white, size: 35), onPressed: () => playMusic(currentIndex - 1)),
            const SizedBox(width: 20),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.blueAccent, size: 55),
              onPressed: () {
                if (isPlaying) _player.pause(); else _player.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
            const SizedBox(width: 20),
            IconButton(icon: const Icon(Icons.skip_next, color: Colors.white, size: 35), onPressed: () => playMusic(currentIndex + 1)),
          ],
        ),
      ],
    ),
  );
}
