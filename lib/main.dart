import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyPro()));

class DhunlyPro extends StatefulWidget {
  const DhunlyPro({super.key});
  @override
  State<DhunlyPro> createState() => _DhunlyProState();
}

class _DhunlyProState extends State<DhunlyPro> { // Yahan fix kiya gaya hai
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) => setState(() => duration = d));
    player.onPositionChanged.listen((p) => setState(() => position = p));
    player.onPlayerComplete.listen((event) => setState(() => isPlaying = false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F1E),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                width: 250, height: 250,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 8),
                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 30)],
                ),
                child: const Icon(Icons.music_note, size: 120, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 50),
            const Text("Dhunly Premium", style: TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Streaming Online Track", style: TextStyle(color: Colors.white70, fontSize: 16)),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Slider(
                activeColor: Colors.blueAccent,
                inactiveColor: Colors.white24,
                min: 0,
                max: duration.inSeconds.toDouble(),
                value: position.inSeconds.toDouble(),
                onChanged: (value) async {
                  final seekPosition = Duration(seconds: value.toInt());
                  await player.seek(seekPosition);
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous, size: 45, color: Colors.white), onPressed: () {}),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () async {
                    if (isPlaying) {
                      await player.pause();
                    } else {
                      await player.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
                    }
                    setState(() => isPlaying = !isPlaying);
                  },
                  child: CircleAvatar(
                    radius: 40, backgroundColor: Colors.blueAccent,
                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.skip_next, size: 45, color: Colors.white), onPressed: () {}),
              ],
            ),
            
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.volume_down, color: Colors.white54),
                SizedBox(
                  width: 150,
                  child: Slider(
                    value: 0.5,
                    onChanged: (v) => player.setVolume(v),
                    activeColor: Colors.white54,
                  ),
                ),
                const Icon(Icons.volume_up, color: Colors.white54),
              ],
            )
          ],
        ),
      ),
    );
  }
}
