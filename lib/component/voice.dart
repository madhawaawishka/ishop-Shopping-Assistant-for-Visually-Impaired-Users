import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:spm_project/auth/auth.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpeechButton extends StatefulWidget {
  final VoidCallback onCaptureCommand;

  const SpeechButton({super.key, required this.onCaptureCommand});

  @override
  State<SpeechButton> createState() => _SpeechButtonState();
}

class _SpeechButtonState extends State<SpeechButton> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  bool _isListening = false;
  String _command = '';
  Timer? _timer;

  void logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const AuthPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: (result) {
      setState(() {
        _command = result.recognizedWords;
        _navigateBasedOnCommand(_command.toLowerCase());
      });
    });
    setState(() {
      _speechEnabled = true;
      _isListening = true;
    });

    _timer = Timer(const Duration(seconds: 10), _stopListening);
  }

  void _stopListening() async {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
      // _speak("Unrecognized command, please try again");
    }
    await _speechToText.stop();
    setState(() {
      _speechEnabled = false;
      _isListening = false;
    });
  }

  void _navigateBasedOnCommand(String command) async {
    if (command.contains('home')) {
      Navigator.pushNamed(context, '/home_page');
      _speak("Navigating to Home Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('objects')) {
      Navigator.pushNamed(context, '/objects_page');
      _speak("Navigating to Objects Page");
      _stopListening(); // Stop after correct command 
    } else if (command.contains('fruits')) {
      Navigator.pushNamed(context, 'objects_page/fruits_obj');
      _speak("Navigating to Fruits Object Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('vegetables')) {
      Navigator.pushNamed(context, 'objects_page/vegetables_obj');
      _speak("Navigating to Vegetables Object Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('packages')) {
      Navigator.pushNamed(context, 'objects_page/packages_obj');
      _speak("Navigating to Packages Object Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('save')) {
      Navigator.pushNamed(context, '/display_shape_obj');
      _speak("Navigating to Object Save Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('profile')) {
      Navigator.pushNamed(context, '/profile_page');
      _speak("Navigating to Profile Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('logout')) {
      logout(context);
      _speak("Logging out");
      _stopListening(); // Stop after correct command
    } else if (command.contains('community')) {
      Navigator.pushNamed(context, '/community_page');
      _speak("Navigating to community Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('voice note')) {
      Navigator.pushNamed(context, '/voice_note_page');
      _speak("Navigating to voice note Page");
      _stopListening(); // Stop after correct command
    } else if (command.contains('capture')) {
      widget.onCaptureCommand();
      _speak("Capturing the image");
      _stopListening(); // Stop after correct command
    } else if (command.contains('help')) {
      Navigator.pushNamed(context, '/help_page');
      _speak("Navigating to Help Page");
      // Stop after correct command
    } else if (command.contains('video')) {
      Navigator.pushNamed(context, '/home_page1');
      _speak("Navigating to Video call screen");
    } else if (command.contains('emergency')) {
      Navigator.pushNamed(context, '/tutor_list_page');
      _speak("Navigating to emergency page");
    } else {
      // _speak("Unrecognized command, please try again");
      _stopListening(); // Restart listening for the correct command
    }
  }

  void _speak(String text) async {
    if (text.isNotEmpty) {
      // Stop any previous speech
      // await _flutterTts.stop();

      // Optionally set other properties before speaking
      await _flutterTts.setLanguage("en-US");
      await _flutterTts.setSpeechRate(0.5); // Speed control
      await _flutterTts.setVolume(1.0); // Volume control
      await _flutterTts.setPitch(1.0); // Pitch control

      // Speak the text
      int result = await _flutterTts.speak(text);

      if (result == 1) {
        print("Speech started");
      } else {
        print("Speech failed");
      }
    } else {
      print("No text to speak");
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end, // Button stays at the bottom
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _startListening,
                    child: Container(
                      height: 60, // Make it large
                      color: Colors.transparent, // Ensure the full area is tappable
                      child: FloatingActionButton.extended(
                        elevation: 0,
                        onPressed: _startListening,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        label: Text(
                          _speechToText.isListening ? "Listening..." : "Speak",
                          style: const TextStyle(color: Colors.white),
                        ),
                        icon: Icon(
                          _speechToText.isListening ? Icons.mic : Icons.mic_none,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                if (_isListening)
                  Padding(
                    padding: const EdgeInsets.all(25.0),
                    child: FloatingActionButton(
                      elevation: 0,
                      onPressed: _stopListening,
                      backgroundColor: Colors.red,
                      child: const Icon(
                        Icons.stop,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
