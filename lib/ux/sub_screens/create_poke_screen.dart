// ignore_for_file: depend_on_referenced_packages

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

  // 🔹 VALID FOR slider
  static const List<double> labels = [0.25, 4, 12, 24];
  double sliderValue = 0.25; // default = 15 min

  bool friendsOnly = true;
  bool isSubmitting = false;

  String _label(double v) => v < 1 ? '${(v * 60).round()} m' : '${v.round()} h';

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
        text: _textController.text.trim(),
        category: selectedCategory,
        validForHours: sliderValue, // ✅ correct value
        friendsOnly: friendsOnly,
        position: widget.position,
      );

      Navigator.pop(context);
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
      backgroundColor: const Color(0xFFF6F8F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
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
                  color: AppStyling.white,
                ),
                child: TextField(
                  controller: _textController,
                  maxLines: null,
                  decoration: const InputDecoration(
                    hintText: "What’s the vibe? (e.g., Coffee run ☕)",
                    border: InputBorder.none,
                    hintStyle: TextStyle(
                      fontSize: 20,
                      color: AppStyling.secondaryColor,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // CATEGORY
              Text(
                "CATEGORY",
                style: TextStyle(
                  fontSize: 16,
                  color: AppStyling.secondaryColor,
                ),
              ),
              const SizedBox(height: 12),

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
                        color: isSelected
                            ? AppStyling.primaryColor
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Text(
                        "${cat['label']} ${cat['emoji']}",
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 32),

              // 🔹 VALID FOR (NEW SLIDER)
              Text(
                "VALID FOR",
                style: TextStyle(
                  fontSize: 16,
                  color: AppStyling.secondaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    Slider(
                      value: sliderValue,
                      min: 0.25,
                      max: 24,
                      divisions: labels.length - 1, // 🔥 4 stops
                      label: _label(sliderValue),
                      activeColor: AppStyling.primaryColor,
                      inactiveColor: AppStyling.primaryColor.withValues(
                        alpha: 0.25,
                      ),
                      thumbColor: Colors.white,
                      onChanged: (double v) {
                        // snap to nearest label
                        final closest = labels.reduce(
                          (a, b) => (v - a).abs() < (v - b).abs() ? a : b,
                        );
                        setState(() => sliderValue = closest);
                      },
                    ),
                    Container(
                      padding: const EdgeInsets.fromLTRB(19, 0, 19, 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text(
                            '15 m',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '4 h',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '12 h',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '24 h',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Friends only
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 5,
                ),
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    // thumb & track colours
                    switchTheme: SwitchThemeData(
                      thumbColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : Colors.grey.shade300,
                      ),
                      trackColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppStyling.primaryColor
                            : Colors.grey.shade300,
                      ),
                      overlayColor: WidgetStateProperty.all(Colors.transparent),
                    ),
                  ),
                  child: SwitchListTile(
                    value: friendsOnly,
                    onChanged: (v) => setState(() => friendsOnly = v),
                    title: const Text(
                      "Friends only",
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 18,
                      ),
                    ),
                    contentPadding: EdgeInsets.zero, // remove extra indent
                    dense: true, // tighter height
                    activeColor: Colors.white, // fallback (optional)
                  ),
                ),
              ),

              const SizedBox(height: 90),

              // Submit
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitPoke,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyling.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: isSubmitting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Send Poke",
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 7),
                            Icon(Icons.send, size: 20, color: Colors.white),
                          ],
                        ),
                ),
              ),

              // const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
