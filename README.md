# 🎙️ AI Voice Assistant (Flutter)

An intelligent, **real-time voice chatbot** built using **Flutter** and the **Perplexity API**, designed to deliver concise, human-like answers with natural voice interaction.  The assistant listens to your voice, processes the query through **Perplexity AI**, and replies with a **female AI voice** — all in a sleek, modern chat interface inspired by ChatGPT and Perplexity.

---

## 🚀 Features

- 🎤 **Voice Recognition** — Speak naturally; your voice is automatically transcribed to text.  
- 🤖 **Perplexity AI Integration** — Uses your **Perplexity Pro API key** for real-time intelligent answers.  
- 🗣️ **Text-to-Speech (TTS)** — Natural **female voice** replies with adjustable pitch and speed.  
- ⚡ **Concise Replies** — Optimized prompt structure for short, clear, and meaningful answers.  
- 🧏 **Auto Mic Stop** — Microphone turns off automatically after your speech ends.  
- 💬 **Chat UI** — User and bot avatars with smooth, animated chat bubbles.  
- 🌐 **Multi-Language Ready** — Supports English, Hindi, Telugu (extendable).  
- 💡 **Cross-Platform** — Works on Android, iOS, and Web.

---

## 🧠 How It Works

1. 🎙️ **User Speaks** → App captures your voice using `speech_to_text`.  
2. 💬 **Speech to Text** → Converts speech into a text query.  
3. 🛰️ **Send Query to Perplexity API** → Sends query through HTTPS using your `PERPLEXITY_API_KEY`.  
4. 🧩 **AI Response** → Perplexity returns a concise, meaningful reply.  
5. 🗣️ **Text to Speech** → App reads the response in a natural female voice.  
6. 💬 **Chat Display** → Conversation appears beautifully with user and AI icons.

---

## 🧩 Tech Stack

| Component | Technology |
|------------|-------------|
| **Frontend** | Flutter (Dart) |
| **Voice Input** | `speech_to_text` |
| **AI Engine** | Perplexity API (Sonar / Sonar Pro / Sonar Reasoning) |
| **Voice Output** | `flutter_tts` |
| **UI Design** | ChatGPT / Perplexity-style widgets |
| **HTTP Requests** | `http` package |
| **State Management** | Simple setState / Provider (optional) |

---

## 🔑 Setup Instructions

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/<your-username>/perplexity-voice-assistant.git
cd perplexity-voice-assistant

```

2️⃣ Add Dependencies
Add these in your pubspec.yaml:

```
dependencies:
  flutter:
    sdk: flutter
  http: ^1.2.0
  flutter_tts: ^3.8.5
  speech_to_text: ^6.5.0
Then install them:

flutter pub get

```

3️⃣ Configure Your API Key
Create a .env file in your project root:

```
PERPLEXITY_API_KEY=your_api_key_here
Or define it directly inside your Dart code (for testing only).

You can get your key from the Perplexity Pro dashboard (Airtel Thanks offer supported).

```

4️⃣ Example API Call
dart
```
final response = await http.post(
  Uri.parse('https://api.perplexity.ai/chat/completions'),
  headers: {
    'Authorization': 'Bearer $apiKey',
    'Content-Type': 'application/json',
  },
  body: jsonEncode({
    'model': 'sonar-pro', // can also use sonar or sonar-reasoning
    'messages': [
      {'role': 'user', 'content': query}
    ],
  }),
);
```
5️⃣ Run the App
```
flutter run
```

---

## 🎨 UI Highlights
- 💬 Animated Chat Bubbles
- 👤 User Avatar (Self Icon)
- 🤖 Perplexity Bot Avatar
- 🎛️ Mic Button with Listening Animation
- 🕹️ Auto-stop Mic Detection
- 💫 Smooth Scroll-to-End Animation
- 🌍 Multi-Language Support
Easily switch languages:

```
await _tts.setLanguage("en-US"); // English
await _tts.setLanguage("hi-IN"); // Hindi
await _tts.setLanguage("te-IN"); // Telugu
```
Change to female voice (if available):

```
await _tts.setVoice({"name": "en-us-x-sfg#female_1-local", "locale": "en-US"});
```

## 💬 Example Conversation Flow
User (🎙️): “What is quantum computing?”
Mic: Auto stops after you finish speaking.
AI (🤖): “Quantum computing uses quantum bits to perform operations faster than traditional computers.”
TTS: Speaks the reply in a natural female voice.
Chat: Displays your message and response beautifully with avatars and smooth animation.

---

## 📸 Screenshots

<img width="1070" height="680" alt="image" src="https://github.com/user-attachments/assets/b7795808-f309-4a8e-86ab-163aad1ffb04" />




## 💡 Benefits
- ✅ Fast, compact answers — designed for brevity and clarity.
- ✅ Hands-free operation — speak and listen effortlessly.
- ✅ Smart, human-like interaction powered by Perplexity.
- ✅ Cross-platform support across Android, iOS, and Web.
- ✅ Simple architecture that’s easy to extend and maintain.
- ✅ Supports multilingual expansion for broader use.

  ---

## 🧭 Use Cases
- 🧠 Education Assistant — Ask study-related questions.
- 💼 Personal Productivity Bot — Task, schedule, or quick facts.
- 📰 News Summarizer — Get short, factual news updates.
- 🌍 Language Translator — Convert queries into multiple languages.
- 🧘 Wellness Companion — Voice-based journaling or chat companion.
- 🚀 Future Enhancements
- 🌐 Multi-model support (GPT, Gemini, Claude).
- 🧠 Local caching for offline history.
- 🔊 Emotion-based speech tone detection.
- 🪄 Real-time text animation like ChatGPT.
- 📡 Smart context memory for long-term chat.
- 🎧 Offline voice & TTS mode.

---

## 🧑‍💻 Developer Info
Author: S. Chandu

Role: Software Freelance

Institution: Acharya Nagarjuna University

Department: B.Tech AI & ML

Languages Supported: English, Hindi, Telugu

---

## 🏆 Acknowledgements
Perplexity AI — for the reasoning API
Flutter — for beautiful cross-platform UI
Airtel Thanks — for API key offer integration

## Disclaimer 

- In The voice Assistant Application You can Use my Perplexcity APi Key for demo purpose, not on Production
- i 've Place The Api Key in the Main.dart File in Flutter Project in the Place oF Api Key on Commenting the Line
- Get The Key Test The Demo and Enjoy With The Voice Assistant Seamlessly 👍

---

## 📄 License
This project is licensed under the MIT License.
You are free to use, modify, and distribute this project for learning or development purposes.

---


