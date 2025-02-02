import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with "NoteForge" on the left
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'NoteForge',
          style: TextStyle(
            color: Colors.white,  // White text color for the app bar
            fontSize: 20,  // Font size for the app bar text
            fontWeight: FontWeight.bold,  // Make the text bold
          ),
        ),
        centerTitle: false,  // Align the title to the left
      ),
      backgroundColor: Colors.black,  // Set the background color to black
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            // Circle with Plus sign inside it (smaller circle with constant plus sign size)
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => SummaryPage()));
              },
              child: Container(
                width: 70,  // Smaller circle diameter
                height: 70, // Smaller circle diameter
                decoration: BoxDecoration(
                  color: Colors.white,  // Circle color
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.add,  // Plus sign icon
                    size: 40,    // Constant size for the plus sign
                    color: Colors.black,  // Plus sign color
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),  // Space between the icon and text
            // Text below the icon
            Text(
              'CREATE A NEW SESSION TO SUMMARIZE',
              style: TextStyle(
                color: Colors.grey,  // Grey text color
                fontSize: 16,  // Font size (small to medium)
                fontWeight: FontWeight.w400,  // Font weight (normal)
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SummaryPage extends StatefulWidget {
  const SummaryPage({super.key});

  @override
  State<SummaryPage> createState() => _SummaryPageState();
}

class _SummaryPageState extends State<SummaryPage>{
  // Controller for the input field
  TextEditingController _controller = TextEditingController();
  late stt.SpeechToText _speech;
  bool _isListening = false;


  Future<String> getSummary(String inputText) async {
    final url = Uri.parse("https://huggingface.co/spaces/TaterTots123/AISOC_hackathon/summarize");
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": inputText}),
    );

    if (response.statusCode == 200) {
      return response.body; // Contains the summarized text
    } else {
      throw Exception("Failed to summarize text");
    }
  }

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
  }

  // Start listening to the speech input
  void _startListening() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print("Status: $status"),
      onError: (error) => print("Error: $error"),
    );
    if (available) {
      setState(() => _isListening = true);
      _speech.listen(onResult: (result) {
        setState(() {
          // Update the input field with recognized speech
          _controller.text = result.recognizedWords;
        });
      });
    }
  }

  // Stop listening to the speech input
  void _stopListening() {
    _speech.stop();
    setState(() => _isListening = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with back arrow
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),  // Back arrow icon
          onPressed: () {
            Navigator.pop(context);  // Go back to the main screen
          },
        ),
        title: Text(
          'New Session',
          style: TextStyle(color: Colors.white),
        ),
      ),
      backgroundColor: Colors.black,  // Set the background color to black
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // Input form at the top-center
            Padding(
              padding: EdgeInsets.all(20.0),
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.white),  // White text color
                decoration: InputDecoration(
                  hintText: 'Enter or speak your transcript that you wish to summarize',
                  hintStyle: TextStyle(color: Colors.grey),  // Grey hint text
                  filled: true,
                  fillColor: Colors.black,  // Black background for the input field
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                    borderSide: BorderSide.none,  // No border
                  ),
                ),
                maxLines: 5,  // Allow multi-line input
              ),
            ),

            // Summarize button below the input form
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  // Add your summarization logic here
                  if (_controller.text.isEmpty) {
                    print("No transcript entered!");
                  } else {
                    print("Summarizing transcript: ${_controller.text}");
                    // Implement summarization functionality
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,  // White background for the button
                  foregroundColor: Colors.black,  // Black text color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),  // Rounded corners
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                ),
                child:GestureDetector(
                  onTap:(){
                    getSummary(_controller.text);
                  },
                  child: Text(
                  'Summarize',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
            ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                _controller.text, // Display the fetched summary
                style: TextStyle(color: Colors.white, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),

            // Spacer to push the mic button to the bottom center

            // Mic button at the bottom-center
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0),
              child: GestureDetector(
                onTap: _isListening ? _stopListening : _startListening,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,  // White background for the circle
                    shape: BoxShape.circle,  // Circle shape
                  ),
                  child: Center(
                    child: Icon(
                      _isListening ? Icons.mic_off : Icons.mic,  // Toggle mic icon
                      size: 40,  // Size of the mic icon
                      color: Colors.black,  // Black mic icon
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,  // Remove the debug banner
    home: HomePage(),  // The main screen
  ));
}


