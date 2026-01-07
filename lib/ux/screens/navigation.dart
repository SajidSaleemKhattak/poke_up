// ignore_for_file: depend_on_referenced_packages
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poke_up/constants/app_styling.dart';
import 'package:poke_up/services/chat/chat_service.dart';

class Navigation extends StatelessWidget {
  final Widget child;

  const Navigation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final int currentIndex = _getCurrentIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: AppStyling.primaryColor, // brand color
        unselectedItemColor: AppStyling.primaryColorLight,

        onTap: (index) {
          final String location = GoRouterState.of(context).uri.toString();

          switch (index) {
            case 0:
              if (!location.startsWith('/app/home_feed')) {
                context.go('/app/home_feed');
              }
              break;

            case 1:
              if (!location.startsWith('/app/map')) {
                context.go('/app/map');
              }
              break;

            case 2:
              if (!location.startsWith('/app/conversations')) {
                context.go('/app/conversations');
              }
              break;

            case 3:
              if (!location.startsWith('/app/profile')) {
                context.go('/app/profile');
              }
              break;
          }
        },

        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: _ChatsIcon(), label: 'Chats'),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  int _getCurrentIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    if (location.startsWith('/app/map')) return 1;
    if (location.startsWith('/app/conversations')) return 2;
    if (location.startsWith('/app/profile')) return 3;

    return 0; // home_feed
  }
}

class _ChatsIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Icon(Icons.chat);
  }
}
