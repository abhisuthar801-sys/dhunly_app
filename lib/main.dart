import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:audioplayers/audioplayers.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: DhunlyFinalLogoApp()));

class DhunlyFinalLogoApp extends StatefulWidget {
  const DhunlyFinalLogoApp({super.key});
  @override
  State<DhunlyFinalLogoApp> createState() => _DhunlyFinalLogoAppState();
}

class _DhunlyFinalLogoAppState extends State<DhunlyFinalLogoApp> {
  final AudioPlayer _player = AudioPlayer();
  List cloudSongs = [];
  bool isPlaying = false;
  bool isLoading = true;
  
  // AAPKA LOGO LINK (Blue-Purple Play Button)
  final String myAppLogo = "https://i.ibb.co/Ldx999X/dhunly-logo.png"; 

  String currentSong = "Dhunly Pro: Ready";
  String currentImg = "https://i.ibb.co/Ldx999X/dhunly-logo.png";

  @override
  void initState() {
    super.initState();
    syncDatabase();
  }

  Future<void> syncDatabase() async {
    try {
      final response = await http.get(Uri.parse("https://api.jsonsilo.com/public/69094396-e176-474c-8302-3866d56d788e"));
      if (response.statusCode == 200) {
        setState(() {
          cloudSongs = json.decode(response.body)['songs'];
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
      backgroundColor: const Color(0xFF020202),
      body: Stack(
        children: [
          _backgroundArt(),
          SafeArea(
            child: Column(
              children: [
                _brandedTopBar(),
                if (isLoading) const Expanded(child: Center(child: CircularProgressIndicator(color: Colors.blueAccent))),
                if (!isLoading) _songGrid(),
                _bottomControlBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backgroundArt() => Positioned(
    top: -50, left: -50,
    child: Container(width: 300, height: 300, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withOpacity(0.12))),
  );

  Widget _brandedTopBar() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
    child: Row(
      children: [
        // AAPKA LOGO YAHAN DIKHEGA
        Container(
          height: 50, width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            image: DecorationImage(image: NetworkImage(myAppLogo), fit: BoxFit.cover),
            boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 10)]
          ),
        ),
        const SizedBox(width: 15),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("DHUNLY PRO", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900, letterSpacing: 2)),
            Text("Premium Music Cloud", style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    ),
  );

  Widget _songGrid() => Expanded(
    child: ListView.builder(
      itemCount: cloudSongs.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, i) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(18)),
        child: ListTile(
          leading: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(cloudSongs[i]['img'], width: 50, height: 50, fit: BoxFit.cover)),
          title: Text(cloudSongs[i]['title'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: Text(cloudSongs[i]['artist'], style: const TextStyle(color: Colors.white38, fontSize: 11)),
          trailing: const Icon(Icons.play_circle_outline, color: Colors.blueAccent),
          onTap: () => playMusic(cloudSongs[i]),
        ),
      ),
    ),
  );

  Widget _bottomControlBar() => Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: const Color(0xFF0A0A0A), border: Border(top: BorderSide(color: Colors.blueAccent.withOpacity(0.2)))),
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
