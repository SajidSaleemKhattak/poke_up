import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:poke_up/services/poke/poke_service.dart';
import 'package:poke_up/constants/app_styling.dart';

class CreatePokeScreen extends StatefulWidget {
  final Position position;

  const CreatePokeScreen({super.key, required this.position});

  @override
  State<CreatePokeScreen> createState() => _CreatePokeScreenState();
}

class _CreatePokeScreenState extends State<CreatePokeScreen> {
  final TextEditingController _textController = TextEditingController();

  String selectedCategory = 'Food';
  double sliderValue = 1;
  bool friendsOnly = true;
  bool isSubmitting = false;

  final List<Map<String, String>> categories = [
    {'label': 'Food', 'emoji': '🍔'},
    {'label': 'Chill', 'emoji': '🏠'},
    {'label': 'Active', 'emoji': '🏃'},
    {'label': 'Study', 'emoji': '📚'},
    {'label': 'Party', 'emoji': '🎉'},
    {'label': 'Gaming', 'emoji': '🎮'},
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _submitPoke() async {
    if (_textController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please write something')));
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await PokeService.createPoke(
        text: _textController.text,
        category: selectedCategory,
        validForHours: sliderValue,
        friendsOnly: friendsOnly,
        position: widget.position,
      );

      Navigator.pop(context); // back to HomeFeed
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to create poke')));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyling.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header
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

              // Text input
              Container(
                height: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "What’s the vibe? (e.g., Coffee run ☕)",
                    border: InputBorder.none,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Categories
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: categories.map((cat) {
                  final isSelected = selectedCategory == cat['label'];
                  return GestureDetector(
                    onTap: () {
                      setState(() => selectedCategory = cat['label']!);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: isSelected ? Colors.blue : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.transparent : Colors.grey,
                        ),
                      ),
                      child: Text(
                        "${cat['emoji']} ${cat['label']}",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // Slider
              Slider(
                value: sliderValue,
                min: 0.25,
                max: 24,
                divisions: 4,
                label: "${sliderValue.round()}h",
                onChanged: (val) {
                  setState(() => sliderValue = val);
                },
              ),

              const SizedBox(height: 28),

              // Friends only
              SwitchListTile(
                value: friendsOnly,
                onChanged: (v) => setState(() => friendsOnly = v),
                title: const Text("Friends only"),
              ),

              const SizedBox(height: 40),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitPoke,
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Send Poke", style: TextStyle(fontSize: 18)),
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
