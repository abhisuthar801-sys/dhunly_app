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
  String currentArtist = "Premium Cloud Music";
  String currentImg = "assets/logo.png"; // Aapka logo

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

  void search(String query) {
    setState(() {
      filteredSongs = allSongs.where((s) => s['title'].toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000000),
      body: Stack(
        children: [
          // Background Color Glow
          Positioned(
            top: -50,
            right: -50,
            child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.2), boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 100)])),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearch(),
                _buildCategories(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
                if (!isLoading) _buildSongList(),
                _buildGlassPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Image.asset("assets/logo.png", height: 45, errorBuilder: (c, e, s) => const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 45)),
            const SizedBox(width: 15),
            const Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: 2)),
          ],
        ),
      );

  Widget _buildSearch() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: TextField(
              onChanged: (v) => search(v),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Search Songs...",
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      );

  Widget _buildCategories() {
    List<String> tags = ["All", "Punjabi", "Sad", "Lofi", "Party"];
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(vertical: 15),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: tags.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => filterByCategory(tags[i]),
          child: Container(
            margin: const EdgeInsets.only(left: 20),
            padding: const EdgeInsets.symmetric(horizontal: 25),
            decoration: BoxDecoration(
              color: selectedCat == tags[i] ? Colors.blueAccent : Colors.white10,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(child: Text(tags[i], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ),
        ),
      ),
    );
  }

  Widget _buildSongList() => Expanded(
        child: ListView.builder(
          itemCount: filteredSongs.length,
          itemBuilder: (context, i) => ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(filteredSongs[i]['img'], width: 55, height: 55, fit: BoxFit.cover)),
            title: Text(filteredSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(filteredSongs[i]['artist'], style: const TextStyle(color: Colors.white38)),
            trailing: const Icon(Icons.play_circle_outline, color: Colors.white24),
            onTap: () {
              _player.play(UrlSource(filteredSongs[i]['url']));
              setState(() {
                currentTitle = filteredSongs[i]['title'];
                currentArtist = filteredSongs[i]['artist'];
                isPlaying = true;
              });
            },
          ),
        ),
      );

  Widget _buildGlassPlayer() => ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 90,
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), border: Border(top: BorderSide(color: Colors.white10))),
            child: Row(
              children: [
                CircleAvatar(backgroundImage: const AssetImage("assets/logo.png"), radius: 30),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text(currentTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1),
                    Text(currentArtist, style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ]),
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
