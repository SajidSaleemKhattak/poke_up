// ignore_for_file: depend_on_referenced_packages

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/services/auth/auth_service.dart';

class LoginPage2 extends StatefulWidget {
  const LoginPage2({super.key});

  @override
  State<LoginPage2> createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  final _formKey = GlobalKey<FormState>();
  bool _isSignup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 193, 241, 249), // top
                  Color.fromARGB(255, 234, 235, 235), // middle
                  Color.fromARGB(255, 234, 235, 235), // middle
                  Color.fromARGB(255, 234, 235, 235), // middle
                  Color.fromARGB(255, 180, 232, 241), // top
                  // bottom
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),

                      // 🔹 Logo
                      Container(
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppStyling.primaryColor,
                        ),
                        child: const Icon(
                          Icons.bolt_rounded,
                          size: 40,
                          color: AppStyling.primaryLight,
                        ),
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Title
                      Text.rich(
                        TextSpan(
                          text: "Kill the\n",
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                          ),
                          children: const [
                            TextSpan(
                              text: "Boredom.",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: AppStyling.primaryColor,
                              ),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 12),

                      const Text(
                        "Join the crew turning free time into\ngood times.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppStyling.secondaryColor,
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🔹 Segmented Control
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(40),
                          color: AppStyling.primaryLight,
                        ),
                        child: Row(
                          children: [
                            _segmentButton(
                              title: "Sign Up",
                              active: _isSignup,
                              onTap: () {
                                setState(() => _isSignup = true);
                              },
                            ),
                            _segmentButton(
                              title: "Log In",
                              active: !_isSignup,
                              onTap: () {
                                setState(() => _isSignup = false);
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🔹 Form
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Email or Phone"),
                            const SizedBox(height: 8),

                            _inputField(
                              hint: "Enter your email or phone",
                              icon: Icons.email_outlined,
                            ),

                            const SizedBox(height: 20),

                            Text(
                              _isSignup
                                  ? "Create your password"
                                  : "Enter your password to login",
                            ),
                            const SizedBox(height: 8),

                            _inputField(
                              hint: _isSignup
                                  ? "Create a password"
                                  : "Enter your password",
                              icon: Icons.lock_outline,
                              suffix: Icons.visibility_off_outlined,
                              obscure: true,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      // 🔹 CTA Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: () {
                            context.goNamed("create_profile");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppStyling.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Text(
                                "Let's Go",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: AppStyling.primaryLight,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.arrow_forward,
                                color: AppStyling.primaryLight,
                                size: 21,
                                fontWeight: FontWeight.w800,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 42),

                      // 🔹 Divider
                      Row(
                        children: const [
                          Expanded(child: Divider()),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "or hang with",
                              style: TextStyle(
                                fontSize: 16,
                                color: AppStyling.secondaryColor,
                              ),
                            ),
                          ),
                          Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // 🔹 Social Icons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              try {
                                final credential =
                                    await AuthService.signInWithGoogle();

                                if (credential == null) return;

                                final uid = credential.user!.uid;

                                final snapshot = await FirebaseFirestore
                                    .instance
                                    .collection('users')
                                    .doc(uid)
                                    .get();

                                final data = snapshot.data();

                                if (data == null ||
                                    data['firstName'] == null ||
                                    data['ageRange'] == null) {
                                  // ❌ Profile incomplete
                                  context.goNamed("create_profile");
                                } else {
                                  // ✅ Profile + onboarding complete
                                  context.goNamed("interest_selection");
                                }
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Sign in failed"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                                boxShadow: [
                                  // subtle lift
                                  BoxShadow(
                                    blurRadius: 6,
                                    color: Color(0x1A000000),
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(
                                15,
                              ), // space around icon
                              child: Image.asset(
                                "assets/images/Google_icon.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(width: 20),
                          _socialIcon(Icons.apple),
                          const SizedBox(width: 20),
                          _socialIcon(Icons.music_note),
                        ],
                      ),

                      const SizedBox(height: 32),

                      const Text(
                        "By signing up, you agree to our Terms and Privacy Policy.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppStyling.secondaryColor,
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // 🔹 Segmented Button
  Widget _segmentButton({
    required String title,
    required bool active,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: active ? Colors.white : Colors.transparent,
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: active ? Colors.black : AppStyling.secondaryColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔹 Input Field
  Widget _inputField({
    required String hint,
    required IconData icon,
    IconData? suffix,
    bool obscure = false,
  }) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppStyling.secondaryColor),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              obscureText: obscure,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 16,
                  color: Colors.blueGrey,
                  fontWeight: FontWeight.w300,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          if (suffix != null) Icon(suffix, color: AppStyling.secondaryColor),
        ],
      ),
    );
  }

  // 🔹 Social Icon
  Widget _socialIcon(IconData icon) {
    return Container(
      width: 56,
      height: 56,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
      ),

      child: Icon(icon, size: 30),
    );
  }
}
