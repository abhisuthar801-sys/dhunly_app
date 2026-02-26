import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

void main() => runApp(DhunlyUltimate());

class DhunlyUltimate extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: MusicHome(),
    );
  }
}

class MusicHome extends StatefulWidget {
  @override
  _MusicHomeState createState() => _MusicHomeState();
}

class _MusicHomeState extends State<MusicHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode yt = YoutubeExplode();
  
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // --- AAPKI PLAYLIST ---
  final List<Map<String, String>> allSongs = [
    {"title": "Pasoori", "artist": "Ali Sethi", "id": "5Eqb_-j3FDA", "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/maxresdefault.jpg"},
    {"title": "295", "artist": "Sidhu Moose Wala", "id": "n_Wce6z38ps", "img": "https://i.ytimg.com/vi/n_Wce6z38ps/maxresdefault.jpg"},
    {"title": "Elevated", "artist": "Shubh", "id": "mH7-K8nSIsU", "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/maxresdefault.jpg"},
    {"title": "Softly", "artist": "Karan Aujla", "id": "cWMXkGuV_Sg", "img": "https://i.ytimg.com/vi/cWMXkGuV_Sg/maxresdefault.jpg"},
    {"title": "Kesariya", "artist": "Arijit Singh", "id": "BddP6PYo2gs", "img": "https://i.ytimg.com/vi/BddP6PYo2gs/maxresdefault.jpg"},
    {"title": "Check It Out", "artist": "Parmish Verma", "id": "572_77_IcsM", "img": "https://i.ytimg.com/vi/572_77_IcsM/maxresdefault.jpg"},
  ];

  List<Map<String, String>> displayedSongs = [];

  @override
  void initState() {
    super.initState();
    displayedSongs = allSongs;
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) => nextSong());
  }

  void filterSearch(String query) {
    setState(() {
      displayedSongs = allSongs
          .where((song) => song['title']!.toLowerCase().contains(query.toLowerCase()) || 
                           song['artist']!.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> playYoutubeAudio(int index) async {
    setState(() {
      currentIndex = index;
      isLoading = true;
    });

    try {
      await _audioPlayer.stop();
      // YouTube se audio nikalne ka system
      var manifest = await yt.videos.streamsClient.getManifest(allSongs[index]['id']!);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      
      await _audioPlayer.play(UrlSource(audioStream.url.toString()));
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      print("Error fetching YouTube audio: $e");
    }
  }

  void nextSong() => playYoutubeAudio((currentIndex + 1) % allSongs.length);
  void prevSong() => playYoutubeAudio((currentIndex - 1 + allSongs.length) % allSongs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow Effect
          Positioned(top: -100, left: -50, child: _glow(Colors.greenAccent)),
          Positioned(bottom: -100, right: -50, child: _glow(Colors.blueAccent)),
          
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Column(
                children: [
                  _searchHeader(),
                  _nowPlayingCard(),
                  _songListHeader(),
                  _songListSection(),
                ],
              ),
            ),
          ),
          // Jab gaana load ho raha ho
          if (isLoading) _fullScreenLoader(),
        ],
      ),
    );
  }

  Widget _glow(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 150, spreadRadius: 50)]));

  Widget _searchHeader() => Padding(
    padding: EdgeInsets.all(20),
    child: TextField(
      onChanged: filterSearch,
      decoration: InputDecoration(
        hintText: "Search songs or artists...",
        prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _nowPlayingCard() => Container(
    margin: EdgeInsets.symmetric(horizontal: 20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.05),
      borderRadius: BorderRadius.circular(30),
      border: Border.all(color: Colors.white10),
    ),
    child: Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(allSongs[currentIndex]['img']!, height: 140, width: double.infinity, fit: BoxFit.cover)),
        SizedBox(height: 15),
        Text(allSongs[currentIndex]['title']!, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text(allSongs[currentIndex]['artist']!, style: TextStyle(color: Colors.white54)),
        Slider(
          activeColor: Colors.greenAccent,
          value: position.inSeconds.toDouble(),
          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
          onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.skip_previous, size: 35), onPressed: prevSong),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 60, color: Colors.greenAccent),
              onPressed: () {
                if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
            IconButton(icon: Icon(Icons.skip_next, size: 35), onPressed: nextSong),
          ],
        )
      ],
    ),
  );

  Widget _songListHeader() => Padding(
    padding: EdgeInsets.only(left: 25, top: 20, bottom: 10),
    child: Align(alignment: Alignment.centerLeft, child: Text("Your Playlist", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.greenAccent))),
  );

  Widget _songListSection() => Expanded(
    child: ListView.builder(
      itemCount: displayedSongs.length,
      itemBuilder: (context, index) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 25),
        leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(displayedSongs[index]['img']!, width: 45, height: 45, fit: BoxFit.cover)),
        title: Text(displayedSongs[index]['title']!),
        subtitle: Text(displayedSongs[index]['artist']!),
        onTap: () => playYoutubeAudio(allSongs.indexOf(displayedSongs[index])),
      ),
    ),
  );

  Widget _fullScreenLoader() => Container(
    color: Colors.black87,
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.staggeredDotsWave(color: Colors.greenAccent, size: 60),
          SizedBox(height: 20),
          Text("Fetching from YouTube...", style: TextStyle(color: Colors.greenAccent, letterSpacing: 1.2)),
        ],
      ),
    ),
  );
}
