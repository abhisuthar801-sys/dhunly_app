import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

void main() => runApp(DhunlyApp());

class DhunlyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyHome(),
    );
  }
}

class DhunlyHome extends StatefulWidget {
  @override
  _DhunlyHomeState createState() => _DhunlyHomeState();
}

class _DhunlyHomeState extends State<DhunlyHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode yt = YoutubeExplode();
  
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // --- YOUTUBE PLAYLIST (Yahan se ID badal sakte ho) ---
  final List<Map<String, String>> songs = [
    {"title": "Pasoori", "artist": "Ali Sethi", "id": "5Eqb_-j3FDA", "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/maxresdefault.jpg"},
    {"title": "295", "artist": "Sidhu Moose Wala", "id": "n_Wce6z38ps", "img": "https://i.ytimg.com/vi/n_Wce6z38ps/maxresdefault.jpg"},
    {"title": "Elevated", "artist": "Shubh", "id": "mH7-K8nSIsU", "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/maxresdefault.jpg"},
    {"title": "Softly", "artist": "Karan Aujla", "id": "cWMXkGuV_Sg", "img": "https://i.ytimg.com/vi/cWMXkGuV_Sg/maxresdefault.jpg"},
    {"title": "California Love", "artist": "Cheema Y", "id": "I3_Xz9is_R0", "img": "https://i.ytimg.com/vi/I3_Xz9is_R0/maxresdefault.jpg"},
    {"title": "White Brown Black", "artist": "Avvy Sra", "id": "VIsasL-LdSc", "img": "https://i.ytimg.com/vi/VIsasL-LdSc/maxresdefault.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) => nextSong());
  }

  Future<void> playYoutubeAudio(int index) async {
    setState(() {
      currentIndex = index;
      isLoading = true;
    });

    try {
      await _audioPlayer.stop();
      // YouTube se Audio link nikalne ka magic
      var manifest = await yt.videos.streamsClient.getManifest(songs[index]['id']);
      var audioStream = manifest.audioOnly.withHighestBitrate();
      
      await _audioPlayer.play(UrlSource(audioStream.url.toString()));
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: YouTube Link not working!")));
    }
  }

  void nextSong() => playYoutubeAudio((currentIndex + 1) % songs.length);
  void prevSong() => playYoutubeAudio((currentIndex - 1 + songs.length) % songs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Glass Effect Background
          Positioned(top: -100, left: -50, child: _glow(Colors.redAccent)),
          Positioned(bottom: -100, right: -50, child: _glow(Colors.orangeAccent)),
          
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
              child: Column(
                children: [
                  _appBar(),
                  _featuredPlayer(),
                  _playlistSection(),
                ],
              ),
            ),
          ),
          if (isLoading) _loadingOverlay(),
        ],
      ),
    );
  }

  Widget _glow(Color c) => Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 150, spreadRadius: 50)]));

  Widget _appBar() => Padding(padding: EdgeInsets.all(20), child: Row(children: [Text("DHUNLY YOUTUBE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Colors.white70))]));

  Widget _featuredPlayer() => Container(
    margin: EdgeInsets.all(20),
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.white10)),
    child: Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(songs[currentIndex]['img']!, height: 180, width: double.infinity, fit: BoxFit.cover)),
        SizedBox(height: 15),
        Text(songs[currentIndex]['title']!, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        Text(songs[currentIndex]['artist']!, style: TextStyle(color: Colors.white54)),
        Slider(
          activeColor: Colors.redAccent,
          value: position.inSeconds.toDouble(),
          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
          onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt())),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: prevSong),
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.redAccent),
              onPressed: () {
                if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
            IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: nextSong),
          ],
        )
      ],
    ),
  );

  Widget _playlistSection() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 5),
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(songs[index]['img']!, width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(songs[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(songs[index]['artist']!),
        trailing: Icon(Icons.play_arrow, color: Colors.white24),
        onTap: () => playYoutubeAudio(index),
      ),
    ),
  );

  Widget _loadingOverlay() => Container(
    color: Colors.black54,
    child: Center(
      child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.redAccent, size: 60),
    ),
  );
}
