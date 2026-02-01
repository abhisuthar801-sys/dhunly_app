import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Dhunly Pro",
      home: DhunlyGlassApp(),
    ));

class DhunlyGlassApp extends StatefulWidget {
  const DhunlyGlassApp({super.key});
  @override
  State<DhunlyGlassApp> createState() => _DhunlyGlassAppState();
}

class _DhunlyGlassAppState extends State<DhunlyGlassApp> {
  final AudioPlayer _player = AudioPlayer();
  List allSongs = [];
  List filteredSongs = [];
  String selectedCat = "All";
  bool isLoading = true;
  bool isPlaying = false;

  String currentTitle = "Dhunly Pro";
  String currentArtist = "Premium Music Experience";
  String currentImg = "assets/logo.png"; 

  @override
  void initState() {
    super.initState();
    fetchMusic();
  }

  Future<void> fetchMusic() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        var data = json.decode(res.body)['songs'];
        setState(() {
          allSongs = data;
          filteredSongs = data;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void filterByCategory(String cat) {
    setState(() {
      selectedCat = cat;
      filteredSongs = (cat == "All") ? allSongs : allSongs.where((s) => s['category'] == cat).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(top: -50, right: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15)))),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Image.asset("assets/logo.png", height: 40, errorBuilder: (c, e, s) => const Icon(Icons.music_note, color: Colors.blueAccent)),
                      const SizedBox(width: 15),
                      const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 2)),
                    ],
                  ),
                ),
                // Categories
                SizedBox(
                  height: 50,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: ["All", "Punjabi", "Sad", "Lofi"].map((cat) => Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: ActionChip(
                        label: Text(cat),
                        backgroundColor: selectedCat == cat ? Colors.blueAccent : Colors.white10,
                        onPressed: () => filterByCategory(cat),
                        labelStyle: const TextStyle(color: Colors.white),
                      ),
                    )).toList(),
                  ),
                ),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
                if (!isLoading) Expanded(
                  child: ListView.builder(
                    itemCount: filteredSongs.length,
                    itemBuilder: (context, i) => ListTile(
                      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(filteredSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
                      title: Text(filteredSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      subtitle: Text(filteredSongs[i]['artist'], style: const TextStyle(color: Colors.white54)),
                      onTap: () {
                        _player.play(UrlSource(filteredSongs[i]['url']));
                        setState(() { currentTitle = filteredSongs[i]['title']; currentArtist = filteredSongs[i]['artist']; isPlaying = true; });
                      },
                    ),
                  ),
                ),
                // Glass Player
                if (isPlaying || !isLoading) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() => ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                const CircleAvatar(backgroundImage: AssetImage("assets/logo.png"), radius: 25),
                const SizedBox(width: 15),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 12))])),
                IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.blueAccent, size: 40), onPressed: () { isPlaying ? _player.pause() : _player.resume(); setState(() => isPlaying = !isPlaying); }),
              ],
            ),
          ),
        ),
      );
}
