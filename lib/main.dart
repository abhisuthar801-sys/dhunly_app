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
      appBar: AppBar(title: Text("DHUNLY"), backgroundColor: Colors.transparent, elevation: 0, centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 280, height: 280,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Color(0xFF1DB954).withOpacity(0.4), blurRadius: 20)],
                image: DecorationImage(image: NetworkImage("https://picsum.photos/400"), fit: BoxFit.cover),
              ),
            ),
            SizedBox(height: 40),
            Text("Spotify Style Stream", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            Text("By Dhunly App", style: TextStyle(color: Colors.grey, fontSize: 16)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: StreamBuilder<Duration?>(
                stream: _player.positionStream,
                builder: (context, snapshot) {
                  return ProgressBar(
                    progress: snapshot.data ?? Duration.zero,
                    total: _player.duration ?? Duration.zero,
                    progressBarColor: Color(0xFF1DB954),
                    baseBarColor: Colors.white24,
                    onSeek: (duration) => _player.seek(duration),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                StreamBuilder<PlayerState>(
                  stream: _player.playerStateStream,
                  builder: (context, snapshot) {
                    final playing = snapshot.data?.playing ?? false;
                    return IconButton(
                      iconSize: 80,
                      icon: Icon(playing ? Icons.pause_circle : Icons.play_circle, color: Color(0xFF1DB954)),
                      onPressed: playing ? _player.pause : _player.play,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
