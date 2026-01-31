import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlySpotify()));

class DhunlySpotify extends StatefulWidget {
  const DhunlySpotify({super.key});
  @override
  State<DhunlySpotify> createState() => _DhunlySpotifyState();
}

class _DhunlySpotifyState extends State<DhunlySpotify> {
  final player = AudioPlayer();
  final yt = YoutubeExplode();
  bool isPlaying = false;
  bool isLoading = false;
  String currentTitle = "Search a song to play";
  String currentArtist = "";

  // Search function jo YouTube se link layega
  Future<void> searchAndPlay(String query) async {
    setState(() => isLoading = true);
    try {
      // 1. YouTube par gaana dhoondo
      var searchList = await yt.search.getVideos(query);
      if (searchList.isNotEmpty) {
        var video = searchList.first;
        currentTitle = video.title;
        currentArtist = video.author;

        // 2. Audio stream ka link nikalo
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var audioStream = manifest.audioOnly.withHighestBitrate();

        // 3. Gaana bajao
        await player.play(UrlSource(audioStream.url.toString()));
        setState(() {
          isPlaying = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      print("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.withOpacity(0.5), Colors.black],
          ),
        ),
        child: Column(
          children: [
            const SizedBox(height: 60),
            const Text("Dhunly Online", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
            
            // Spotify Style Search Bar
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: TextField(
                onSubmitted: (value) => searchAndPlay(value),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search any song (Spotify Style)...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                ),
              ),
            ),

            const Spacer(),
            
            // Loading Spinner
            if (isLoading) const CircularProgressIndicator(color: Colors.green),

            // Music Info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Text(currentTitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(currentArtist, style: const TextStyle(color: Colors.white70, fontSize: 16)),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Player Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(icon: const Icon(Icons.shuffle, color: Colors.white54), onPressed: () {}),
                IconButton(icon: const Icon(Icons.skip_previous, size: 40, color: Colors.white), onPressed: () {}),
                GestureDetector(
                  onTap: () {
                    if (isPlaying) { player.pause(); } else { player.resume(); }
                    setState(() => isPlaying = !isPlaying);
                  },
                  child: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.white),
                ),
                IconButton(icon: const Icon(Icons.skip_next, size: 40, color: Colors.white), onPressed: () {}),
                IconButton(icon: const Icon(Icons.repeat, color: Colors.white54), onPressed: () {}),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
