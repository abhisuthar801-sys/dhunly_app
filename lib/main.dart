import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProMaster(),
    ));

class DhunlyProMaster extends StatefulWidget {
  @override
  _DhunlyProMasterState createState() => _DhunlyProMasterState();
}

class _DhunlyProMasterState extends State<DhunlyProMaster> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isRepeat = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  
  // YAHAN APNI SITE KE MP3 LINKS DAALEIN
  final List<Map<String, String>> allSongs = [
    {
      "title": "Temporary Pyar",
      "artist": "Kaka",
      "img": "https://i.ibb.co/v3mX9Dq/album1.jpg",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"
    },
    {
      "title": "295 - High Base",
      "artist": "Sidhu Moose Wala",
      "img": "https://i.ibb.co/yYyYyYy/album2.jpg",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"
    },
    {
      "title": "Lifestyle",
      "artist": "Karan Aujla",
      "img": "https://www.w3schools.com/w3images/workshop.jpg",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3"
    }
  ];

  List<Map<String, String>> filteredSongs = [];

  @override
  void initState() {
    super.initState();
    filteredSongs = allSongs;
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerComplete.listen((event) => nextSong());
  }

  void playMusic(int index) async {
    setState(() => currentIndex = index);
    await _player.play(UrlSource(allSongs[index]['url']!));
    setState(() => isPlaying = true);
  }

  void nextSong() {
    if (currentIndex < allSongs.length - 1) playMusic(currentIndex + 1);
  }

  void prevSong() {
    if (currentIndex > 0) playMusic(currentIndex - 1);
  }

  String formatTime(Duration d) => d.inMinutes.remainder(60).toString().padLeft(2, '0') + ":" + d.inSeconds.remainder(60).toString().padLeft(2, '0');

  @override
  Widget build(BuildContext context) {
    var song = allSongs[currentIndex];
    return Scaffold(
      body: Stack(
        children: [
          // Background Glow Effect
          Container(color: Colors.black),
          Positioned(top: -50, left: -50, child: _glow(Colors.greenAccent)),
          Positioned(bottom: -50, right: -50, child: _glow(Colors.blueAccent)),
          
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
            child: SafeArea(
              child: Column(
                children: [
                  _header(),
                  _searchBar(),
                  _mainCard(song),
                  _seekBar(),
                  _playerControls(),
                  Expanded(child: _playlistView()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _glow(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.15)));

  Widget _header() => Padding(padding: EdgeInsets.all(20), child: Text("DHUNLY PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4, color: Colors.greenAccent)));

  Widget _searchBar() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    child: TextField(
      onChanged: (v) => setState(() => filteredSongs = allSongs.where((s) => s['title']!.toLowerCase().contains(v.toLowerCase())).toList()),
      decoration: InputDecoration(hintText: "Search Songs...", prefixIcon: Icon(Icons.search), filled: true, fillColor: Colors.white10, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none)),
    ),
  );

  Widget _mainCard(Map song) => Container(
    margin: EdgeInsets.all(20), padding: EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
    child: Column(children: [
      ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(song['img'], height: 180, width: double.infinity, fit: BoxFit.cover)),
      SizedBox(height: 15),
      Text(song['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      Text(song['artist'], style: TextStyle(color: Colors.grey)),
    ]),
  );

  Widget _seekBar() => Column(children: [
    Slider(activeColor: Colors.greenAccent, value: position.inSeconds.toDouble(), max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0, onChanged: (v) => _player.seek(Duration(seconds: v.toInt()))),
    Padding(padding: EdgeInsets.symmetric(horizontal: 25), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(formatTime(position)), Text(formatTime(duration))])),
  ]);

  Widget _playerControls() => Row(mainAxisAlignment: MainAxisAlignment.center, children: [
    IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: prevSong),
    SizedBox(width: 20),
    GestureDetector(onTap: () => isPlaying ? _player.pause() : _player.resume(), child: CircleAvatar(radius: 35, backgroundColor: Colors.greenAccent, child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 40))),
    SizedBox(width: 20),
    IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: nextSong),
  ]);

  Widget _playlistView() => ListView.builder(
    itemCount: filteredSongs.length,
    itemBuilder: (context, i) => ListTile(
      leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(filteredSongs[i]['img']!, width: 50, height: 50, fit: BoxFit.cover)),
      title: Text(filteredSongs[i]['title']!),
      subtitle: Text(filteredSongs[i]['artist']!),
      trailing: Icon(Icons.play_arrow, color: Colors.greenAccent),
      onTap: () => playMusic(allSongs.indexOf(filteredSongs[i])),
    ),
  );
}
