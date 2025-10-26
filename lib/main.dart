// main.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';

void main() => runApp(VoiceAssistantApp());

class VoiceAssistantApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Voice Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Color(0xFFF7F7FB),
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: VoiceAssistantHome(),
    );
  }
}

class VoiceAssistantHome extends StatefulWidget {
  @override
  _VoiceAssistantHomeState createState() => _VoiceAssistantHomeState();
}

class _VoiceAssistantHomeState extends State<VoiceAssistantHome>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final ScrollController _scrollController = ScrollController();

  //------------------------------------- Replace with your Perplexity API Key----------------------------------------------------------//
  //place the key on the a - p - i k -e -y place after `pplx-----'WIVkfqLRXXn24ffVt2roT8rdGhXwLRGGWRB9JQemjzrZdnh5'`//

final String perplexityApiKey =
      'pplx-_______________________________________';
  final String perplexityModel =
      'sonar-pro'; // sonar / sonar-pro / sonar-reasoning

  String selectedLocale = 'en-US';
  bool isListening = false;
  bool isLoading = false;
  bool showTyping = false;

  List<Message> messages = [];

  final Map<String, String> languages = {
    'English': 'en-US',
    'Hindi': 'hi-IN',
    'Telugu': 'te-IN',
  };

  // small helper to get a short timestamp
  String _now() => DateFormat('hh:mm a').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    // _tts.setVoice({'name': 'en-US-Wavenet-F', 'locale': 'en-US'});

    _tts.setSpeechRate(0.45);
    _tts.setVolume(1.0);
    _tts.setPitch(1.0);
    // optionally preload a welcome message
    messages.add(
      Message(
        text:
            'Hi — I\'m your smart assistant. Tap the mic and ask anything (short answers).',
        isUser: false,
        time: _now(),
      ),
    );
  }

  // Inside _VoiceAssistantHomeState

  void _listen() async {
    if (isListening) {
      await _stopListening();
      return;
    }

    bool available = await _speech.initialize(
      onError: (e) {
        print('Speech error: $e');
        if (mounted) _addSystemMessage('Speech recognition failed.');
        _stopListening();
      },
      onStatus: (status) async {
        if (status == 'notListening' || status == 'done') {
          if (isListening) await _stopListening();
        }
      },
    );

    if (!available) {
      if (mounted) _addSystemMessage('Speech unavailable on this device.');
      return;
    }

    setState(() => isListening = true);
    String recognizedText = '';
    bool dialogMounted = true;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Start listening once
            if (!_speech.isListening) {
              _speech.listen(
                localeId: selectedLocale,
                listenMode: stt.ListenMode.dictation,
                pauseFor: Duration(seconds: 3),
                listenFor: Duration(seconds: 30),
                onResult: (result) async {
                  recognizedText = result.recognizedWords;

                  if (dialogMounted) setDialogState(() {}); // safe update

                  if (result.finalResult) {
                    final text = recognizedText.trim();
                    if (text.isNotEmpty) {
                      if (mounted) _addUserMessage(text);
                      await _sendToPerplexity(text);
                    } else {
                      if (mounted) _addSystemMessage('No speech recognized.');
                    }
                    await _stopListening();
                  }
                },
              );
            }

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Lottie.asset(
                    'assets/siri.json',
                    width: 180,
                    height: 180,
                    repeat: true,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Listening... $recognizedText",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      dialogMounted = false; // prevent setState on dialog
                      _stopListening();
                    },
                    child: const Text('Stop'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    // Dialog closed, mark as not listening if still true
    dialogMounted = false;
    if (mounted && isListening) setState(() => isListening = false);
  }

  Future<void> _stopListening() async {
    if (_speech.isListening) await _speech.stop();

    if (mounted) {
      setState(() => isListening = false);

      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  // System message helper
  void _showSystemMessage(String text) {
    _addSystemMessage(text);
    _stopListening();
  }

  // Update mic button to reflect listening with color & icon
  Widget _controls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Center(
        child: GestureDetector(
          onTap: _listen,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 250),
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors:
                    isListening
                        ? [Colors.redAccent, Colors.orangeAccent]
                        : [Colors.deepPurple, Colors.indigo],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 8,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Center(
              child: Icon(
                isListening ? Icons.mic : Icons.mic_none,
                color: Colors.white,
                size: 56,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _addUserMessage(String text) {
    setState(() {
      messages.add(Message(text: text, isUser: true, time: _now()));
    });
    _scrollToBottomLater();
  }

  void _addSystemMessage(String text) {
    setState(() {
      messages.add(Message(text: text, isUser: false, time: _now()));
    });
    _scrollToBottomLater();
  }

  // Scroll to bottom a bit later after UI update
  void _scrollToBottomLater() {
    Future.delayed(Duration(milliseconds: 250), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // Ask Perplexity for a short answer: instruct model to reply concisely and fully.
  Future<void> _sendToPerplexity(String userInput) async {
    setState(() {
      isLoading = true;
      showTyping = true;
    });

    // System instruction strongly asks for short, complete answer
    final systemInstruction =
        "You are a concise assistant. Provide accurate, complete answers in very few words or sentences (preferably 1-3 short sentences). Avoid long explanations. If user asks for more detail, only then expand.";

    final url = Uri.parse('https://api.perplexity.ai/chat/completions');
    final headers = {
      'Authorization': 'Bearer $perplexityApiKey',
      'Content-Type': 'application/json',
    };

    final body = jsonEncode({
      'model': perplexityModel,
      'messages': [
        {'role': 'system', 'content': systemInstruction},
        {'role': 'user', 'content': userInput},
      ],
      // keep token small so replies are short and fast:
      'max_tokens': 500,
      'temperature': 0.2,
      // If the API supports it, we could request a 'concise' instruction — system message handles that.
    });

    try {
      final resp = await http
          .post(url, headers: headers, body: body)
          .timeout(Duration(seconds: 20));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        String reply = '';

        try {
          reply = data['choices'][0]['message']['content'].toString().trim();
        } catch (e) {
          reply = 'Sorry — unexpected response format from API.';
        }

        // As an extra safeguard, if the reply is long, shorten it to first 2 sentences.
        reply = _shortenToSentences(reply, 2);

        reply = reply.replaceAll(RegExp(r'\*'), '');
        reply = reply.replaceAll(RegExp(r'\[\d+\]'), '');

        setState(() {
          messages.add(Message(text: reply, isUser: false, time: _now()));
          showTyping = false;
        });

        // speak the reply
        await _tts.setLanguage(selectedLocale);
        await _tts.speak(reply);
      } else {
        print('Perplexity error: ${resp.statusCode} ${resp.body}');
        _addSystemMessage('Perplexity API error: ${resp.statusCode}.');
      }
    } catch (e) {
      print('Error calling Perplexity: $e');
      _addSystemMessage('Network error: could not call Perplexity.');
    } finally {
      setState(() {
        isLoading = false;
        showTyping = false;
      });
      _scrollToBottomLater();
    }
  }

  // If reply is very long, keep only the first `maxSentences` sentences.
  String _shortenToSentences(String text, int maxSentences) {
    if (text.isEmpty) return text;
    final regex = RegExp(r'([^\.\!\?]+[\.\!\?])', multiLine: true);
    final matches = regex.allMatches(text);
    if (matches.isEmpty) return text;
    final take = matches
        .take(maxSentences)
        .map((m) => m.group(0)!.trim())
        .join(' ');
    return take.isEmpty ? text : take;
  }

  // Build the beautiful UI
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            _languageRow(),
            Expanded(child: _chatList()),
            if (showTyping)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _typingIndicator(),
              ),
            _controls(),
            SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 2,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Perplexity-like small logo area (simple P circle)
          CircleAvatar(
            backgroundColor: Colors.deepPurple,
            child: Text(
              'P',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Smart Voice Assistant',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Short answers • Fast • Multilingual',
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _languageRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedLocale,
                  items:
                      languages.entries.map((e) {
                        return DropdownMenuItem<String>(
                          value: e.value,
                          child: Text(e.key),
                        );
                      }).toList(),
                  onChanged: (v) {
                    if (v != null) setState(() => selectedLocale = v);
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          InkWell(
            onTap: () {
              // quick help tooltip
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: Text('How it works'),
                      content: Text(
                        'Tap the mic and speak. Mic auto-stops after you finish. Replies are short and will be spoken aloud.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text('OK'),
                        ),
                      ],
                    ),
              );
            },
            child: Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.info_outline, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _chatList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: messages.length,
        padding: EdgeInsets.only(top: 12, bottom: 12),
        itemBuilder: (context, idx) {
          final m = messages[idx];
          return _chatBubble(m);
        },
      ),
    );
  }

  Widget _chatBubble(Message m) {
    final isUser = m.isUser;
    final avatar =
        isUser
            ? CircleAvatar(
              backgroundColor: Colors.deepPurple,
              child: Icon(Icons.person, color: Colors.white),
            )
            : CircleAvatar(
              backgroundColor: Colors.grey[200],
              child: Icon(Icons.smart_toy, color: Colors.deepPurple),
            );
    final bubbleColor =
        isUser ? Colors.deepPurple.withOpacity(0.12) : Colors.white;
    final align = isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius =
        isUser
            ? BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            )
            : BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(16),
              bottomRight: Radius.circular(16),
            );

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) avatar,
          SizedBox(width: isUser ? 0 : 10),
          Flexible(
            child: Column(
              crossAxisAlignment: align,
              children: [
                AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: radius,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: align,
                    children: [
                      Text(
                        m.text,
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                      ),
                      SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            m.time,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 6),
                          if (isUser)
                            Icon(
                              Icons.done_all,
                              size: 14,
                              color: Colors.blueAccent,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: isUser ? 10 : 0),
          if (isUser) avatar,
        ],
      ),
    );
  }

  Widget _typingIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        SizedBox(width: 16),
        CircleAvatar(
          radius: 14,
          backgroundColor: Colors.grey[200],
          child: Icon(Icons.smart_toy, color: Colors.deepPurple, size: 18),
        ),
        SizedBox(width: 10),
        Container(
          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(width: 6),
              _dot(),
              SizedBox(width: 4),
              _dot(delay: 150),
              SizedBox(width: 4),
              _dot(delay: 300),
            ],
          ),
        ),
      ],
    );
  }

  Widget _dot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.4, end: 1.0),
      duration: Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      builder: (context, v, child) {
        return Opacity(
          opacity: v,
          child: CircleAvatar(radius: 5, backgroundColor: Colors.deepPurple),
        );
      },
      onEnd: () {
        // this widget will animate by itself because of tween; no extra work needed
      },
    );
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _scrollController.dispose();
    super.dispose();
  }
}

class Message {
  final String text;
  final bool isUser;
  final String time;

  Message({required this.text, required this.isUser, required this.time});
}
