import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:ui';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpotifyProMax(),
    ));

class SpotifyProMax extends StatefulWidget {
  const SpotifyProMax({super.key});
  @override
  State<SpotifyProMax> createState() => _SpotifyProMaxState();
}

class _SpotifyProMaxState extends State<SpotifyProMax> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  // TEST DATA: Gaane ab app ke andar hi hain (Feature Test ke liye)
  List songs = [
    {"title": "Softly", "artist": "Karan Aujla", "img": "https://i.getimg.ai/generated/882/1.jpg", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3"},
    {"title": "Winning Speech", "artist": "Karan Aujla", "img": "https://i.getimg.ai/generated/882/2.jpg", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3"},
    {"title": "Kesariya", "artist": "Arijit Singh", "img": "https://i.getimg.ai/generated/882/3.jpg", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3"},
  ];

  var currentSong;

  @override
  void initState() {
    super.initState();
    currentSong = songs[0];
    
    _player.onDurationChanged.listen((d) => setState(() => duration = d));
    _player.onPositionChanged.listen((p) => setState(() => position = p));
    _player.onPlayerComplete.listen((event) => setState(() => isPlaying = false));
  }

  void playMusic(var s) async {
    await _player.stop();
    await _player.play(UrlSource(s['url']));
    setState(() { currentSong = s; isPlaying = true; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Aesthetic Glow
          Container(height: 300, decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.blueAccent.withOpacity(0.3), Colors.black], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
          
          SafeArea(
            child: Column(
              children: [
                _buildAppBar(),
                _buildCategories(),
                _buildSectionTitle("Made For You"),
                _buildHorizontalList(),
                _buildSectionTitle("Trending Now"),
                _buildVerticalList(),
                _buildModernMiniPlayer(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildAppBar() => Padding(
    padding: const EdgeInsets.all(20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text("Dhunly Pro", style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        Row(children: [
          const Icon(Icons.notifications_none, color: Colors.white),
          const SizedBox(width: 15),
          const Icon(Icons.history, color: Colors.white),
          const SizedBox(width: 15),
          CircleAvatar(radius: 15, backgroundImage: AssetImage("assets/logo.png")),
        ]),
      ],
    ),
  );

  Widget _buildCategories() => Container(
    height: 50,
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: ["Music", "Podcasts", "Punjabi", "Lofi", "Chill"].map((txt) => Container(
        margin: const EdgeInsets.only(left: 15),
        child: Chip(label: Text(txt), backgroundColor: Colors.white10, labelStyle: const TextStyle(color: Colors.white)),
      )).toList(),
    ),
  );

  Widget _buildSectionTitle(String title) => Padding(
    padding: const EdgeInsets.all(15),
    child: Align(alignment: Alignment.centerLeft, child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))),
  );

  Widget _buildHorizontalList() => Container(
    height: 180,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: songs.length,
      itemBuilder: (context, i) => GestureDetector(
        onTap: () => playMusic(songs[i]),
        child: Container(
          width: 140,
          margin: const EdgeInsets.only(left: 15),
          child: Column(children: [
            ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(songs[i]['img'], height: 130, width: 130, fit: BoxFit.cover)),
            const SizedBox(height: 5),
            Text(songs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
          ]),
        ),
      ),
    ),
  );

  Widget _buildVerticalList() => Expanded(
    child: ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, i) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(songs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
        title: Text(songs[i]['title'], style: const TextStyle(color: Colors.white)),
        subtitle: Text(songs[i]['artist'], style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.more_vert, color: Colors.white54),
        onTap: () => playMusic(songs[i]),
      ),
    ),
  );

  Widget _buildModernMiniPlayer() => GestureDetector(
    onTap: () => _showFullPlayer(),
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(borderRadius: BorderRadius.circular(5), child: Image.network(currentSong['img'], width: 40, height: 40)),
              const SizedBox(width: 10),
              Expanded(child: Text(currentSong['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
              IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.white), onPressed: () {
                isPlaying ? _player.pause() : _player.resume();
                setState(() => isPlaying = !isPlaying);
              }),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(trackHeight: 2, thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 0)),
            child: Slider(value: position.inSeconds.toDouble(), max: duration.inSeconds.toDouble(), onChanged: (v) {}),
          ),
        ],
      ),
    ),
  );

  Widget _buildBottomNav() => BottomNavigationBar(
    backgroundColor: Colors.black,
    selectedItemColor: Colors.blueAccent,
    unselectedItemColor: Colors.white54,
    type: BottomNavigationBarType.fixed,
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: "Home"),
      BottomNavigationBarItem(icon: Icon(Icons.search), label: "Search"),
      BottomNavigationBarItem(icon: Icon(Icons.library_music), label: "Library"),
      BottomNavigationBarItem(icon: Icon(Icons.workspace_premium), label: "Premium"),
    ],
  );

  void _showFullPlayer() {
    showModalBottomSheet(context: context, isScrollControlled: true, builder: (context) => Container(
      color: Colors.black,
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.keyboard_arrow_down, color: Colors.white),
        const SizedBox(height: 50),
        Image.network(currentSong['img'], width: 300, height: 300, fit: BoxFit.cover),
        const SizedBox(height: 40),
        Text(currentSong['title'], style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        Text(currentSong['artist'], style: const TextStyle(color: Colors.white54, fontSize: 18)),
        const SizedBox(height: 2
