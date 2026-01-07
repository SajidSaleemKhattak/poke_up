// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';

class WelcomePage1 extends StatelessWidget {
  const WelcomePage1({super.key});
  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final usableHeight = mq.size.height - mq.padding.top - mq.padding.bottom;

    return Scaffold(
      // 🔥 gradient under the whole scaffold (including the top safe-area)
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: mq.size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomLeft,
            colors: [Color(0xFFE1F3F6), Color(0xFFEEF2FF), Color(0xFFE1F3F6)],
          ),
        ),
        child: SafeArea(
          // keeps content below notch, but gradient is already painted behind
          bottom: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: usableHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // logo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.bolt_rounded,
                        size: 28,
                        color: AppStyling.primaryColor,
                      ),
                      SizedBox(width: 3),
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

                  // image
                  Container(
                    width: double.infinity,
                    height: usableHeight * 0.45,
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

                  // headline
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

                  // subtitle
                  const Text(
                    "Spontaneous meetups for the moment.\nNo pressure, just vibes.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppStyling.primaryColorLight,
                    ),
                  ),
                  SizedBox(height: usableHeight * 0.06),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppStyling.primaryColor,
                      ),
                      onPressed: () => context.goNamed('login'),
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

                  // footer + safe bottom
                  SizedBox(height: usableHeight * 0.03),
                  const Padding(
                    padding: EdgeInsets.only(top: 15, bottom: 24),
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
      ),
    );
  }
}
