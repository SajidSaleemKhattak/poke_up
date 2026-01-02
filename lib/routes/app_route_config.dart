// ignore_for_file: depend_on_referenced_packages

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:poke_up/services/auth/auth_service.dart';
import 'package:poke_up/services/profile/profile_service.dart';

import 'package:poke_up/ux/screens/welcome_page_1.dart';
import 'package:poke_up/ux/screens/login_page_2.dart';
import 'package:poke_up/ux/screens/create_profile_3.dart';
import 'package:poke_up/ux/screens/interest_selection_4.dart';

import 'package:poke_up/ux/screens/home_feed_5.dart';
import 'package:poke_up/ux/screens/map_vibes_screen_6.dart';
import 'package:poke_up/ux/screens/conversations_screen_7.dart';
import 'package:poke_up/ux/screens/profile_screen_8.dart';

import 'package:poke_up/ux/sub_screens/settings_screen.dart';
import 'package:poke_up/ux/sub_screens/community_guideline_screen.dart';

import 'package:poke_up/ux/screens/Navigation.dart';

class MyAppRouter {
  final GoRouter approuter = GoRouter(
    initialLocation: '/',
    refreshListenable: GoRouterRefreshStream(AuthService.authStateChanges()),
    redirect: (context, state) async {
      final user = FirebaseAuth.instance.currentUser;
      final location = state.matchedLocation;

      // ─────────────────────────────
      // 1️⃣ USER NOT LOGGED IN
      // ─────────────────────────────
      if (user == null) {
        // allow welcome + login only
        if (location == '/' || location == '/login') {
          return null;
        }
        return '/login';
      }

      // ─────────────────────────────
      // 2️⃣ USER LOGGED IN → LOAD PROFILE
      // ─────────────────────────────
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final data = snapshot.data();

      if (data == null) {
        // corrupted state → force login
        return '/login';
      }

      final isBasicComplete = ProfileService.isBasicProfileComplete(data);
      final isOnboardingComplete = ProfileService.isOnboardingComplete(data);

      // ─────────────────────────────
      // 3️⃣ FORCE BASIC PROFILE
      // ─────────────────────────────
      if (!isBasicComplete && location != '/create_profile') {
        return '/create_profile';
      }

      // ─────────────────────────────
      // 4️⃣ FORCE INTEREST SELECTION
      // ─────────────────────────────
      if (isBasicComplete &&
          !isOnboardingComplete &&
          location != '/interest_selection') {
        return '/interest_selection';
      }

      // ─────────────────────────────
      // 5️⃣ PREVENT GOING BACK
      // ─────────────────────────────
      if (isOnboardingComplete &&
          (location == '/' ||
              location == '/login' ||
              location == '/create_profile' ||
              location == '/interest_selection')) {
        return '/app/home_feed';
      }

      return null; // allow navigation
    },

    routes: [
      // ─────────── Public / Entry ───────────
      GoRoute(
        name: 'home',
        path: '/',
        builder: (context, state) => const WelcomePage1(),
      ),
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => const LoginPage2(),
      ),
      GoRoute(
        name: 'create_profile',
        path: '/create_profile',
        builder: (context, state) => const CreateProfile3(),
      ),
      GoRoute(
        name: 'interest_selection',
        path: '/interest_selection',
        builder: (context, state) => const InterestSelection4(),
      ),

      // ─────────── App Shell ───────────
      ShellRoute(
        builder: (context, state, child) {
          return Navigation(child: child);
        },
        routes: [
          GoRoute(
            name: 'home_feed',
            path: '/app/home_feed',
            builder: (context, state) => const HomeFeed5(),
          ),
          GoRoute(
            name: 'map',
            path: '/app/map',
            builder: (context, state) => const MapVibesScreen(),
          ),
          GoRoute(
            name: 'conversations',
            path: '/app/conversations',
            builder: (context, state) => const ConversationsScreen(),
          ),
          GoRoute(
            name: 'profile',
            path: '/app/profile',
            builder: (context, state) => const ProfileScreen(),
            routes: [
              GoRoute(
                name: 'settings',
                path: 'settings',
                builder: (context, state) => const SettingsScreen(),
              ),
              GoRoute(
                name: 'community_guidelines',
                path: 'community_guideline',
                builder: (context, state) => const CommunityGuidelinesScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

final router = MyAppRouter().approuter;

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
