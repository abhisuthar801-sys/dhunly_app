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
  
  // Current Song Details
  String currentTitle = "Select a Song";
  String currentArtist = "Dhunly Pro Player";
  String currentImg = "https://res.cloudinary.com/ds1bcvkop/image/upload/dhunly_songs/poster1.jpg";

  // --- AAPKA CLOUDINARY CONFIG ---
  final String cloudName = "ds1bcvkop"; 
  final String folderName = "dhunly_songs";

  // Ye loop automatically 20 gaane taiyar kar dega (Aap ise badha bhi sakte ho)
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
      print("Error playing audio: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Glows
          Container(color: Colors.black),
          Positioned(top: -100, left: -50, child: _buildGlow(Colors.deepPurple)),
          Positioned(bottom: -100, right: -50, child: _buildGlow(Colors.blueAccent)),

          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
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

  Widget _buildGlow(Color color) => Container(height: 300, width: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.3), blurRadius: 100));

  Widget _buildAppBar() => Padding(padding: EdgeInsets.all(20), child: Text("DHUNLY PRO", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 3, color: Colors.white70)));

  Widget _buildMainPlayerCard() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(currentImg, height: 160, width: 160, fit: BoxFit.cover)),
          SizedBox(height: 15),
          Text(currentTitle, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(currentArtist, style: TextStyle(color: Colors.white54)),
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
              IconButton(icon: Icon(Icons.skip_previous, size: 35), onPressed: () {}),
              GestureDetector(
                onTap: () {
                  if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
                  setState(() => isPlaying = !isPlaying);
                },
                child: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.blueAccent),
              ),
              IconButton(icon: Icon(Icons.skip_next, size: 35), onPressed: () {}),
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
            contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
            leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(songs[index]['img']!, width: 50, height: 50, fit: BoxFit.cover)),
            title: Text(songs[index]['title']!, style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(songs[index]['artist']!),
            onTap: () => playMusic(songs[index]['url']!, songs[index]['title']!, songs[index]['artist']!, songs[index]['img']!),
          );
        },
      ),
    );
  }
}
