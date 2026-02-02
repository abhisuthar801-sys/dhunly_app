import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlySpotifyGlass(),
    ));

class DhunlySpotifyGlass extends StatefulWidget {
  @override
  _DhunlySpotifyGlassState createState() => _DhunlySpotifyGlassState();
}

class _DhunlySpotifyGlassState extends State<DhunlySpotifyGlass> {
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
    // Seekbar update karne ke liye listeners
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerStateChanged.listen((state) {
      setState(() => isPlaying = state == PlayerState.playing);
    });
  }

  // --- YouTube Search & Play Logic ---
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Gaana nahi mila!")));
    }
  }

  void _togglePlay() {
    if (isPlaying) _player.pause(); else _player.resume();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glows (Modern Look)
          _buildGlow(Colors.blueAccent.withOpacity(0.15), -100, -50),
          _buildGlow(Colors.purpleAccent.withOpacity(0.1), 400, 150),

          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildSearchBar(),
                if (isLoading) LinearProgressIndicator(color: Colors.greenAccent, backgroundColor: Colors.transparent),
                Expanded(child: _buildBody()),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlow(Color color, double top, double left) {
    return Positioned(top: top, left: left, child: Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 120, spreadRadius: 50)])));
  }

  Widget _buildAppBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Pro", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
          IconButton(icon: Icon(Icons.account_circle_outlined, size: 30), onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: TextField(
            onSubmitted: (v) => searchAndPlay(v),
            decoration: InputDecoration(
              hintText: "Search any song from YouTube...",
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

  Widget _buildBody() {
    if (currentSong == null && !isLoading) {
      return Center(child: Text("Search karo aur music ka maza lo!", style: TextStyle(color: Colors.grey)));
    }
    if (currentSong == null) return Container();

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 40),
          // Album Art with Shadow
          Container(
            height: 280, width: 280,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 10))]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.network(currentSong['img'], fit: BoxFit.cover),
            ),
          ),
          SizedBox(height: 30),
          Text(currentSong['title'], style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(currentSong['artist'], style: TextStyle(fontSize: 16, color: Colors.grey)),
          
          SizedBox(height: 30),
          // Seekbar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Slider(
              activeColor: Colors.greenAccent,
              inactiveColor: Colors.white12,
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
              onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
            ),
          ),
          
          // Controls
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(icon: Icon(Icons.shuffle, color: Colors.grey), onPressed: () {}),
              IconButton(icon: Icon(Icons.skip_previous, size: 40), onPressed: () {}),
              IconButton(
                icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 80, color: Colors.greenAccent),
                onPressed: _togglePlay,
              ),
              IconButton(icon: Icon(Icons.skip_next, size: 40), onPressed: () {}),
              IconButton(icon: Icon(Icons.repeat, color: Colors.grey), onPressed: () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Positioned(
      bottom: 20, left: 15, right: 15,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            height: 70,
            color: Colors.white.withOpacity(0.07),
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['img'], width: 50, height: 50, fit: BoxFit.cover)),
                SizedBox(width: 15),
                Expanded(child: Text(currentSong['title'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis)),
                IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: _togglePlay),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
