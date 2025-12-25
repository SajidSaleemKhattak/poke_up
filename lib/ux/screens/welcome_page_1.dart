// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';

class WelcomePage1 extends StatelessWidget {
  const WelcomePage1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: AppStyling.secondaryBackgroundColor,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
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

                // 🔹 Image Card
                Container(
                  width: double.infinity,
                  height: 420,
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

                const SizedBox(height: 24),

                // 🔹 Primary Button
                SizedBox(
                  width: double.infinity,
                  height: 62,

                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppStyling.primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 20.0),
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

                const SizedBox(height: 10),
                Spacer(),

                // 🔹 Secondary Actions
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /* 1. OutlinedButton ------------------------------------------------ */
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                      ), // empty space around button
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ElevatedButton(
                        onPressed: () {
                          context.goNamed('login');
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 40,
                            vertical: 20,
                          ),
                        ),
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    /* 2. Phone icon ---------------------------------------------------- */
                    GestureDetector(
                      onTap: () {
                        context.goNamed("login");
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18.0,
                          vertical: 7,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.amberAccent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.phone_android_outlined,
                            size: 27,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 8),

                    /* 3. Mail icon ----------------------------------------------------- */
                    GestureDetector(
                      onTap: () {
                        context.goNamed('login');
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14.0,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(Icons.email_rounded, size: 30),
                        ),
                      ),
                    ),
                  ],
                ),

                const Spacer(),

                // 🔹 Footer
                const Padding(
                  padding: EdgeInsets.only(bottom: 12),
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
