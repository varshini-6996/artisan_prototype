import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Artisan App",
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomeScreen(),
    );
  }
}

// ---------------- Home with Bottom Nav ----------------
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    StoryScreen(),
    VoiceScreen(),
    EcoImpactScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: "Stories",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic),
            label: "Voice",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: "Eco Impact",
          ),
        ],
      ),
    );
  }
}

// ---------------- Screen 1: Artisan Stories ----------------
class StoryScreen extends StatefulWidget {
  @override
  _StoryScreenState createState() => _StoryScreenState();
}

class _StoryScreenState extends State<StoryScreen> {
  final TextEditingController _controller = TextEditingController();
  String story = "";
  String originalStory = "";
  bool loading = false;

  // Generate Story
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

  // Translate Story
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
      appBar: AppBar(title: const Text("Artisan Storytelling")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration:
                  const InputDecoration(labelText: "Enter product name"),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => generateStory(_controller.text),
              child: const Text("Generate Story"),
            ),
            const SizedBox(height: 20),
            loading
                ? const CircularProgressIndicator()
                : Expanded(
                    child: SingleChildScrollView(
                      child: Text(story, style: const TextStyle(fontSize: 16)),
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
                          textStyle: const TextStyle(fontSize: 14),
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

// ---------------- Screen 2: Voice Recording (Enhanced) ----------------
class VoiceScreen extends StatelessWidget {
  const VoiceScreen({super.key});

  final List<Map<String, String>> recordings = const [
    {
      "name": "Ravi Kumar",
      "product": "Handwoven Jute Bag",
      "image":
          "https://images.unsplash.com/photo-1588776814546-374f4c3d1df5",
    },
    {
      "name": "Anita Sharma",
      "product": "Handcrafted Cotton Scarf",
      "image":
          "https://images.unsplash.com/photo-1608151350326-5e4c0c7b27d0",
    },
    {
      "name": "Suresh Patel",
      "product": "Terracotta Pot",
      "image":
          "https://images.unsplash.com/photo-1598970434795-0c54fe7c0642",
    },
    {
      "name": "Meena Gupta",
      "product": "Madhubani Painting",
      "image":
          "https://images.unsplash.com/photo-1562158070-2a2a37b0e3f5",
    },
    {
      "name": "Ramesh Yadav",
      "product": "Bamboo Basket",
      "image":
          "https://images.unsplash.com/photo-1593452972726-9c1eea4e62e4",
    },
    {
      "name": "Priya Desai",
      "product": "Block-printed Saree",
      "image":
          "https://images.unsplash.com/photo-1603415526960-f7e0328a3c6c",
    },
    {
      "name": "Vikram Singh",
      "product": "Hand-carved Wooden Toy",
      "image":
          "https://images.unsplash.com/photo-1590073248234-8698f3015c70",
    },
    {
      "name": "Lakshmi Iyer",
      "product": "Clay Diya",
      "image":
          "https://images.unsplash.com/photo-1610243605335-b8de62f2e87c",
    },
  ];

  void recordVoice(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Recording started (simulation)..."),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voice Interaction")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.mic),
                label: const Text("Record New Voice"),
                onPressed: () => recordVoice(context),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: recordings.length,
                itemBuilder: (context, index) {
                  final rec = recordings[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      leading: CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(rec["image"]!),
                      ),
                      title: Text(rec["name"]!,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 16)),
                      subtitle: Text(rec["product"]!,
                          style: const TextStyle(fontSize: 14)),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content:
                                  Text("Playing recording of ${rec["name"]}"),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


// ---------------- Screen 3: Eco Impact ----------------
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
    "Plastic bags can take up to 1000 years to decompose, polluting our land and oceans for generations. They contribute to microplastics in soil and water, harming wildlife and entering the human food chain. In contrast, handwoven jute bags are 100% biodegradable, breaking down naturally without releasing harmful chemicals. Choosing jute over plastic significantly reduces environmental harm and helps conserve our planet's resources.",
  
    "Artisan products, like handwoven cotton and jute, are not only eco-friendly but also resource-efficient. Handwoven cotton uses about 60% less water compared to polyester production. The dyes used in traditional crafts are often natural, minimizing chemical pollution. By supporting these artisans, we sustain traditional crafts and provide fair livelihoods, promoting social and economic sustainability. Every purchase encourages environmentally responsible practices and fosters a culture of mindful consumption.",

    "Using eco-friendly alternatives in daily life, such as reusable jute bags, wooden utensils, or bamboo products, can drastically reduce waste and energy consumption. Educating consumers about the impact of plastic and synthetic materials helps build awareness. Communities that embrace artisan-made eco products contribute to a healthier ecosystem and inspire future generations to adopt sustainable habits.",

    "Collaborations between customers and artisans for customized, sustainable products not only provide unique items but also create a closer connection to the environment. When buyers understand the story behind a product—the materials, the craft, and the effort—they are more likely to make responsible choices. Supporting such products reduces carbon footprints and strengthens local economies, making eco-conscious living both practical and meaningful."
];


    return Scaffold(
      appBar: AppBar(title: const Text("Eco Impact")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const Text(
                    "Eco Facts:",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...facts
                      .map((f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Text(f, style: const TextStyle(fontSize: 16)),
                          ))
                      .toList(),
                  const Divider(height: 30),
                  const Text(
                    "Want to know more?",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: "Enter a product (e.g., plastic bag)",
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => fetchEcoComparison(_controller.text),
                    child: const Text("Find Eco Alternative"),
                  ),
                  const SizedBox(height: 20),
                  loading
                      ? const CircularProgressIndicator()
                      : Text(
                          comparison,
                          style: const TextStyle(fontSize: 16),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
