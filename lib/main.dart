import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(DhunlyPro());

class DhunlyPro extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MusicPlayerHome(),
    );
  }
}

class MusicPlayerHome extends StatefulWidget {
  @override
  _MusicPlayerHomeState createState() => _MusicPlayerHomeState();
}

class _MusicPlayerHomeState extends State<MusicPlayerHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  
  String currentTitle = "Select a Song";
  String currentArtist = "Dhunly Pro Player";
  String currentImg = "https://res.cloudinary.com/ds1bcvkop/image/upload/dhunly_songs/poster1.jpg";

  final String cloudName = "ds1bcvkop"; 
  final String folderName = "dhunly_songs";

  final List<Map<String, String>> songs = List.generate(20, (index) {
    int id = index + 1;
    return {
      "title": "Super Hit Song $id",
      "artist": "Dhunly Artist",
      "url": "https://res.cloudinary.com/ds1bcvkop/video/upload/dhunly_songs/song$id.mp3",
      "img": "https://res.cloudinary.com/ds1bcvkop/image/upload/dhunly_songs/poster$id.jpg"
    };
  });

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) => setState(() => isPlaying = false));
  }

  void playMusic(String url, String title, String artist, String img) async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(UrlSource(url));
      setState(() {
        isPlaying = true;
        currentTitle = title;
        currentArtist = artist;
        currentImg = img;
      });
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Fixed Glows
          Positioned(top: -100, left: -50, child: _buildGlow(Colors.deepPurple)),
          Positioned(bottom: -100, right: -50, child: _buildGlow(Colors.blueAccent)),

          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Column(
                children: [
                  _buildAppBar(),
                  _buildMainPlayerCard(),
                  _buildSongList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // FIX: blurRadius moved inside BoxShadow
  Widget _buildGlow(Color color) => Container(
    height: 300, 
    width: 300, 
    decoration: BoxDecoration(
      shape: BoxShape.circle, 
      boxShadow: [
        BoxShadow(color: color.withOpacity(0.5), blurRadius: 100, spreadRadius: 50)
      ]
    )
  );

  Widget _buildAppBar() => Padding(
    padding: const EdgeInsets.all(20), 
    child: Text("DHUNLY PRO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white70))
  );

  Widget _buildMainPlayerCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(currentImg, height: 160, width: 160, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.music_note, size: 100))),
          const SizedBox(height: 15),
          Text(currentTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(currentArtist, style: const TextStyle(color: Colors.white54)),
          Slider(
            activeColor: Colors.blueAccent,
            inactiveColor: Colors.white24,
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
            onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: const Icon(Icons.skip_previous, size: 35), onPressed: () {}),
              GestureDetector(
                onTap: () {
                  if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
                  setState(() => isPlaying = !isPlaying);
                },
                child: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.blueAccent),
              ),
              IconButton(icon: const Icon(Icons.skip_next, size: 35), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSongList() {
    return Expanded(
      child: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(songs[index]['img']!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c, e, s) => Icon(Icons.music_video))),
            title: Text(songs[index]['title']!, style: const TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(songs[index]['artist']!),
            onTap: () => playMusic(songs[index]['url']!, songs[index]['title']!, songs[index]['artist']!, songs[index]['img']!),
          );
        },
      ),
    );
  }
}
