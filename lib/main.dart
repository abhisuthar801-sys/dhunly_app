import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProFinal(),
    ));

class DhunlyProFinal extends StatefulWidget {
  @override
  _DhunlyProFinalState createState() => _DhunlyProFinalState();
}

class _DhunlyProFinalState extends State<DhunlyProFinal> {
  final yt_exp.YoutubeExplode yt = yt_exp.YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;

  // Mood Categories
  final List<Map<String, dynamic>> categories = [
    {"name": "Romantic", "icon": Icons.favorite, "color": Colors.pink},
    {"name": "Party", "icon": Icons.celebration, "color": Colors.orange},
    {"name": "Sad", "icon": Icons.sentiment_very_satisfied, "color": Colors.blue},
    {"name": "Gym", "icon": Icons.fitness_center, "color": Colors.red},
  ];

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
          isPlaying = true;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: Gaana nahi chal paya! Check Internet.")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (isLoading) LinearProgressIndicator(color: Colors.greenAccent),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCategoryRow(),
                    _buildSectionTitle("Trending Hits"),
                    _buildTrendingList(),
                    _buildSectionTitle("Popular For You"),
                    _buildVerticalPlaylist(),
                  ],
                ),
              ),
            ),
            if (currentSong != null) _buildFullMiniPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Text("DHUNLY", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.greenAccent, letterSpacing: 2)),
          Text(" PRO", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
          Spacer(),
          Icon(Icons.notifications_none),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onSubmitted: (v) => searchAndPlay(v),
        decoration: InputDecoration(
          hintText: "Search Songs, Artists, Podcasts...",
          prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    return Container(
      height: 100,
      padding: EdgeInsets.only(top: 20),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, i) => Column(
          children: [
            Container(
              margin: EdgeInsets.only(right: 20),
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(color: categories[i]['color'].withOpacity(0.2), shape: BoxShape.circle),
              child: Icon(categories[i]['icon'], color: categories[i]['color']),
            ),
            SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Text(categories[i]['name'], style: TextStyle(fontSize: 12)),
            ),
          ],
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

  Widget _buildTrendingList() {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: 5,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => searchAndPlay("Viral Song $i"),
          child: Container(
            width: 140,
            margin: EdgeInsets.only(right: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              image: DecorationImage(image: NetworkImage("https://picsum.photos/200/300?random=$i"), fit: BoxFit.cover),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalPlaylist() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, i) => ListTile(
        leading: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network("https://picsum.photos/50/50?random=${i+10}")),
        title: Text(i == 0 ? "Kaka Hits" : i == 1 ? "Sidhu Mix" : "Divine Street"),
        subtitle: Text("Playlist • Dhunly"),
        trailing: Icon(Icons.more_vert),
        onTap: () => searchAndPlay(i == 0 ? "Kaka" : i == 1 ? "Sidhu Moose Wala" : "Divine"),
      ),
    );
  }

  Widget _buildFullMiniPlayer() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: Colors.greenAccent.withOpacity(0.9), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(currentSong['img'], width: 45, height: 45, fit: BoxFit.cover)),
          SizedBox(width: 15),
          Expanded(child: Text(currentSong['title'], style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.black),
            onPressed: () {
              if (isPlaying) { _player.pause(); setState(() => isPlaying = false); }
              else { _player.resume(); setState(() => isPlaying = true); }
            },
          ),
        ],
      ),
    );
  }
}
