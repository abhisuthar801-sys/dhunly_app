import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyPro(),
    ));

class DhunlyPro extends StatefulWidget {
  @override
  _DhunlyProState createState() => _DhunlyProState();
}

class _DhunlyProState extends State<DhunlyPro> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // AAPKI PLAYLIST (Yahan aap aur gaane add kar sakte hain)
  final List<Map<String, String>> playlist = [
    {
      "title": "Kaka - Temporary Pyar",
      "artist": "Kaka",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "img": "https://i.ibb.co/v3mX9Dq/album1.jpg"
    },
    {
      "title": "Sidhu - 295",
      "artist": "Sidhu Moose Wala",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      "img": "https://i.ibb.co/yYyYyYy/album2.jpg"
    }
  ];

  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => isPlaying = s == PlayerState.playing));
  }

  void playMusic(String url) async {
    await _player.play(UrlSource(url));
  }

  String formatTime(Duration d) {
    return d.inMinutes.remainder(60).toString().padLeft(2, '0') + ":" + 
           d.inSeconds.remainder(60).toString().padLeft(2, '0');
  }

  @override
  Widget build(BuildContext context) {
    var song = playlist[currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(top: -50, left: -50, child: Container(width: 250, height: 250, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withOpacity(0.2), blurRadius: 100))),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                _buildAlbumArt(song['img']!),
                SizedBox(height: 30),
                _buildSongInfo(song['title']!, song['artist']!),
                _buildSeekBar(),
                _buildControls(),
                Spacer(),
                _buildPlaylistSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(Icons.keyboard_arrow_down, size: 30),
          Text("DHUNLY PRO", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
          Icon(Icons.more_vert),
        ],
      ),
    );
  }

  Widget _buildAlbumArt(String img) {
    return Container(
      height: 280, width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, spreadRadius: 5)],
        image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildSongInfo(String title, String artist) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        Text(artist, style: TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSeekBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Slider(
            activeColor: Colors.greenAccent,
            inactiveColor: Colors.white10,
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
            onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatTime(position)),
                Text(formatTime(duration)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: () {}),
        SizedBox(width: 20),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          iconSize: 80,
          color: Colors.greenAccent,
          onPressed: () => isPlaying ? _player.pause() : playMusic(playlist[currentIndex]['url']!),
        ),
        SizedBox(width: 20),
        IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: () {}),
      ],
    );
  }

  Widget _buildPlaylistSection() {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
      ),
      child: ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Image.network(playlist[index]['img']!, width: 40),
            title: Text(playlist[index]['title']!),
            subtitle: Text(playlist[index]['artist']!),
            onTap: () {
              setState(() => currentIndex = index);
              playMusic(playlist[index]['url']!);
            },
          );
        },
      ),
    );
  }
}
