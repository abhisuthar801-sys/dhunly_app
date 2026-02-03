import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyFullApp(),
    ));

class DhunlyFullApp extends StatefulWidget {
  @override
  _DhunlyFullAppState createState() => _DhunlyFullAppState();
}

class _DhunlyFullAppState extends State<DhunlyFullApp> {
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  int currentIndex = 0;

  // Zyada Songs aur Categories
  final List<Map<String, String>> topHits = [
    {"title": "Temporary Pyar", "artist": "Kaka", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3", "img": "https://i.pravatar.cc/150?u=1"},
    {"title": "Elevated", "artist": "Shubh", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3", "img": "https://i.pravatar.cc/150?u=2"},
    {"title": "295", "artist": "Sidhu Moose Wala", "url": "https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3", "img": "https://i.pravatar.cc/150?u=3"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF090909),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(),
              _buildSearchBar(),
              _buildSectionTitle("Your Top Hits"),
              _buildHorizontalList(),
              _buildSectionTitle("Recent Playlists"),
              _buildVerticalList(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomPlayer(),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("Dhunly Pro", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          CircleAvatar(backgroundImage: NetworkImage("https://i.pravatar.cc/150?u=9")),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(15)),
        child: TextField(
          decoration: InputDecoration(hintText: "Search Songs, Artists...", border: InputBorder.none, icon: Icon(Icons.search, color: Colors.greenAccent)),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 30, bottom: 15),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHorizontalList() {
    return Container(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: topHits.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _play(index),
            child: Container(
              width: 150,
              margin: EdgeInsets.only(right: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(topHits[index]['img']!, height: 150, width: 150, fit: BoxFit.cover)),
                  SizedBox(height: 8),
                  Text(topHits[index]['title']!, style: TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: topHits.length,
      itemBuilder: (context, index) {
        return ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(topHits[index]['img']!, width: 50, height: 50, fit: BoxFit.cover)),
          title: Text(topHits[index]['title']!),
          subtitle: Text(topHits[index]['artist']!),
          trailing: Icon(Icons.play_circle_fill, color: Colors.greenAccent),
          onTap: () => _play(index),
        );
      },
    );
  }

  Widget _buildBottomPlayer() {
    var current = topHits[currentIndex];
    return Container(
      height: 80,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white12))),
      child: Row(
        children: [
          CircleAvatar(backgroundImage: NetworkImage(current['img']!)),
          SizedBox(width: 15),
          Expanded(child: Text(current['title']!, overflow: TextOverflow.ellipsis)),
          IconButton(icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow), onPressed: () => isPlaying ? _pause() : _play(currentIndex)),
          IconButton(icon: Icon(Icons.skip_next), onPressed: () => _play((currentIndex + 1) % topHits.length)),
        ],
      ),
    );
  }

  void _play(int index) async {
    setState(() => currentIndex = index);
    await _player.play(UrlSource(topHits[index]['url']!));
    setState(() => isPlaying = true);
  }

  void _pause() async {
    await _player.pause();
    setState(() => isPlaying = false);
  }
}
