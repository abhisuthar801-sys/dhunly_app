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
  int currentIndex = 0;

  // AAPKI PREMIUM PLAYLIST
  final List<Map<String, String>> playlist = [
    {
      "title": "Temporary Pyar",
      "artist": "Kaka",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3",
      "img": "https://i.ibb.co/v3mX9Dq/album1.jpg"
    },
    {
      "title": "295 - High Energy",
      "artist": "Sidhu Moose Wala",
      "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3",
      "img": "https://www.w3schools.com/w3images/workshop.jpg"
    }
  ];

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
          // Background Glow (FIXED VERSION)
          Positioned(
            top: -50, 
            left: -50, 
            child: Container(
              width: 250, 
              height: 250, 
              decoration: BoxDecoration(
                shape: BoxShape.circle, 
                boxShadow: [
                  BoxShadow(
                    color: Colors.greenAccent.withOpacity(0.2),
                    blurRadius: 100,
                    spreadRadius: 50
                  )
                ]
              )
            )
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                SizedBox(height: 20),
                _buildAlbumArt(song['img']!),
                SizedBox(height: 20),
                _buildSongInfo(song['title']!, song['artist']!),
                _buildSeekBar(),
                _buildControls(),
                Expanded(child: _buildPlaylistSection()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Text("DHUNLY PRO", style: TextStyle(letterSpacing: 4, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
    );
  }

  Widget _buildAlbumArt(String img) {
    return Container(
      height: 250, width: 250,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover),
        boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 15)]
      ),
    );
  }

  Widget _buildSongInfo(String title, String artist) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(artist, style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  Widget _buildSeekBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        children: [
          Slider(
            activeColor: Colors.greenAccent,
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
        IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: () {
          if(currentIndex > 0) setState(() => currentIndex--);
        }),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
          iconSize: 70, color: Colors.greenAccent,
          onPressed: () => isPlaying ? _player.pause() : playMusic(playlist[currentIndex]['url']!),
        ),
        IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: () {
          if(currentIndex < playlist.length - 1) setState(() => currentIndex++);
        }),
      ],
    );
  }

  Widget _buildPlaylistSection() {
    return ListView.builder(
      itemCount: playlist.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: Icon(Icons.music_note, color: Colors.greenAccent),
          title: Text(playlist[index]['title']!),
          subtitle: Text(playlist[index]['artist']!),
          onTap: () {
            setState(() => currentIndex = index);
            playMusic(playlist[index]['url']!);
          },
        );
      },
    );
  }
}
