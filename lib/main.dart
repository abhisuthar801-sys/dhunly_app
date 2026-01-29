import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() => runApp(MaterialApp(home: DhunlyPlayer(), debugShowCheckedModeBanner: false));

class DhunlyPlayer extends StatefulWidget {
  @override
  _DhunlyPlayerState createState() => _DhunlyPlayerState();
}

class _DhunlyPlayerState extends State<DhunlyPlayer> {
  late AudioPlayer _player;
  // Sample Online Song
  final String musicUrl = "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3";

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.setUrl(musicUrl); 
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF121212),
      appBar: AppBar(
        title: Text("DHUNLY SPOTIFY", style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Album Art
            Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.width * 0.8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Color(0xFF1DB954).withOpacity(0.3), blurRadius: 30)],
                image: DecorationImage(image: NetworkImage("https://picsum.photos/500/500?music"), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 40),
            Text("Streaming Now", style: TextStyle(color: Color(0xFF1DB954), fontSize: 16, fontWeight: FontWeight.bold)),
            Text("Online Track 01", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 30),
            
            // Progress Bar
            StreamBuilder<Duration?>(
              stream: _player.positionStream,
              builder: (context, snapshot) {
                return ProgressBar(
                  progress: snapshot.data ?? Duration.zero,
                  buffered: _player.bufferedPosition,
                  total: _player.duration ?? Duration.zero,
                  progressBarColor: Color(0xFF1DB954),
                  baseBarColor: Colors.white12,
                  thumbColor: Colors.white,
                  onSeek: (duration) => _player.seek(duration),
                );
              },
            ),

            SizedBox(height: 20),

            // Music Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Icon(Icons.shuffle, color: Colors.grey),
                IconButton(icon: Icon(Icons.skip_previous, color: Colors.white, size: 40), onPressed: () {}),
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      icon: Icon(playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: Color(0xFF1DB954), size: 85),
                      onPressed: playing ? _player.pause : _player.play,
                    );
                  },
                ),
                IconButton(icon: Icon(Icons.skip_next, color: Colors.white, size: 40), onPressed: () {}),
                Icon(Icons.repeat, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
