import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui'; // Glass effect ke liye

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SpotifyGlassApp(),
    ));

class SpotifyGlassApp extends StatefulWidget {
  @override
  _SpotifyGlassAppState createState() => _SpotifyGlassAppState();
}

class _SpotifyGlassAppState extends State<SpotifyGlassApp> {
  final AudioPlayer _player = AudioPlayer();
  int _currentIndex = 0;
  List allSongs = [];
  List filteredSongs = [];
  var currentSong;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    
    // Seekbar aur Auto-next ka logic
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerComplete.listen((event) => playNext());
  }

  fetchSongs() async {
    String url = "https://pastebin.com/raw/S67v8v0Q"; // APNA LINK YAHAN RAKHO
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          allSongs = data['songs'];
          filteredSongs = allSongs;
        });
      }
    } catch (e) { print(e); }
  }

  void playMusic(song) async {
    await _player.stop();
    await _player.play(UrlSource(song['url']));
    setState(() { currentSong = song; isPlaying = true; });
  }

  void playNext() {
    int index = allSongs.indexOf(currentSong);
    if (index < allSongs.length - 1) playMusic(allSongs[index + 1]);
    else playMusic(allSongs[0]);
  }

  void playPrevious() {
    int index = allSongs.indexOf(currentSong);
    if (index > 0) playMusic(allSongs[index - 1]);
    else playMusic(allSongs.last);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Decor (Gradients)
          Positioned(top: -100, left: -50, child: CircleAvatar(radius: 150, backgroundColor: Colors.green.withOpacity(0.2))),
          Positioned(bottom: -100, right: -50, child: CircleAvatar(radius: 150, backgroundColor: Colors.blue.withOpacity(0.2))),
          
          // Main Content
          _currentIndex == 0 ? buildHome() : _currentIndex == 1 ? buildSearch() : buildLibrary(),

          // Bottom Glass Player
          if (currentSong != null) buildGlassPlayer(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        backgroundColor: Colors.black.withOpacity(0.8),
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
          BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
        ],
      ),
    );
  }

  Widget buildHome() {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(20),
            child: Text("Good Evening", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: allSongs.length,
              itemBuilder: (context, i) => glassListTile(allSongs[i]),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearch() {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(15),
            child: TextField(
              onChanged: (v) => setState(() => filteredSongs = allSongs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList()),
              decoration: InputDecoration(hintText: "Search artist, songs...", filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
          Expanded(child: ListView.builder(itemCount: filteredSongs.length, itemBuilder: (context, i) => glassListTile(filteredSongs[i]))),
        ],
      ),
    );
  }

  Widget buildLibrary() {
    return Center(child: Text("Premium Library\nComing Soon", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 18)));
  }

  Widget glassListTile(song) {
    return ListTile(
      onTap: () => playMusic(song),
      leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(song['img'], width: 50, height: 50, fit: BoxFit.cover)),
      title: Text(song['title'], style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(song['artist'], style: TextStyle(color: Colors.grey)),
      trailing: Icon(Icons.more_vert),
    );
  }

  Widget buildGlassPlayer() {
    return Positioned(
      bottom: 10, left: 10, right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 130,
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Column(
              children: [
                Row(
                  children: [
                    Image.network(currentSong['img'], width: 45, height: 45),
                    SizedBox(width: 10),
                    Expanded(child: Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold))),
                    IconButton(icon: Icon(Icons.skip_previous), onPressed: playPrevious),
                    IconButton(icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 40, color: Colors.greenAccent), onPressed: () { if(isPlaying) _player.pause(); else _player.resume(); setState(() => isPlaying = !isPlaying); }),
                    IconButton(icon: Icon(Icons.skip_next), onPressed: playNext),
                  ],
                ),
                Slider(
                  activeColor: Colors.greenAccent,
                  inactiveColor: Colors.white24,
                  value: position.inSeconds.toDouble(),
                  max: duration.inSeconds.toDouble(),
                  onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
