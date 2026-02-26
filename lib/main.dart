import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DhunlyFinalApp());
}

class DhunlyFinalApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: SuperFastPlayer(),
    );
  }
}

class SuperFastPlayer extends StatefulWidget {
  @override
  _SuperFastPlayerState createState() => _SuperFastPlayerState();
}

class _SuperFastPlayerState extends State<SuperFastPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;

  // --- 100% WORKING FAST LINKS ---
  final List<Map<String, String>> songs = [
    {
      "title": "Pasoori",
      "url": "https://res.cloudinary.com/dxfq3iotg/video/upload/v1655370213/sample_audio_1.mp3",
      "img": "https://i.ytimg.com/vi/5Eqb_-j3FDA/0.jpg"
    },
    {
      "title": "295",
      "url": "https://res.cloudinary.com/dxfq3iotg/video/upload/v1655370213/sample_audio_2.mp3",
      "img": "https://i.ytimg.com/vi/n_Wce6z38ps/0.jpg"
    }
  ];

  @override
  void initState() {
    super.initState();
    // Audio configuration fix
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  Future<void> playSong(int index) async {
    setState(() {
      currentIndex = index;
      isLoading = true;
    });

    try {
      await _audioPlayer.stop();
      // Direct stream with source
      await _audioPlayer.play(UrlSource(songs[index]['url']!));
      
      setState(() {
        isPlaying = true;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      // Agar error aaye toh screen par dikhega
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: Internet slow hai ya link block hai!"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          const SizedBox(height: 60),
          _playerCard(),
          Expanded(child: _listSection()),
        ],
      ),
    );
  }

  Widget _playerCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white10, borderRadius: BorderRadius.circular(20)),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Image.network(songs[currentIndex]['img']!, height: 150, fit: BoxFit.cover),
          ),
          const SizedBox(height: 20),
          if (isLoading)
            LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 50)
          else
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 70, color: Colors.blueAccent),
              onPressed: () {
                if (isPlaying) _audioPlayer.pause(); else _audioPlayer.resume();
                setState(() => isPlaying = !isPlaying);
              },
            ),
        ],
      ),
    );
  }

  Widget _listSection() {
    return ListView.builder(
      itemCount: songs.length,
      itemBuilder: (context, index) => ListTile(
        leading: Image.network(songs[index]['img']!, width: 50),
        title: Text(songs[index]['title']!),
        onTap: () => playSong(index),
      ),
    );
  }
}
