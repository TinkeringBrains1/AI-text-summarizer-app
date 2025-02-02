import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _text = "Press the button and start speaking";

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() => _text = result.recognizedWords);
      });
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Speech to Text")),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_text, style: TextStyle(fontSize: 18)),
              SizedBox(height: 20),
              FloatingActionButton(
                onPressed: _isListening ? _stopListening : _startListening,
                child: Icon(_isListening ? Icons.mic_off : Icons.mic),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
