import 'package:flutter/material.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart' as yt_exp;
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: DhunlyUltimate(),
    ));

class DhunlyUltimate extends StatefulWidget {
  @override
  _DhunlyUltimateState createState() => _DhunlyUltimateState();
}

class _DhunlyUltimateState extends State<DhunlyUltimate> {
  final yt_exp.YoutubeExplode yt = yt_exp.YoutubeExplode();
  final AudioPlayer _player = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  var currentSong;

  // Search function jo YouTube se gaana layega
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
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF0F0F0F),
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
                    _buildSectionTitle("Trending Now"),
                    _buildHorizontalScroll(),
                    _buildSectionTitle("Popular Artists"),
                    _buildArtistList(),
                  ],
                ),
              ),
            ),
            if (currentSong != null) _buildMiniPlayer(),
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
          Text("Dhunly Pro", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.greenAccent)),
          Icon(Icons.settings, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextField(
        onSubmitted: (v) => searchAndPlay(v),
        decoration: InputDecoration(
          hintText: "Search songs, artists...",
          prefixIcon: Icon(Icons.search, color: Colors.greenAccent),
          filled: true,
          fillColor: Colors.white10,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 20, top: 20, bottom: 10),
      child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHorizontalScroll() {
    return Container(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.only(left: 20),
        itemCount: 5,
        itemBuilder: (context, i) => Container(
          width: 140,
          margin: EdgeInsets.only(right: 15),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(image: NetworkImage("https://picsum.photos/200/300?random=$i"), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildArtistList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, i) => ListTile(
        leading: CircleAvatar(backgroundColor: Colors.greenAccent, child: Icon(Icons.person, color: Colors.black)),
        title: Text(i == 0 ? "Kaka" : i == 1 ? "Sidhu" : "Divine"),
        subtitle: Text("Artist"),
        trailing: Icon(Icons.play_arrow),
        onTap: () => searchAndPlay(i == 0 ? "Kaka" : i == 1 ? "Sidhu Moose Wala" : "Divine"),
      ),
    );
  }

  Widget _buildMiniPlayer() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.black, border: Border(top: BorderSide(color: Colors.white12))),
      child: Row(
        children: [
          ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.network(currentSong['img'], width: 50, height: 50, fit: BoxFit.cover)),
          SizedBox(width: 15),
          Expanded(child: Text(currentSong['title'], maxLines: 1, overflow: TextOverflow.ellipsis)),
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Colors.greenAccent),
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
