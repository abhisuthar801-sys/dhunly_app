import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  theme: ThemeData.dark(),
  home: DhunlyPremium(),
));

class DhunlyPremium extends StatefulWidget {
  @override
  _DhunlyPremiumState createState() => _DhunlyPremiumState();
}

class _DhunlyPremiumState extends State<DhunlyPremium> {
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
    if (query.isEmpty) return;
    setState(() => isLoading = true);
    try {
      var searchList = await yt.search.search(query);
      if (searchList.isNotEmpty) {
        var video = searchList.first;
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var url = manifest.audioOnly.withHighestBitrate().url;

        await _player.play(UrlSource(url.toString()));
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glow
          Positioned(top: -100, left: -100, child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.greenAccent.withOpacity(0.15), blurRadius: 100))),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.all(20),
                  child: Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
                ),
                _buildSearchField(),
                if (isLoading) LinearProgressIndicator(color: Colors.greenAccent),
                Expanded(child: _buildPlayerUI()),
                if (currentSong != null) _buildMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onSubmitted: (v) => searchAndPlay(v),
        decoration: InputDecoration(
          hintText: "Search any song...",
          prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildPlayerUI() {
    if (currentSong == null) return Center(child: Text("Kaka, Sidhu ya Divine search karo!"));
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 30),
          ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(currentSong['img'], height: 250, width: 250, fit: BoxFit.cover)),
          SizedBox(height: 20),
          Text(currentSong['title'], style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          Text(currentSong['artist'], style: TextStyle(color: Colors.grey)),
          Slider(
            activeColor: Colors.greenAccent,
            value: position.inSeconds.toDouble(),
            max: duration.inSeconds.toDouble() > 0 ? duration.inSeconds.toDouble() : 1.0,
            onChanged: (v) => _player.seek(Duration(seconds: v.toInt())),
          ),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.greenAccent),
            onPressed: () => isPlaying ? _player.pause() : _player.resume(),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      height: 70,
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'])),
        title: Text(currentSong['title'], maxLines: 1),
        trailing: IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () => isPlaying ? _player.pause() : _player.resume()),
      ),
    );
  }
}
