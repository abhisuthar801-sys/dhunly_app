import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProGlass(),
    ));

class DhunlyProGlass extends StatefulWidget {
  @override
  _DhunlyProGlassState createState() => _DhunlyProGlassState();
}

class _DhunlyProGlassState extends State<DhunlyProGlass> {
  final AudioPlayer _player = AudioPlayer();
  List allSongs = [];
  List filteredSongs = [];
  var currentSong;
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    fetchSongs();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerComplete.listen((event) => playNext());
  }

  fetchSongs() async {
    // APNA PASTEBIN RAW LINK YAHAN DALO
    String url = "https://pastebin.com/raw/S67v8v0Q"; 
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          allSongs = data['songs'];
          filteredSongs = allSongs;
        });
      }
    } catch (e) {
      print("Error fetching songs: $e");
    }
  }

  void playMusic(song) async {
    try {
      await _player.stop();
      await _player.play(UrlSource(song['url']));
      setState(() {
        currentSong = song;
        isPlaying = true;
      });
    } catch (e) {
      print("Playback Error: $e");
      playNext(); // Agar error aaye toh agla gaana
    }
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
          // Background Glows
          Positioned(top: -50, left: -50, child: circleGlow(Colors.deepPurple.withOpacity(0.3))),
          Positioned(bottom: 100, right: -50, child: circleGlow(Colors.greenAccent.withOpacity(0.2))),

          SafeArea(
            child: Column(
              children: [
                buildHeader(),
                Expanded(child: _currentIndex == 1 ? buildSearch() : buildSongList()),
              ],
            ),
          ),
          
          if (currentSong != null) buildGlassPlayer(),
        ],
      ),
      bottomNavigationBar: buildBottomNav(),
    );
  }

  Widget circleGlow(Color color) {
    return Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]));
  }

  Widget buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 1)),
          CircleAvatar(backgroundColor: Colors.white10, child: Icon(Icons.person, color: Colors.white)),
        ],
      ),
    );
  }

  Widget buildSongList() {
    return ListView.builder(
      itemCount: allSongs.length,
      padding: EdgeInsets.only(bottom: 180),
      itemBuilder: (context, i) => songTile(allSongs[i]),
    );
  }

  Widget buildSearch() {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(15),
          child: TextField(
            onChanged: (v) => setState(() => filteredSongs = allSongs.where((s) => s['title'].toLowerCase().contains(v.toLowerCase())).toList()),
            decoration: InputDecoration(hintText: "Search songs, artists...", prefixIcon: Icon(Icons.search), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredSongs.length,
            itemBuilder: (context, i) => songTile(filteredSongs[i]),
          ),
        ),
      ],
    );
  }

  Widget songTile(song) {
    return ListTile(
      onTap: () => playMusic(song),
      leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(song['img'], width: 55, height: 55, fit: BoxFit.cover)),
      title: Text(song['title'], style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(song['artist'], style: TextStyle(color: Colors.grey[400])),
      trailing: Icon(Icons.play_circle_outline, color: Colors.greenAccent),
    );
  }

  Widget buildGlassPlayer() {
    return Positioned(
      bottom: 20, left: 15, right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: Container(
            height: 150,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white.withOpacity(0.1))),
            child: Column(
              children: [
                Row(
                  children: [
                    ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['img'], width: 50, height: 50, fit: BoxFit.cover)),
                    SizedBox(width: 15),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(currentSong['title'], style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis), Text(currentSong['artist'], style: TextStyle(color: Colors.grey, fontSize: 12))])),
                    IconButton(icon: Icon(Icons.skip_previous, size: 30), onPressed: playPrevious),
                    IconButton(icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 50, color: Colors.greenAccent), onPressed: () { if(isPlaying) _player.pause(); else _player.resume(); setState(() => isPlaying = !isPlaying); }),
                    IconButton(icon: Icon(Icons.skip_next, size: 30), onPressed: playNext),
                  ],
                ),
                Slider(activeColor: Colors.greenAccent, inactiveColor: Colors.white24, value: position.inSeconds.toDouble(), max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0, onChanged: (v) => _player.seek(Duration(seconds: v.toInt()))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (i) => setState(() => _currentIndex = i),
      backgroundColor: Colors.black,
      selectedItemColor: Colors.greenAccent,
      unselectedItemColor: Colors.grey,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: [
        BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.search), label: ""),
        BottomNavigationBarItem(icon: Icon(Icons.library_music), label: ""),
      ],
    );
  }
}
