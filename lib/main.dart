import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyApp(),
    ));

class DhunlyApp extends StatefulWidget {
  @override
  _DhunlyAppState createState() => _DhunlyAppState();
}

class _DhunlyAppState extends State<DhunlyApp> {
  final yt_exp.YoutubeExplode yt = yt_exp.YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();
  
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerStateChanged.listen((s) => setState(() => isPlaying = s == PlayerState.playing));
  }

  void searchAndPlay(String query) async {
    setState(() => isLoading = true);
    try {
      var searchList = await yt.search.search(query);
      if (searchList.isNotEmpty) {
        var video = searchList.first;
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var audioStream = manifest.audioOnly.withHighestBitrate();

        await _player.play(UrlSource(audioStream.url.toString()));
        
        setState(() {
          currentSong = {
            "title": video.title,
            "artist": video.author,
            "img": video.thumbnails.highResUrl,
          };
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
      body: Stack(
        children: [
          _buildGlow(Colors.deepPurple.withOpacity(0.2), -50, -50),
          _buildGlow(Colors.blueAccent.withOpacity(0.1), 400, 100),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                if (isLoading) LinearProgressIndicator(color: Colors.greenAccent, backgroundColor: Colors.transparent),
                Expanded(child: _buildMainView()),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double top, double left) {
    return Positioned(top: top, left: left, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)])));
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Pro", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          CircleAvatar(backgroundColor: Colors.white12, child: Icon(Icons.person, color: Colors.greenAccent)),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            onSubmitted: (v) => searchAndPlay(v),
            style: TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Search song or artist...",
              prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainView() {
    if (currentSong == null) {
      return Center(child: Text("Search karo, gaana bajao!", style: TextStyle(color: Colors.grey)));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ClipRRect(borderRadius: BorderRadius.circular(25), child: Image.network(currentSong['img'], height: 260, width: 260, fit: BoxFit.cover)),
        SizedBox(height: 25),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Text(currentSong['title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2),
        ),
        Text(currentSong['artist'], style: TextStyle(color: Colors.grey)),
        Slider(
          activeColor: Colors.greenAccent,
          value: position.inSeconds.toDouble(),
          max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
          onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
        ),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.greenAccent),
          onPressed: () => isPlaying ? _player.pause() : _player.resume(),
        ),
      ],
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      bottom: 10, left: 10, right: 10,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            height: 65, color: Colors.white10,
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'], width: 45, height: 45, fit: BoxFit.cover)),
                SizedBox(width: 10),
                Expanded(child: Text(currentSong['title'], overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 13))),
                IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () => isPlaying ? _player.pause() : _player.resume()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
