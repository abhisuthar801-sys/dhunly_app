import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(DhunlySpotify());

class DhunlySpotify extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SpotifyHome(),
    );
  }
}

class SpotifyHome extends StatefulWidget {
  @override
  _SpotifyHomeState createState() => _SpotifyHomeState();
}

class _SpotifyHomeState extends State<SpotifyHome> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  int currentIndex = 0;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // Cloudinary Config (Aapka Cloud Name)
  final String cloudName = "ds1bcvkop";
  List<Map<String, String>> songs = [];
  List<Map<String, String>> filteredSongs = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // 50 Songs generated automatically
    songs = List.generate(50, (index) => {
      "title": "Song ${index + 1}",
      "artist": "Trending Artist",
      "url": "https://res.cloudinary.com/$cloudName/video/upload/dhunly_songs/song${index + 1}.mp3",
      "img": "https://res.cloudinary.com/$cloudName/image/upload/dhunly_songs/poster${index + 1}.jpg"
    });
    filteredSongs = songs;

    _audioPlayer.onDurationChanged.listen((d) => setState(() => duration = d));
    _audioPlayer.onPositionChanged.listen((p) => setState(() => position = p));
    _audioPlayer.onPlayerComplete.listen((event) => nextSong());
  }

  void playMusic(int index) async {
    setState(() => currentIndex = index);
    await _audioPlayer.stop();
    await _audioPlayer.play(UrlSource(songs[index]['url']!));
    setState(() => isPlaying = true);
  }

  void nextSong() => playMusic((currentIndex + 1) % songs.length);
  void prevSong() => playMusic((currentIndex - 1 + songs.length) % songs.length);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Glows
          Positioned(top: -150, left: -100, child: _glowCircle(Colors.blueAccent)),
          Positioned(bottom: -150, right: -100, child: _glowCircle(Colors.purpleAccent)),

          SafeArea(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
              child: Column(
                children: [
                  _header(),
                  _searchBar(),
                  _featuredCard(),
                  _songListHeader(),
                  _songList(),
                  if (isPlaying || position > Duration.zero) _miniPlayer(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _bottomNav(),
    );
  }

  Widget _glowCircle(Color color) => Container(width: 400, height: 400, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 200, spreadRadius: 100)]));

  Widget _header() => Padding(
    padding: EdgeInsets.all(20),
    child: Row(children: [Text("Good Evening", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold))]),
  );

  Widget _searchBar() => Padding(
    padding: EdgeInsets.symmetric(horizontal: 20),
    child: TextField(
      onChanged: (v) => setState(() => filteredSongs = songs.where((s) => s['title']!.toLowerCase().contains(v.toLowerCase())).toList()),
      decoration: InputDecoration(
        hintText: "Search songs, artists...",
        prefixIcon: Icon(Icons.search),
        filled: true,
        fillColor: Colors.white10,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      ),
    ),
  );

  Widget _featuredCard() => Container(
    margin: EdgeInsets.all(20),
    height: 150,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.4), Colors.transparent]),
      border: Border.all(color: Colors.white10),
    ),
    child: Row(
      children: [
        Padding(padding: EdgeInsets.all(15), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(songs[currentIndex]['img']!, width: 120, height: 120, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.music_note, size: 80)))),
        Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("NOW PLAYING", style: TextStyle(letterSpacing: 2, fontSize: 10, color: Colors.blueAccent)),
          Text(songs[currentIndex]['title']!, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), maxLines: 1),
          Text(songs[currentIndex]['artist']!, style: TextStyle(color: Colors.white70)),
        ]))
      ],
    ),
  );

  Widget _songListHeader() => Padding(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), child: Row(children: [Text("Your Library", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))]));

  Widget _songList() => Expanded(
    child: ListView.builder(
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(filteredSongs[index]['img']!, width: 50, height: 50, fit: BoxFit.cover, errorBuilder: (c,e,s) => Icon(Icons.music_video))),
        title: Text(filteredSongs[index]['title']!),
        subtitle: Text(filteredSongs[index]['artist']!),
        onTap: () => playMusic(songs.indexOf(filteredSongs[index])),
      ),
    ),
  );

  Widget _miniPlayer() => Container(
    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    padding: EdgeInsets.all(10),
    decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.white10)),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(songs[currentIndex]['img']!, width: 45, height: 45, fit: BoxFit.cover)),
            SizedBox(width: 15),
            Expanded(child: Text(songs[currentIndex]['title']!, style: TextStyle(fontWeight: FontWeight.bold))),
            IconButton(icon: Icon(Icons.skip_previous), onPressed: prevSong),
            IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () { if(isPlaying) _audioPlayer.pause(); else _audioPlayer.resume(); setState(() => isPlaying = !isPlaying); }),
            IconButton(icon: Icon(Icons.skip_next), onPressed: nextSong),
          ],
        ),
        LinearProgressIndicator(value: position.inSeconds / (duration.inSeconds > 0 ? duration.inSeconds : 1), backgroundColor: Colors.white10, valueColor: AlwaysStoppedAnimation(Colors.blueAccent)),
      ],
    ),
  );

  Widget _bottomNav() => BottomNavigationBar(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.white30,
    items: [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
    ],
  );
}
