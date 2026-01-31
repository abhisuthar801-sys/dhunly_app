import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyPro()));

class DhunlyPro extends StatefulWidget {
  const DhunlyPro({super.key});
  @override
  State<DhunlyPro> createState() => _DhunlyProState();
}

class _DhunlyProState extends State<DhunlyPro> {
  final player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Playlist Data
  int currentIndex = 0;
  final List<Map<String, String>> playlist = [
    {'title': 'Smooth Jazz', 'artist': 'SoundHelix 1', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Chill Beats', 'artist': 'SoundHelix 2', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Retro Funk', 'artist': 'SoundHelix 3', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
    {'title': 'Modern Pop', 'artist': 'SoundHelix 4', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'},
  ];

  @override
  void initState() {
    super.initState();
    player.onDurationChanged.listen((d) => setState(() => duration = d));
    player.onPositionChanged.listen((p) => setState(() => position = p));
    // Auto-play next song when current ends
    player.onPlayerComplete.listen((event) => nextSong());
  }

  void playCurrent() async {
    await player.stop();
    await player.play(UrlSource(playlist[currentIndex]['url']!));
    setState(() => isPlaying = true);
  }

  void nextSong() {
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      playCurrent();
    }
  }

  void prevSong() {
    if (currentIndex > 0) {
      currentIndex--;
      playCurrent();
    }
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
            const SizedBox(height: 40),
            // Music Disk
            Center(
              child: Container(
                width: 220, height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 8),
                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.2), blurRadius: 30)],
                ),
                child: const Icon(Icons.music_note, size: 100, color: Colors.blueAccent),
              ),
            ),
            const SizedBox(height: 30),
            Text(playlist[currentIndex]['title']!, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
            Text(playlist[currentIndex]['artist']!, style: const TextStyle(color: Colors.white70, fontSize: 16)),
            
            // Progress Slider
            Slider(
              activeColor: Colors.blueAccent,
              inactiveColor: Colors.white24,
              min: 0, max: duration.inSeconds.toDouble(),
              value: position.inSeconds.toDouble(),
              onChanged: (v) => player.seek(Duration(seconds: v.toInt())),
            ),

            // Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous, size: 45, color: Colors.white), onPressed: prevSong),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    if (isPlaying) { player.pause(); } else { playCurrent(); }
                    setState(() => isPlaying = !isPlaying);
                  },
                  child: CircleAvatar(
                    radius: 40, backgroundColor: Colors.blueAccent,
                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow, size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 20),
                IconButton(icon: const Icon(Icons.skip_next, size: 45, color: Colors.white), onPressed: nextSong),
              ],
            ),
            
            // Playlist Preview
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: playlist.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.music_video, color: Colors.white54),
                    title: Text(playlist[index]['title']!, style: TextStyle(color: index == currentIndex ? Colors.blueAccent : Colors.white)),
                    subtitle: Text(playlist[index]['artist']!, style: const TextStyle(color: Colors.white54)),
                    onTap: () {
                      currentIndex = index;
                      playCurrent();
                    },
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
