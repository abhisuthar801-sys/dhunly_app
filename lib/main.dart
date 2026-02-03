import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyProMaster(),
    ));

class DhunlyProMaster extends StatefulWidget {
  @override
  _DhunlyProMasterState createState() => _DhunlyProMasterState();
}

class _DhunlyProMasterState extends State<DhunlyProMaster> {
  final yt_exp.YoutubeExplode yt = yt_exp.YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;

  // Categories jo ab sach mein kaam karengi
  final List<Map<String, dynamic>> categories = [
    {"name": "Romantic", "icon": Icons.favorite, "query": "Arijit Singh Romantic Songs"},
    {"name": "Party", "icon": Icons.celebration, "query": "Badshah Latest Party Hits"},
    {"name": "Sad", "icon": Icons.sentiment_dissatisfied, "query": "Sad Punjabi Songs"},
    {"name": "Gym", "icon": Icons.fitness_center, "query": "High Bass Workout Music"},
  ];

  // Search aur Play function (Full Power)
  void fetchAndPlay(String query) async {
    setState(() {
      isLoading = true;
      isPlaying = false;
    });
    try {
      var search = await yt.search.search(query);
      if (search.isNotEmpty) {
        var video = search.first;
        var manifest = await yt.videos.streamsClient.getManifest(video.id);
        var audioUrl = manifest.audioOnly.withHighestBitrate().url.toString();

        await _player.play(UrlSource(audioUrl));
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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Try Again! Connection slow hai.")));
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
            if (isLoading) LinearProgressIndicator(color: Colors.greenAccent, backgroundColor: Colors.white10),
            Expanded(
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Quick Moods"),
                    _buildCategories(),
                    _buildSectionTitle("Trending Now"),
                    _buildTrendingCards(),
                    _buildSectionTitle("Your Library"),
                    _buildLibraryList(),
                  ],
                ),
              ),
            ),
            if (currentSong != null) _buildStickyPlayer(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(text: TextSpan(style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), children: [
            TextSpan(text: "DHUNLY", style: TextStyle(color: Colors.greenAccent)),
            TextSpan(text: "PRO"),
          ])),
          Icon(Icons.person_outline, size: 30),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        onSubmitted: (v) => fetchAndPlay(v),
        decoration: InputDecoration(
          hintText: "Search Songs or Artists...",
          prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: categories.length,
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => fetchAndPlay(categories[i]['query']),
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.only(right: 20),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
                child: Icon(categories[i]['icon'], color: Colors.greenAccent),
              ),
              SizedBox(height: 8),
              Padding(padding: EdgeInsets.only(right: 20), child: Text(categories[i]['name'])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingCards() {
    return Container(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        children: [
          _card("Kaka Specials", "https://picsum.photos/300/300?music=1"),
          _card("Punjabi 2024", "https://picsum.photos/300/300?music=2"),
          _card("Lo-fi Study", "https://picsum.photos/300/300?music=3"),
        ],
      ),
    );
  }

  Widget _card(String name, String img) {
    return GestureDetector(
      onTap: () => fetchAndPlay(name),
      child: Container(
        width: 160,
        margin: EdgeInsets.only(right: 15),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), image: DecorationImage(image: NetworkImage(img), fit: BoxFit.cover)),
        child: Container(
          alignment: Alignment.bottomLeft,
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Colors.black87])),
          child: Text(name, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildLibraryList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, i) => ListTile(
        leading: Icon(Icons.music_note, color: Colors.greenAccent),
        title: Text(i == 0 ? "Sidhu Moose Wala" : i == 1 ? "Divine" : "Karan Aujla"),
        subtitle: Text("Top Songs"),
        onTap: () => fetchAndPlay(i == 0 ? "295 Sidhu" : i == 1 ? "Divine Mirchi" : "Aujla Softly"),
      ),
    );
  }

  Widget _buildStickyPlayer() {
    return Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Color(0xFF1E1E1E), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(currentSong['img'], width: 50, height: 50, fit: BoxFit.cover)),
          SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(currentSong['title'], maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontWeight: FontWeight.bold)),
            Text(currentSong['artist'], style: TextStyle(color: Colors.grey, fontSize: 12)),
          ])),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 40, color: Colors.greenAccent),
            onPressed: () {
              if (isPlaying) { _player.pause(); setState(() => isPlaying = false); }
              else { _player.resume(); setState(() => isPlaying = true); }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(padding: EdgeInsets.only(left: 20, top: 25, bottom: 10), child: Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white70)));
  }
}
