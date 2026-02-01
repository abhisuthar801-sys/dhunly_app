import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyBranding()));

class DhunlyBranding extends StatefulWidget {
  const DhunlyBranding({super.key});
  @override
  State<DhunlyBranding> createState() => _DhunlyBrandingState();
}

class _DhunlyBrandingState extends State<DhunlyBranding> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  bool isLoading = false;
  bool isPlaying = false;
  
  // LOGO URL (Jo aapne chuna tha - Bottom Right wala professional logo)
  final String appLogo = "https://i.ibb.co/Ldx999X/dhunly-logo.png"; 

  String currentSong = "Dhunly: Music for You";
  String currentImg = "https://i.ibb.co/Ldx999X/dhunly-logo.png";

  Future<void> searchMusic(String query) async {
    setState(() => isLoading = true);
    try {
      final res = await http.get(Uri.parse("https://pipedapi.kavin.rocks/search?q=$query&filter=videos"));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['items'];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playMusic(String vId, String title, String img) async {
    try {
      final res = await http.get(Uri.parse("https://pipedapi.kavin.rocks/streams/$vId"));
      var audioUrl = json.decode(res.body)['audioStreams'][0]['url'];
      await _player.stop();
      await _player.play(UrlSource(audioUrl));
      setState(() {
        currentSong = title;
        currentImg = img;
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
          _backgroundGradient(),
          SafeArea(
            child: Column(
              children: [
                _buildBrandedHeader(),
                _buildSearchInput(),
                if (isLoading) const LinearProgressIndicator(color: Colors.blueAccent),
                _buildMusicList(),
                _buildGlassPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundGradient() => Stack(children: [
    Positioned(top: -50, left: -50, child: _orb(Colors.blueAccent.withOpacity(0.2))),
    Positioned(bottom: -50, right: -50, child: _orb(Colors.purpleAccent.withOpacity(0.2))),
    BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: Container(color: Colors.transparent)),
  ]);

  Widget _orb(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c));

  Widget _buildBrandedHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // App logo in Header
        Image.network("https://cdn-icons-png.flaticon.com/512/3844/3844724.png", height: 40), // Placeholder logo
        const SizedBox(width: 15),
        const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 3)),
      ],
    ),
  );

  Widget _buildSearchInput() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onSubmitted: (v) => searchMusic(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search your vibe...",
        hintStyle: const TextStyle(color: Colors.white30),
        filled: true,
        fillColor: Colors.white10,
        prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _buildMusicList() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      padding: const EdgeInsets.all(15),
      itemBuilder: (context, i) {
        var s = songs[i];
        return ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(s['thumbnail'], width: 50, height: 50, fit: BoxFit.cover)),
          title: Text(s['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
          subtitle: Text(s['uploaderName'] ?? "Artist", style: const TextStyle(color: Colors.white54)),
          onTap: () {
             String vId = s['url'].split("=")[1];
             playMusic(vId, s['title'], s['thumbnail']);
          },
        );
      },
    ),
  );

  Widget _buildGlassPlayer() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.1),
      border: const Border(top: BorderSide(color: Colors.white10)),
    ),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
        const SizedBox(width: 15),
        Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.white, size: 45),
          onPressed: () {
            if (isPlaying) _player.pause(); else _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        ),
      ],
    ),
  );
}
