// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/ux/screens/create_profile_3.dart';
import 'package:poke_up/ux/screens/home_feed_5.dart';
import 'package:poke_up/ux/screens/interest_selection_4.dart';
import 'package:poke_up/ux/screens/login_page_2.dart';
import 'package:poke_up/ux/screens/welcome_page_1.dart';
import 'package:poke_up/ux/screens/Navigation.dart';

class MyAppRouter {
  final GoRouter approuter = GoRouter(
    routes: [
      GoRoute(
        name: "home",
        path: "/",
        builder: (context, state) => const WelcomePage1(),
      ),
      GoRoute(
        name: "login",
        path: "/login",
        builder: (context, state) => LoginPage2(),
      ),
      GoRoute(
        name: "create_profile",
        path: "/create_profile",
        builder: (context, state) => CreateProfile3(),
      ),
      GoRoute(
        name: "interest_selection",
        path: "/interest_selection",
        builder: (context, state) => InterestSelection4(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          return Navigation(child: child);
        },
        routes: [
          GoRoute(
            name: "home_feed",
            path: "/app/home_feed",
            builder: (context, state) => HomeFeed5(),
          ),
          GoRoute(
            name: "map",
            path: "/app/map",
            builder: (context, state) => Placeholder(),
          ),
          GoRoute(
            name: "chats",
            path: "/app/chats",
            builder: (context, state) => Placeholder(),
          ),
          GoRoute(
            name: "profile",
            path: "/app/profile",
            builder: (context, state) => Placeholder(),
          ),
        ],
      ),
    ],
  );
}

final router = MyAppRouter().approuter;
