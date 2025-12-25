// ignore_for_file: depend_on_referenced_packages

import 'package:go_router/go_router.dart';
import 'package:poke_up/ux/screens/create_profile_3.dart';
import 'package:poke_up/ux/screens/login_page_2.dart';
import 'package:poke_up/ux/screens/welcome_page_1.dart';

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
    ],
  );
}

final router = MyAppRouter().approuter;
