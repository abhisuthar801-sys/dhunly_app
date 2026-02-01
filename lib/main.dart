import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyOnline()));

class DhunlyOnline extends StatefulWidget {
  const DhunlyOnline({super.key});
  @override
  State<DhunlyOnline> createState() => _DhunlyOnlineState();
}

class _DhunlyOnlineState extends State<DhunlyOnline> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  String currentSong = "Dhunly: Online Mode";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  // --- 100% WORKING API (No Key Required) ---
  Future<void> getMusic(String query) async {
    setState(() => isLoading = true);
    try {
      // Hum is open-source API ka use karenge jo fast hai
      final response = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query&limit=20"));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          songs = data['data']['results'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playMusic(String url, String name, String img) async {
    try {
      await _player.stop();
      // Yahan hum sabse fast server link utha rahe hain
      await _player.play(UrlSource(url));
      setState(() {
        currentSong = name;
        currentImg = img;
        isPlaying = true;
      });
    } catch (e) {
      print("Stream Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glass Background
          _backgroundEffect(),
          SafeArea(
            child: Column(
              children: [
                _header(),
                _searchBox(),
                if (isLoading) const LinearProgressIndicator(color: Colors.blueAccent),
                _songList(),
                _playerBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundEffect() {
    return Stack(
      children: [
        Positioned(top: -50, left: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent))),
        Positioned(bottom: -50, right: -50, child: Container(width: 300, height: 300, decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.purpleAccent))),
        BackdropFilter(filter: ImageFilter.blur(sigmaX: 90, sigmaY: 90), child: Container(color: Colors.transparent)),
      ],
    );
  }

  Widget _header() => const Padding(
    padding: EdgeInsets.all(20),
    child: Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 5)),
  );

  Widget _searchBox() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onSubmitted: (v) => getMusic(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search (Ex: Sidhu, Arijit, Karan Aujla)",
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _songList() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) {
        var s = songs[index];
        return ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(s['image'].last['url'])),
          title: Text(s['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(s['artists']['primary'][0]['name'], style: const TextStyle(color: Colors.white54)),
          onTap: () => playMusic(s['downloadUrl'].last['url'], s['name'], s['image'].last['url']),
        );
      },
    ),
  );

  Widget _playerBar() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), border: const Border(top: BorderSide(color: Colors.white10))),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg)),
        const SizedBox(width: 15),
        Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white), maxLines: 1)),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.white, size: 40),
          onPressed: () {
            if (isPlaying) _player.pause(); else _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        ),
      ],
    ),
  );
}
