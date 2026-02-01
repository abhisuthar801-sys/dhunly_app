import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyCloudMaster()));

class DhunlyCloudMaster extends StatefulWidget {
  const DhunlyCloudMaster({super.key});
  @override
  State<DhunlyCloudMaster> createState() => _DhunlyCloudMasterState();
}

class _DhunlyCloudMasterState extends State<DhunlyCloudMaster> {
  final AudioPlayer _player = AudioPlayer();
  List cloudLibrary = [];
  bool isPlaying = false;
  bool isLoading = true;
  String currentSong = "Dhunly: Loading Hits...";
  String currentImg = "https://cdn-icons-png.flaticon.com/512/3844/3844724.png";

  @override
  void initState() {
    super.initState();
    loadDhunlyDatabase();
  }

  // --- DHUNLY CLOUD ENGINE ---
  Future<void> loadDhunlyDatabase() async {
    try {
      // Ye humara temporary master link hai jo verified gaane bhejega
      final response = await http.get(Uri.parse("https://raw.githubusercontent.com/dhunly-music/database/main/library.json"));
      
      if (response.statusCode == 200) {
        setState(() {
          cloudLibrary = json.decode(response.body);
          isLoading = false;
        });
      } else {
        // Fallback: Agar server down ho toh ye default gaane chalenge
        setState(() {
          cloudLibrary = [
            {'title': 'Legend', 'artist': 'Sidhu Moose Wala', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3', 'img': 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=300'},
            {'title': 'Kesariya', 'artist': 'Arijit Singh', 'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3', 'img': 'https://images.unsplash.com/photo-1493225255756-d9584f8606e9?w=300'},
          ];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void playMusic(var s) async {
    await _player.stop();
    await _player.play(UrlSource(s['url']));
    setState(() {
      currentSong = s['title'];
      currentImg = s['img'];
      isPlaying = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050505),
      body: Stack(
        children: [
          _buildBackground(),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
                if (!isLoading) _buildLibraryList(),
                _buildBottomPlayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() => Positioned(
    top: -50, right: -50,
    child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.15))),
  );

  Widget _buildHeader() => Padding(
    padding: const EdgeInsets.all(25),
    child: Row(
      children: [
        // Final Logo Icon
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Colors.blueAccent, Colors.purpleAccent]),
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(Icons.music_note, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text("Online Cloud Library", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );

  Widget _buildLibraryList() => Expanded(
    child: ListView.builder(
      itemCount: cloudLibrary.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
        child: ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(10), child: Image.network(cloudLibrary[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
          title: Text(cloudLibrary[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(cloudLibrary[i]['artist'], style: const TextStyle(color: Colors.white54, fontSize: 12)),
          trailing: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
          onTap: () => playMusic(cloudLibrary[i]),
        ),
      ),
    ),
  );

  Widget _buildBottomPlayer() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      color: Colors.black,
      border: Border(top: BorderSide(color: Colors.blueAccent.withOpacity(0.3))),
    ),
    child: Row(
      children: [
        CircleAvatar(backgroundImage: NetworkImage(currentImg), radius: 25),
        const SizedBox(width: 15),
        Expanded(child: Text(currentSong, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
        IconButton(
          icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle, color: Colors.blueAccent, size: 45),
          onPressed: () {
            isPlaying ? _player.pause() : _player.resume();
            setState(() => isPlaying = !isPlaying);
          },
        ),
      ],
    ),
  );
}
