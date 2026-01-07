// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/services/profile/profile_service.dart';

class InterestSelection4 extends StatefulWidget {
  const InterestSelection4({super.key});

  @override
  State<InterestSelection4> createState() => _InterestSelection4State();
}

class _InterestSelection4State extends State<InterestSelection4> {
  final Set<String> selectedInterests = {};

  void toggleInterest(String interest) {
    setState(() {
      if (selectedInterests.contains(interest)) {
        selectedInterests.remove(interest);
      } else {
        selectedInterests.add(interest);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyling.secondaryBgColor,
      body: SafeArea(
        child: Column(
          children: [
            // 🔹 Scrollable content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),

                    // 🔹 Header
                    Row(
                      children: const [
                        Spacer(),
                        Text(
                          "ONBOARDING",
                          style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Spacer(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 🔹 Title
                    Text.rich(
                      TextSpan(
                        text: "What gets you\n",
                        style: TextStyle(
                          fontSize: 32.0,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                        ),
                        children: const [
                          TextSpan(
                            text: "hyped?",
                            style: TextStyle(
                              fontSize: 32.0,
                              fontWeight: FontWeight.w800,
                              color: AppStyling.primaryColor,
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    const Text(
                      "Pick at least 3. We'll show you who's down for the same stuff.",
                      style: TextStyle(
                        fontSize: 16,
                        color: AppStyling.secondaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 🔹 Search bar
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: AppStyling.white,
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.search, color: Colors.grey),
                          SizedBox(width: 8),
                          Text(
                            "Search interests (e.g. Hiking)",
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),

                    // 🔹 Food & Drink
                    _sectionTitle("🍴 Food & Drink"),
                    _chipsWrap([
                      "🌮 Tacos",
                      "☕ Coffee Runs",
                      "🍣 Sushi",
                      "🍕 Late Night Pizza",
                      "🧋 Boba Tea",
                      "🥐 Brunch",
                    ]),

                    const SizedBox(height: 28),

                    // 🔹 Vibes
                    _sectionTitle("✨ Vibes"),
                    _chipsWrap([
                      "🎬 Movie Night",
                      "🎮 Gaming",
                      "🚶‍♀️ Hot Girl Walk",
                      "🍹 Rooftop Drinks",
                      "📖 Book Time",
                      "😌 Just Chilling",
                    ]),

                    const SizedBox(height: 28),

                    // 🔹 Fitness & Wellness
                    _sectionTitle("💪 Fitness & Wellness"),
                    _chipsWrap([
                      "🏋️ Gym",
                      "🧘 Yoga",
                      "🏃 Running",
                      "🥗 Healthy Eating",
                      "🧠 Mental Health",
                      "🛌 Self Care",
                    ]),

                    const SizedBox(height: 28),

                    // 🔹 Sports
                    _sectionTitle("🏀 Sports"),
                    _chipsWrap([
                      "⚽ Football",
                      "🏀 Basketball",
                      "🎾 Tennis",
                      "🏏 Cricket",
                      "🏓 Table Tennis",
                      "🏐 Volleyball",
                    ]),

                    const SizedBox(height: 28),

                    // 🔹 Creative & Arts
                    _sectionTitle("🎨 Creative & Arts"),
                    _chipsWrap([
                      "🎵 Music",
                      "📸 Photography",
                      "🎬 Filmmaking",
                      "✍️ Writing",
                      "🖌️ Painting",
                      "🎭 Theatre",
                    ]),

                    const SizedBox(height: 40.0),
                  ],
                ),
              ),
            ),

            // 🔹 Bottom CTA
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedInterests.length >= 3
                      ? () async {
                          try {
                            await ProfileService.updateInterests(
                              selectedInterests.toList(),
                            );

                            // ✅ onboarding fully completed
                            context.goNamed("home_feed");
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Failed to save interests"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppStyling.primaryColor,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Find my people",
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
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Section title
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
      ),
    );
  }

  // 🔹 Chips wrapper
  Widget _chipsWrap(List<String> items) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items.map((item) {
        final bool isSelected = selectedInterests.contains(item);

        return GestureDetector(
          onTap: () => toggleInterest(item),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: isSelected ? AppStyling.primaryColor : Colors.white,
              border: Border.all(
                color: isSelected
                    ? AppStyling.primaryColor
                    : Colors.grey.shade300,
              ),
            ),
            child: Text(
              item,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
