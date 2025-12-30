import 'package:flutter/material.dart';

class CreatePokeScreen extends StatefulWidget {
  const CreatePokeScreen({super.key});

  @override
  State<CreatePokeScreen> createState() => _CreatePokeScreenState();
}

class _CreatePokeScreenState extends State<CreatePokeScreen> {
  String selectedCategory = 'Food';
  double sliderValue = 1; // hours
  bool friendsOnly = true;

  final List<Map<String, String>> categories = [
    {'label': 'Food', 'emoji': '🍔'},
    {'label': 'Chill', 'emoji': '🏠'},
    {'label': 'Active', 'emoji': '🏃'},
    {'label': 'Study', 'emoji': '📚'},
    {'label': 'Party', 'emoji': '🎉'},
    {'label': 'Gaming', 'emoji': '🎮'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // 🔹 Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.close, size: 26),
                  ),
                  const Spacer(),
                  const Text(
                    "New Poke",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 24),

              // 🔹 Vibe Input
              Container(
                height: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Stack(
                  children: [
                    TextField(
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: "What’s the vibe? (e.g., Coffee run ☕)",
                        hintStyle: TextStyle(fontSize: 18, color: Colors.grey),
                        border: InputBorder.none,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: const Color(0xFFEAF7FA),
                        child: const Icon(
                          Icons.location_on,
                          size: 18,
                          color: Color(0xFF2EC7F0),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🔹 Category
              const Text(
                "CATEGORY",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.map((cat) {
                  final bool isSelected = selectedCategory == cat['label'];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategory = cat['label']!;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: isSelected
                            ? const Color(0xFF2EC7F0)
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            cat['label']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(cat['emoji']!),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // 🔹 Valid For
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "VALID FOR",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      "${sliderValue.round()} Hour",
                      style: const TextStyle(
                        color: Color(0xFF2EC7F0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Slider(
                value: sliderValue,
                min: 0.25,
                max: 24,
                divisions: 4,
                activeColor: const Color(0xFF2EC7F0),
                inactiveColor: Colors.grey.shade300,
                label: "${sliderValue.round()}h",
                onChanged: (val) {
                  setState(() {
                    sliderValue = val;
                  });
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text("15m"),
                    Text("4h"),
                    Text("12h"),
                    Text("24h"),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // 🔹 Friends Only Toggle
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      backgroundColor: Color(0xFFEAF7FA),
                      child: Icon(Icons.people, color: Color(0xFF2EC7F0)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Friends Only",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            "Visible to your connections",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    Switch(
                      value: friendsOnly,
                      activeThumbColor: const Color(0xFF2EC7F0),
                      onChanged: (val) {
                        setState(() {
                          friendsOnly = val;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // 🔹 Send Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    // TODO: Send poke
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2EC7F0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Send Poke",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
