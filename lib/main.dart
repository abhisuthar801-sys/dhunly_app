import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyUltimateApp(),
    ));

class DhunlyUltimateApp extends StatefulWidget {
  @override
  _DhunlyUltimateAppState createState() => _DhunlyUltimateAppState();
}

class _DhunlyUltimateAppState extends State<DhunlyUltimateApp> {
  final AudioPlayer _player = AudioPlayer();
  List songs = [];
  List filteredSongs = [];
  bool isLoading = true;
  bool isPlaying = false;
  var currentSong;
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchCloudMusic();
  }

  Future<void> fetchCloudMusic() async {
    try {
      final res = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (res.statusCode == 200) {
        setState(() {
          songs = json.decode(res.body)['songs'];
          filteredSongs = songs;
          currentSong = songs[0];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playMusic(var song) async {
    await _player.stop();
    await _player.play(UrlSource(song['url']));
    setState(() { currentSong = song; isPlaying = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic Glow
          Positioned(top: -50, left: -50, child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.2), blurRadius: 100))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchField(),
                _buildCategories(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent)))
                else _buildSongLibrary(),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // --- UI COMPONENTS ---

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Dhunly Pro", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white)),
        const Icon(Icons.history, color: Colors.white70),
      ],
    ),
  );

  Widget _buildSearchField() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          onChanged: (v) => setState(() => filteredSongs = songs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList()),
          decoration: InputDecoration(
            hintText: "Search songs, artists...",
            prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
            filled: true,
            fillColor: Colors.white.withOpacity(0.05),
            border: InputBorder.none,
          ),
        ),
      ),
    ),
  );

  Widget _buildCategories() => Container(
    height: 60,
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20),
      children: ["All", "Punjabi", "Lofi", "Sad", "Party"].map((c) => Padding(
        padding: const EdgeInsets.only(right: 10),
        child: ChoiceChip(label: Text(c), selected: false, onSelected: (v){}),
      )).toList(),
    ),
  );

  Widget _buildSongLibrary() => Expanded(
    child: ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, i) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(filteredSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(filteredSongs[i]['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(filteredSongs[i]['artist']),
        onTap: () => playMusic(filteredSongs[i]),
      ),
    ),
  );

  Widget _buildMiniPlayer() => GestureDetector(
    onTap: () => _openFullPlayer(),
    child: Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'], width: 45, height: 45)),
          const SizedBox(width: 15),
          Expanded(child: Text(currentSong['title'], style: const TextStyle(fontWeight: FontWeight.bold))),
          IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white), onPressed: () {
            isPlaying ? _player.pause() : _player.resume();
            setState(() => isPlaying = !isPlaying);
          }),
        ],
      ),
    ),
  );

  Widget _buildBottomNav() => BottomNavigationBar(
    currentIndex: _selectedIndex,
    onTap: (i) => setState(() => _selectedIndex = i),
    backgroundColor: Colors.black,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.white54,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
    ],
  );

  void _openFullPlayer() {
    showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.black, builder: (context) => Container(
      height: MediaQuery.of(context).size.height * 0.9,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
        const Spacer(),
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(currentSong['img'], width: 300, height: 300, fit: BoxFit.cover)),
        const SizedBox(height: 30),
        Text(currentSong['title'], style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        Text(currentSong['artist'], style: const TextStyle(fontSize: 18, color: Colors.white54)),
        const Spacer(),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          const Icon(Icons.shuffle, size: 30),
          const Icon(Icons.skip_previous, size: 50),
          IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.blueAccent), onPressed: () {
            isPlaying ? _player.pause() : _player.resume();
            setState(() => isPlaying = !isPlaying);
            Navigator.pop(context);
          }),
          const Icon(Icons.skip_next, size: 50),
          const Icon(Icons.repeat, size: 30),
        ]),
        const Spacer(),
      ]),
    ));
  }
}
