import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(const MaterialApp(
  debugShowCheckedModeBanner: false,
  title: "Dhunly Pro",
  home: DhunlySpotifyMaster(),
));

class DhunlySpotifyMaster extends StatefulWidget {
  const DhunlySpotifyMaster({super.key});
  @override
  State<DhunlySpotifyMaster> createState() => _DhunlySpotifyMasterState();
}

class _DhunlySpotifyMasterState extends State<DhunlySpotifyMaster> {
  final AudioPlayer _player = AudioPlayer();
  List allSongs = [];
  List filteredSongs = [];
  bool isLoading = true;
  bool isPlaying = false;
  
  String currentTitle = "Dhunly Pro";
  String currentArtist = "Select a vibe";
  String currentImg = "https://i.ibb.co/Ldx999X/dhunly-logo.png"; // Aapka Logo

  @override
  void initState() {
    super.initState();
    syncWithCloud();
  }

  // YE HAI DUNIYA KA SABSE POWERFUL SYNC SYSTEM
  Future<void> syncWithCloud() async {
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

  void filterSearch(String query) {
    setState(() {
      filteredSongs = allSongs.where((s) => s['title'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void playMusic(var s) async {
    await _player.stop();
    await _player.play(UrlSource(s['url']));
    setState(() {
      currentTitle = s['title'];
      currentArtist = s['artist'];
      currentImg = s['img'];
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF040404),
      body: Stack(
        children: [
          _spotifyGlow(),
          SafeArea(
            child: Column(
              children: [
                _headerSection(),
                _searchSection(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.greenAccent))),
                if (!isLoading) _musicList(),
                _spotifyPlayerPanel(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _spotifyGlow() => Positioned(top: -150, left: -50, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15))));

  Widget _headerSection() => Padding(
    padding: const EdgeInsets.all(25),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.network("https://i.ibb.co/Ldx999X/dhunly-logo.png", height: 45), // LOGO
            const SizedBox(width: 15),
            const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ],
        ),
        IconButton(icon: const Icon(Icons.refresh, color: Colors.white54), onPressed: syncWithCloud),
      ],
    ),
  );

  Widget _searchSection() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onChanged: (v) => filterSearch(v),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: "Search in your library...",
        hintStyle: const TextStyle(color: Colors.white24),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        prefixIcon: const Icon(Icons.search, color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _musicList() => Expanded(
    child: ListView.builder(
      itemCount: filteredSongs.length,
      padding: const EdgeInsets.all(20),
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        child: ListTile(
          onTap: () => playMusic(filteredSongs[i]),
          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(filteredSongs[i]['img'], width: 55, height: 55, fit: BoxFit.cover)),
          title: Text(filteredSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(filteredSongs[i]['artist'], style: const TextStyle(color: Colors.white38, fontSize: 12)),
          trailing: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
        ),
      ),
    ),
  );

  Widget _spotifyPlayerPanel() => ClipRRect(
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), border: Border(top: BorderSide(color: Colors.white10))),
        child: Row(
          children: [
            CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 28),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(currentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                  Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Colors.blueAccent, size: 50),
              onPressed: () {
                isPlaying ? _player.pause() : _player.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
