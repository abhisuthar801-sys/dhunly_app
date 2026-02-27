import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DhunlyUniversal());
}

class DhunlyUniversal extends StatelessWidget {
  const DhunlyUniversal({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const UniversalPlayer(),
    );
  }
}

class UniversalPlayer extends StatefulWidget {
  const UniversalPlayer({super.key});
  @override
  _UniversalPlayerState createState() => _UniversalPlayerState();
}

class _UniversalPlayerState extends State<UniversalPlayer> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoading = false;
  int currentIndex = 0;

  // --- 100% UNIVERSAL WORKING LINKS ---
  final List<Map<String, String>> songs = [
    {
      "title": "Universal Tune 1",
      "url": "https://www.apple.com/library/test/success.mp3",
      "img": "https://img.freepik.com/free-vector/abstract-colorful-musical-note-background_53876-114251.jpg"
    },
    {
      "title": "Universal Tune 2",
      "url": "https://storage.googleapis.com/codeskulptor-assets/GalaxyInvaders/theme.mp3",
      "img": "https://img.freepik.com/free-vector/music-background-with-sinusoid-waves_23-2147502758.jpg"
    }
  ];

  @override
  void initState() {
    super.initState();
    // NEW AUDIO CONTEXT FIX (For version 6.x)
    _audioPlayer.setAudioContext(const AudioContext(
      android: AudioContextAndroid(
        isSpeakerphoneOn: true,
        stayAwake: true,
        contentType: AndroidContentType.music,
        usageType: AndroidUsageType.media,
        audioFocus: AndroidAudioFocus.gain,
      ),
      iOS: AudioContextIOS(
        category: ObjCAudioSessionCategory.playback,
      ),
    ));

    // Listen to state changes to stop loader
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          isLoading = false;
          isPlaying = true;
        });
      }
    });
  }

  Future<void> playMusic(int index) async {
    setState(() {
      currentIndex = index;
      isLoading = true;
    });

    try {
      await _audioPlayer.stop();
      // Universal Streaming Source
      await _audioPlayer.play(UrlSource(songs[index]['url']!));
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Stream Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("UNIVERSAL PLAYER", 
              style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 24)),
            const SizedBox(height: 30),
            _playerUI(),
            const SizedBox(height: 30),
            ...List.generate(songs.length, (index) => ListTile(
              title: Text(songs[index]['title']!, textAlign: TextAlign.center),
              onTap: () => playMusic(index),
            ))
          ],
        ),
      ),
    );
  }

  Widget _playerUI() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Colors.white10, shape: BoxShape.circle),
      child: isLoading 
        ? LoadingAnimationWidget.staggeredDotsWave(color: Colors.blueAccent, size: 80)
        : IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 100, color: Colors.blueAccent),
            onPressed: () {
              if (isPlaying) {
                _audioPlayer.pause();
                setState(() => isPlaying = false);
              } else {
                _audioPlayer.resume();
                setState(() => isPlaying = true);
              }
            },
          ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
