// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateProfile3 extends StatefulWidget {
  const CreateProfile3({super.key});

  @override
  State<CreateProfile3> createState() => _CreateProfile3State();
}

class _CreateProfile3State extends State<CreateProfile3> {
  // ---- State ----
  bool photoAdded = false;
  String firstName = '';
  String? selectedAge;

  int get completedSteps {
    int count = 0;
    if (photoAdded) count++;
    if (firstName.isNotEmpty) count++;
    if (selectedAge != null) count++;
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // 🔹 Top bar
              Row(
                children: [
                  const Icon(Icons.arrow_back_ios_new),
                  const Spacer(),
                  Text(
                    "Step $completedSteps of 3",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Spacer(),
                ],
              ),

              const SizedBox(height: 16),

              // 🔹 Segmented Animated Progress Bar
              SegmentedProgressBar(currentStep: completedSteps),

              const SizedBox(height: 32),

              // 🔹 Title
              const Text(
                "Let's get the basics\ndown.",
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800),
              ),

              const SizedBox(height: 12),

              const Text(
                "Add a photo and tell us your name so friends can recognize you.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black45,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 36),

              // 🔹 Upload Photo
              Center(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey.shade200,
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 48,
                            color: Colors.grey,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              photoAdded = !photoAdded;
                            });
                          },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF2EC7F0),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "Upload Photo",
                      style: TextStyle(
                        color: Color(0xFF2EC7F0),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // 🔹 First Name
              const Text(
                "First Name",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),

              Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  color: Colors.grey.shade200,
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      firstName = value.trim();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: "e.g. Alex",
                    border: InputBorder.none,
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                "This will be shown on your public profile.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // 🔹 Age Range
              const Text(
                "Age Range",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  _ageChip("18–20"),
                  const SizedBox(width: 12),
                  _ageChip("21–24"),
                  const SizedBox(width: 12),
                  _ageChip("25+"),
                ],
              ),

              const Spacer(),

              // 🔹 Continue Button
              SizedBox(
                width: double.infinity,
                height: 59,
                child: ElevatedButton(
                  onPressed: completedSteps == 3
                      ? () {
                          context.goNamed("interest_selection");
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2EC7F0),
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        "Continue",
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Age chip widget
  Widget _ageChip(String label) {
    final bool isSelected = selectedAge == label;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedAge = label;
          });
        },
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: isSelected ? const Color(0xFF2EC7F0) : Colors.grey.shade200,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.black54,
                fontSize: 16.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// ===============================
/// Segmented Animated Progress Bar
/// ===============================
class SegmentedProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const SegmentedProgressBar({
    super.key,
    required this.currentStep,
    this.totalSteps = 3,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (index) {
        final bool isFilled = index < currentStep;

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: index == totalSteps - 1 ? 0 : 8),
            child: _Segment(filled: isFilled),
          ),
        );
      }),
    );
  }
}

class _Segment extends StatelessWidget {
  final bool filled;

  const _Segment({required this.filled});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 6,
        color: Colors.grey.shade300,
        child: AnimatedAlign(
          alignment: filled ? Alignment.centerLeft : Alignment.centerRight,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            width: filled ? MediaQuery.of(context).size.width : 0,
            height: 6,
            color: const Color(0xFF2EC7F0),
          ),
        ),
      ),
    );
  }
}
