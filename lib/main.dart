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
  String currentImg = "https://via.placeholder.com/150";

  // --- CLOUDINARY CONFIGURATION ---
  // Bhai yahan apna Cloudinary 'Cloud Name' daal dena
  final String cloudName = "your_cloud_name"; 
  final String folderName = "dhunly_songs";

  // Aapke gaano ki list (Cloudinary ke hisab se)
  final List<Map<String, String>> songs = List.generate(20, (index) => {
    "title": "Song ${index + 1}",
    "artist": "Cloud Artist",
    "url": "https://res.cloudinary.com/your_cloud_name/video/upload/dhunly_songs/song${index + 1}.mp3",
    "img": "https://res.cloudinary.com/your_cloud_name/image/upload/dhunly_songs/poster${index + 1}.jpg"
  });

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) => setState(() => isPlaying = false));
  }

  void playMusic(String url, String title, String artist, String img) async {
    await _audioPlayer.play(UrlSource(url));
    setState(() {
      isPlaying = true;
      currentTitle = title;
      currentArtist = artist;
      currentImg = img;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade900, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Glassmorphism Content
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Text("DHUNLY PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 2)),
                  ),
                  
                  // Main Player Card
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.network(currentImg, height: 180, width: 180, fit: BoxFit.cover),
                        ),
                        SizedBox(height: 20),
                        Text(currentTitle, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text(currentArtist, style: TextStyle(color: Colors.white70)),
                        Slider(
                          value: position.inSeconds.toDouble(),
                          max: duration.inSeconds.toDouble(),
                          onChanged: (value) => _audioPlayer.seek(Duration(seconds: value.toInt())),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: () {}),
                            IconButton(
                              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 60, color: Colors.blueAccent),
                              onPressed: () {
                                if (isPlaying) { _audioPlayer.pause(); } else { _audioPlayer.resume(); }
                                setState(() => isPlaying = !isPlaying);
                              },
                            ),
                            IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: () {}),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Song List
                  Expanded(
                    child: ListView.builder(
                      itemCount: songs.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          leading: CircleAvatar(backgroundImage: NetworkImage(songs[index]['img']!)),
                          title: Text(songs[index]['title']!),
                          subtitle: Text(songs[index]['artist']!),
                          trailing: Icon(Icons.play_arrow_outlined),
                          onTap: () => playMusic(songs[index]['url']!, songs[index]['title']!, songs[index]['artist']!, songs[index]['img']!),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
