import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyPro()));

class DhunlyPro extends StatefulWidget {
  const DhunlyPro({super.key});
  @override
  State<DhunlyPro> createState() => _DhunlyProState();
}

class _DhunlyProState extends State<DhunlyPro> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  String currentSong = "Dhunly Premium";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  @override
  void initState() {
    super.initState();
    // Seekbar Logic: Gaane ka time update karne ke liye
    _player.onDurationChanged.listen((d) => setState(() => _duration = d));
    _player.onPositionChanged.listen((p) => setState(() => _position = p));
  }

  Future<void> searchMusic(String query) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("https://saavn.dev/api/search/songs?query=$query&limit=15"));
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

  void playMusic(var s) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(s['downloadUrl'].last['url']));
      setState(() {
        currentSong = s['name'];
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
          // Glass Effect Background
          Positioned(top: -50, left: -50, child: _orb(Colors.blueAccent)),
          Positioned(bottom: -50, right: -50, child: _orb(Colors.purpleAccent)),
          BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: Container(color: Colors.transparent)),

          SafeArea(
            child: Column(
              children: [
                _header(),
                _searchField(),
                if (isLoading) const LinearProgressIndicator(),
                _songList(),
                _premiumPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.3)));

  Widget _header() => const Padding(
    padding: EdgeInsets.all(20),
    child: Text("DHUNLY", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 8)),
  );

  Widget _searchField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onSubmitted: (v) => searchMusic(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white10,
        hintText: "Artist, Song or Mood...",
        hintStyle: const TextStyle(color: Colors.white30),
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _songList() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, i) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(songs[i]['image'].last['url'])),
        title: Text(songs[i]['name'], style: const TextStyle(color: Colors.white)),
        onTap: () => playMusic(songs[i]),
      ),
    ),
  );

  Widget _premiumPlayer() => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: const BorderRadius.vertical(top: Radius.circular(30))),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Seekbar Feature
        Slider(
          activeColor: Colors.blueAccent,
          inactiveColor: Colors.white24,
          value: _position.inSeconds.toDouble(),
          max: _duration.inSeconds.toDouble(),
          onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
        ),
        Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
            const SizedBox(width: 15),
            Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white, size: 40),
              onPressed: () {
                if (isPlaying) _player.pause(); else _player.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
          ],
        ),
      ],
    ),
  );
}
