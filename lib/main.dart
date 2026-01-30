import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() => runApp(MaterialApp(home: DhunlyUniqueApp(), debugShowCheckedModeBanner: false));

class DhunlyUniqueApp extends StatefulWidget {
  @override
  _DhunlyUniqueAppState createState() => _DhunlyUniqueAppState();
}

class _DhunlyUniqueAppState extends State<DhunlyUniqueApp> {
  late AudioPlayer _player;
  final String musicUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer()..setUrl(musicUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(top: -100, left: -50, child: CircleAvatar(radius: 150, backgroundColor: Color(0xFF1DB954).withOpacity(0.15))),
          
          SafeArea(
            child: Column(
              children: [
                // 1. UNIQUE NEON SEARCH BAR
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: TextField(
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Dhoondo apna pasandida music...",
                        hintStyle: TextStyle(color: Colors.white38, fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF1DB954)),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                Spacer(),

                // 2. GLASS-MORPHIC ALBUM ART
                Container(
                  width: 300, height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [BoxShadow(color: Color(0xFF1DB954).withOpacity(0.2), blurRadius: 50, spreadRadius: 2)],
                    image: DecorationImage(image: NetworkImage("https://picsum.photos/400"), fit: BoxFit.cover),
                  ),
                ),

                SizedBox(height: 50),

                // 3. SONG TEXT (UNIQUE STYLE)
                Text("DHUNLY ORIGINAL", style: TextStyle(color: Color(0xFF1DB954), letterSpacing: 4, fontSize: 12, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text("Cloud Streaming v1", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w800)),

                Spacer(),

                // 4. MODERN PROGRESS BAR
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: StreamBuilder<Duration?>(
                    stream: _player.positionStream,
                    builder: (context, snapshot) {
                      return ProgressBar(
                        progress: snapshot.data ?? Duration.zero,
                        total: _player.duration ?? Duration.zero,
                        progressBarColor: Color(0xFF1DB954),
                        baseBarColor: Colors.white10,
                        thumbColor: Colors.white,
                        onSeek: (duration) => _player.seek(duration),
                      );
                    },
                  ),
                ),

                // 5. FLOATING CONTROLS
                Padding(
                  padding: EdgeInsets.only(bottom: 50, top: 20),
                  child: StreamBuilder<PlayerState>(
                    stream: _player.playerStateStream,
                    builder: (context, snapshot) {
                      final playing = snapshot.data?.playing ?? false;
                      return GestureDetector(
                        onTap: playing ? _player.pause : _player.play,
                        child: Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF1DB954),
                            boxShadow: [BoxShadow(color: Color(0xFF1DB954).withOpacity(0.4), blurRadius: 20)],
                          ),
                          child: Icon(playing ? Icons.pause : Icons.play_arrow, color: Colors.black, size: 40),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
