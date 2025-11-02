import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Artisan App",
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.transparent,
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black54,
          titleTextStyle:
              TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

// ---------------- Home Screen ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StoryScreen(),
    const VoiceScreen(),
    const EcoImpactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg_art.jpg'), // ✅ Ensure this file exists
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          color: Colors.black.withOpacity(0.4), // ✅ Overlay for visibility
          child: SafeArea(child: _screens[_currentIndex]),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black.withOpacity(0.7),
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Stories"),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: "Voice"),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: "Eco Impact"),
        ],
      ),
    );
  }
}

// ---------------- Story Screen ----------------
class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final TextEditingController _controller = TextEditingController();
  String story = "";
  String originalStory = "";
  bool loading = false;

  Future<void> generateStory(String productName) async {
    setState(() => loading = true);

    const apiKey = "AIzaSyCZqajBudYN9EIhONIaYrF-awi5dNri5G8";
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Write an engaging 2-paragraph story about the cultural origin and traditional making of $productName. Make it simple, emotional, and easy for buyers to understand."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final generated =
          data["candidates"][0]["content"]["parts"][0]["text"] ?? "No story";
      final cleaned = generated
          .split('\n')
          .where((line) => !line.toLowerCase().contains("attempted"))
          .join('\n');
      setState(() {
        story = cleaned;
        originalStory = cleaned;
      });
    } else {
      setState(() => story = "Error: ${response.body}");
    }

    setState(() => loading = false);
  }

  Future<void> translateStory(String language) async {
    if (originalStory.isEmpty) return;
    setState(() => loading = true);

    const apiKey = "AIzaSyCZqajBudYN9EIhONIaYrF-awi5dNri5G8";
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {"text": "Translate the following story into $language:\n$originalStory"}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translated =
          data["candidates"][0]["content"]["parts"][0]["text"] ?? "No translation";
      final cleaned = translated
          .split('\n')
          .where((line) =>
              !line.toLowerCase().contains("attempted") &&
              !line.toLowerCase().contains("excellent") &&
              !line.toLowerCase().contains("beautiful") &&
              !line.toLowerCase().contains("i translated"))
          .join('\n');
      setState(() => story = cleaned);
    } else {
      setState(() => story = "Error: ${response.body}");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Artisan Storytelling")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Enter product name",
                labelStyle: const TextStyle(color: Colors.white),
                filled: true,
                fillColor: Colors.white.withOpacity(0.2),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              onPressed: () => generateStory(_controller.text),
              child: const Text("Generate Story"),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator(color: Colors.white)
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(
                        story,
                        style: const TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
            const SizedBox(height: 12),
            if (story.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (var lang in ["Hindi", "Telugu", "Tamil", "Bengali"])
                    SizedBox(
                      width: MediaQuery.of(context).size.width / 2 - 24,
                      height: 40,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () => translateStory(lang),
                        child: Text(lang),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

// ---------------- Voice Screen ----------------
class VoiceScreen extends StatefulWidget {
  const VoiceScreen({super.key});

  @override
  State<VoiceScreen> createState() => _VoiceScreenState();
}

class _VoiceScreenState extends State<VoiceScreen> {
  final _player = AudioPlayer();

  final List<Map<String, String>> recordings = [
    {
      'name': 'Ravi Mohan',
      'product': 'Block Printing',
      'file': 'assets/audio/artisan.mp3',
  
    },
  ];

  Future<void> playAudio(String path) async {
    try {
      await _player.setAsset(path);
      await _player.play();
    } catch (e) {
      debugPrint("Playback error: $e");
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Voice Interaction")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.builder(
          itemCount: recordings.length,
          itemBuilder: (context, i) {
            final rec = recordings[i];
            return Card(
              color: Colors.white.withOpacity(0.2),
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: ListTile(
                leading:
                    const Icon(Icons.account_circle, size: 40, color: Colors.white),
                title: Text(rec['name'] ?? 'Unknown Artisan',
                    style: const TextStyle(color: Colors.white)),
                subtitle: Text(rec['product'] ?? 'Unknown Product',
                    style: const TextStyle(color: Colors.white70)),
                trailing: IconButton(
                  icon: const Icon(Icons.play_arrow, color: Colors.white),
                  onPressed: () => playAudio(rec['file']!),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ---------------- Eco Impact Screen ----------------
class EcoImpactScreen extends StatefulWidget {
  const EcoImpactScreen({super.key});

  @override
  _EcoImpactScreenState createState() => _EcoImpactScreenState();
}

class _EcoImpactScreenState extends State<EcoImpactScreen> {
  final TextEditingController _controller = TextEditingController();
  String comparison = "";
  bool loading = false;

  Future<void> fetchEcoComparison(String product) async {
    setState(() => loading = true);

    const apiKey = "AIzaSyCZqajBudYN9EIhONIaYrF-awi5dNri5G8";
    final url =
        "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text":
                    "Compare '$product' with its artisan-made eco-friendly alternative. Explain why the artisan version is better for the environment. Keep it simple and mention the product names."
              }
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        comparison =
            data["candidates"][0]["content"]["parts"][0]["text"] ?? "No result";
      });
    } else {
      setState(() => comparison = "Error: ${response.body}");
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final facts = [
      "Plastic bags can take up to 1000 years to decompose...",
      "Artisan products like handwoven cotton and jute are resource-efficient...",
      "Using eco-friendly alternatives like jute or bamboo reduces waste...",
      "Collaborations between customers and artisans promote sustainability...",
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(title: const Text("Eco Impact")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text("Eco Facts:",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  const SizedBox(height: 8),
                  ...facts.map(
                    (f) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(f,
                          style: const TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                  const Divider(height: 30, color: Colors.white54),
                  const Text("Want to know more?",
                      style: TextStyle(fontSize: 16, color: Colors.white)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: "Enter a product (e.g., plastic bag)",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => fetchEcoComparison(_controller.text),
                    child: const Text("Find Eco Alternative"),
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(comparison,
                          style: const TextStyle(fontSize: 16, color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
