import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'dart:ui';

void main() => runApp(DhunlyUniversal());

class DhunlyUniversal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData.dark(), home: MasterPlayer());
  }
}

class MasterPlayer extends StatefulWidget {
  @override
  _MasterPlayerState createState() => _MasterPlayerState();
}

class _MasterPlayerState extends State<MasterPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final YoutubeExplode yt = YoutubeExplode();
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // --- SAARI LINKS EK SAATH (YouTube ID, Direct MP3, Cloudinary) ---
  final List<Map<String, String>> songs = [
    // --- YouTube Streaming ---
    {"title": "Pasoori", "artist": "Ali Sethi", "type": "yt", "source": "5Eqb_-j3FDA", "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/0.jpg"},
    {"title": "295", "artist": "Sidhu Moose Wala", "type": "yt", "source": "n_Wce6z38ps", "img": "https://i.ytimg.com/vi/n_Wce6z38ps/0.jpg"},
    {"title": "Elevated", "artist": "Shubh", "type": "yt", "source": "mH7-K8nSIsU", "img": "https://i.ytimg.com/vi/mH7-K8nSIsU/0.jpg"},
    
    // --- Direct MP3 Streaming (PagalFree/HighSpeed) ---
    {"title": "Excuses", "artist": "AP Dhillon", "type": "mp3", "source": "https://pagalfree.com/musics/128-Excuses%20-%20AP%20Dhillon%20128%20Kbps.mp3", "img": "https://i.ytimg.com/vi/vX2cDW8LUWk/0.jpg"},
    {"title": "Kesariya", "artist": "Arijit Singh", "type": "mp3", "source": "https://pagalfree.com/musics/128-Kesariya%20-%20Brahmastra%20128%20Kbps.mp3", "img": "https://c.saavncdn.com/191/Kesariya-From-Brahmastra-Hindi-2022-20220717092820-500x500.jpg"},
    
    // --- Cloudinary Streaming (Personal) ---
    {"title": "Cloud Mix", "artist": "Dhunly Cloud", "type": "mp3", "source": "https://res.cloudinary.com/ds1bcvkop/video/upload/dhunly_songs/song1.mp3", "img": "https://res.cloudinary.com/ds1bcvkop/image/upload/dhunly_songs/poster1.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((s) => nextSong());
  }

  Future<void> playStream(int index) async {
    setState(() { currentIndex = index; isLoading = true; });
    try {
      await _audioPlayer.stop();
      String? urlToPlay;

      if (songs[index]['type'] == 'yt') {
        // YouTube logic
        var manifest = await yt.videos.streamsClient.getManifest(songs[index]['source']!);
        urlToPlay = manifest.audioOnly.withHighestBitrate().url.toString();
      } else {
        // Direct MP3 logic
        urlToPlay = songs[index]['source'];
      }

      await _audioPlayer.play(UrlSource(urlToPlay!));
      setState(() { isPlaying = true; isLoading = false; });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Stream Error! Next baj raha hai...")));
      nextSong();
    }
  }

  void nextSong() => playStream((currentIndex + 1) % songs.length);
  void prevSong() => playStream((currentIndex - 1 + songs.length) % songs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _bgGlow(Colors.blueAccent),
          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
              child: Column(
                children: [
                  _header(),
                  _nowPlaying(),
                  _playlist(),
                ],
              ),
            ),
          ),
          if (isLoading) _loadingOverlay(),
        ],
      ),
    );
  }

  Widget _bgGlow(Color c) => Positioned(top: -50, right: -50, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: c.withOpacity(0.2), boxShadow: [BoxShadow(color: c.withOpacity(0.3), blurRadius: 150, spreadRadius: 50)])));

  Widget _header() => Padding(padding: EdgeInsets.all(20), child: Text("DHUNLY WORLD", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueAccent)));

  Widget _nowPlaying() => Container(
    margin: EdgeInsets.all(20), padding: EdgeInsets.all(20),
    decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white10)),
    child: Column(
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(songs[currentIndex]['img']!, height: 140, width: double.infinity, fit: BoxFit.cover)),
        Slider(activeColor: Colors.blueAccent, value: position.inSeconds.toDouble(), max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0, onChanged: (v) => _audioPlayer.seek(Duration(seconds: v.toInt()))),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(icon: Icon(Icons.skip_previous), onPressed: prevSong),
          IconButton(icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, size: 60, color: Colors.blueAccent), onPressed: () {
            if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
            setState(() => isPlaying = !isPlaying);
          }),
          IconButton(icon: Icon(Icons.skip_next), onPressed: nextSong),
        ]),
      ],
    ),
  );

  Widget _playlist() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(songs[index]['img']!, width: 45, height: 45, fit: BoxFit.cover)),
        title: Text(songs[index]['title']!),
        subtitle: Text("${songs[index]['artist']} (${songs[index]['type']!.toUpperCase()})"),
        onTap: () => playStream(index),
      ),
    ),
  );

  Widget _loadingOverlay() => Container(color: Colors.black87, child: Center(child: LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 60)));
}
