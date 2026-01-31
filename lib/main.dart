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

  int currentIndex = 0;
  // Ye hai aapki Online Playlist
  final List<Map<String, String>> allSongs = [
    {'title': 'Arjan Vailly', 'artist': 'Animal', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'},
    {'title': 'Lofi HipHop', 'artist': 'Chill Study', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'},
    {'title': 'Night Vibes', 'artist': 'Dhunly Mix', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'},
    {'title': 'Morning Energy', 'artist': 'Workout', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-8.mp3'},
    {'title': 'Romantic Hits', 'artist': 'Arijit Style', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-10.mp3'},
  ];

  List<Map<String, String>> displayedSongs = [];

  @override
  void initState() {
    super.initState();
    displayedSongs = allSongs;
    player.onDurationChanged.listen((d) => setState(() => duration = d));
    player.onPositionChanged.listen((p) => setState(() => position = p));
    player.onPlayerComplete.listen((event) => nextSong());
  }

  // Search Function
  void filterSongs(String query) {
    setState(() {
      displayedSongs = allSongs
          .where((song) => song['title']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void playCurrent() async {
    await player.stop();
    await player.play(UrlSource(allSongs[currentIndex]['url']!));
    setState(() => isPlaying = true);
  }

  void nextSong() {
    if (currentIndex < allSongs.length - 1) {
      currentIndex++;
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
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF1A1A2E), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 50),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => filterSongs(value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white10,
                  hintText: "Search your favorite song...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            // Current Playing Info
            Text(allSongs[currentIndex]['title']!, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            
            // Player Controls (Mini)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.skip_previous, color: Colors.white), onPressed: () {}),
                IconButton(
                  icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 50, color: Colors.blueAccent),
                  onPressed: () {
                    if (isPlaying) { player.pause(); } else { playCurrent(); }
                    setState(() => isPlaying = !isPlaying);
                  },
                ),
                IconButton(icon: const Icon(Icons.skip_next, color: Colors.white), onPressed: nextSong),
              ],
            ),

            // Playlist Label
            const Padding(
              padding: EdgeInsets.only(left: 20, top: 10, bottom: 10),
              child: Align(alignment: Alignment.centerLeft, child: Text("Your Playlist", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500))),
            ),

            // Scrollable List
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: displayedSongs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    leading: CircleAvatar(
                      backgroundColor: Colors.blueAccent.withOpacity(0.1),
                      child: const Icon(Icons.music_note, color: Colors.blueAccent),
                    ),
                    title: Text(displayedSongs[index]['title']!, style: const TextStyle(color: Colors.white)),
                    subtitle: Text(displayedSongs[index]['artist']!, style: const TextStyle(color: Colors.white54)),
                    onTap: () {
                      // Find actual index in allSongs
                      setState(() {
                        currentIndex = allSongs.indexOf(displayedSongs[index]);
                        playCurrent();
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
