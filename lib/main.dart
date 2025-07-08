import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:string_similarity/string_similarity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(VoiceAssistantApp());
}

class VoiceAssistantApp extends StatefulWidget {
  @override
  _VoiceAssistantAppState createState() => _VoiceAssistantAppState();
}

class _VoiceAssistantAppState extends State<VoiceAssistantApp> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  String selectedLang = 'en';
  String selectedLocale = 'en-US';
  final Map<String, String> languages = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Telugu': 'te-IN',
    'Spanish': 'es-ES',
    'French': 'fr-FR',
  };

  Map<String, Map<String, String>> faqDataset = {};
  List<Map<String, dynamic>> messages = [];
  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _loadDataset();
  }

  Future<void> _loadDataset() async {
    final jsonString = await rootBundle.loadString('assets/farming_faqs.json');
    final Map<String, dynamic> data = json.decode(jsonString);
    setState(() {
      faqDataset = data.map((lang, qaMap) => MapEntry(
          lang, Map<String, String>.from(qaMap as Map<String, dynamic>)));
    });
  }

  void _listen() async {
    if (isListening) {
      await _speech.stop();
      setState(() => isListening = false);
      return;
    }

    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => isListening = false);
        }
      },
      onError: (error) {
        print('Speech error: $error');
        setState(() => isListening = false);
      },
    );

    if (!available) return;

    setState(() => isListening = true);

    _speech.listen(
      localeId: selectedLocale,
      listenMode: stt.ListenMode.dictation,
      onResult: (result) {
        if (result.finalResult) {
          final userInput = result.recognizedWords;
          setState(() {
            messages.add({'text': userInput, 'isUser': true});
            isListening = false;
          });
          _speech.stop();
          _getResponseFromDataset(userInput);
        }
      },
    );
  }

  void _getResponseFromDataset(String userInput) async {
    String langCode = selectedLang.substring(0, 2);
    Map<String, String> faqs = faqDataset[langCode] ?? faqDataset['en']!;

    String? bestMatch;
    double maxScore = 0.0;

    faqs.keys.forEach((question) {
      double score = userInput.toLowerCase().similarityTo(question);
      if (score > maxScore) {
        maxScore = score;
        bestMatch = question;
      }
    });

    final reply = maxScore > 0.4
        ? faqs[bestMatch]!
        : "Sorry, I couldn't understand. Please ask a farming-related question.";

    setState(() {
      messages.add({'text': reply, 'isUser': false});
    });

    await _tts.setLanguage(selectedLocale);
    await _tts.speak(reply);

    Future.delayed(Duration(milliseconds: 300), () {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Voice Assistant',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Farming Voice Assistant')),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                value: selectedLocale,
                items: languages.entries.map((entry) {
                  return DropdownMenuItem<String>(
                    value: entry.value,
                    child: Text(entry.key),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedLocale = value;
                      selectedLang = value.substring(0, 2);
                    });
                  }
                },
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return Align(
                    alignment: message['isUser']
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                      margin:
                          EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                      decoration: BoxDecoration(
                        color: message['isUser']
                            ? Colors.blue[100]
                            : Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message['text'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                icon: Icon(Icons.mic),
                label: Text("Tap to Speak"),
                onPressed: _listen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}