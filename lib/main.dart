import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MaterialApp(home: DhunlyPlayer()));
}

class DhunlyPlayer extends StatefulWidget {
  const DhunlyPlayer({super.key});

  @override
  State<DhunlyPlayer> createState() => _DhunlyPlayerState();
}

class _DhunlyPlayerState extends State<DhunlyPlayer> {
  final player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dhunly Player')),
      body: Center(
        child: ElevatedButton(
          child: const Text('Play Music'),
          onPressed: () async {
            await player.play(UrlSource('https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'));
          },
        ),
      ),
    );
  }
}
