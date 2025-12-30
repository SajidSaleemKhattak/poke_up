// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';

class WelcomePage1 extends StatelessWidget {
  const WelcomePage1({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomLeft,
              colors: [Color(0xFFE1F3F6), Color(0xFFEEF2FF), Color(0xFFE1F3F6)],
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // 🔹 App Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(
                      Icons.bolt_rounded,
                      size: 28,
                      color: AppStyling.primaryColor,
                    ),
                    SizedBox(width: 6),
                    Text(
                      "PokeUp",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // 🔹 Image Card (responsive)
                Container(
                  width: double.infinity,
                  height: screenHeight * 0.45, // 🔥 adaptive height
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    "assets/images/welcome_screen.png",
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 28),

                // 🔹 Headline
                Text.rich(
                  TextSpan(
                    text: "Turn boredom into\n",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                    ),
                    children: const [
                      TextSpan(
                        text: "bonds",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppStyling.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // 🔹 Subtitle
                const Text(
                  "Spontaneous meetups for the moment.\nNo pressure, just vibes.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: AppStyling.primaryColorLight,
                  ),
                ),

                SizedBox(height: screenHeight * 0.06),

                // 🔹 Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyling.primaryColor,
                    ),
                    onPressed: () {
                      context.goNamed('login');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Sign Up Free",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: AppStyling.filtersBackground,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward,
                          size: 24,
                          color: AppStyling.filtersBackground,
                        ),
                      ],
                    ),
                  ),
                ),

                // 🔹 Footer
                SizedBox(height: screenHeight * 0.03),
                const Padding(
                  padding: EdgeInsets.only(top: 15),
                  child: Text(
                    "By continuing, you agree to our Terms & Privacy Policy.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
