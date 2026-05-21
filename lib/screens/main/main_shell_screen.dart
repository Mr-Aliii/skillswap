import 'package:flutter/material.dart';
import 'package:skill_swap/screens/chat/conversations_screen.dart';
import 'package:skill_swap/screens/home/home_screen.dart';
import 'package:skill_swap/screens/match/match_screen.dart';
import 'package:skill_swap/screens/profile/profile_screen.dart';
import 'package:skill_swap/screens/settings/settings_screen.dart';
import 'package:skill_swap/theme/app_colors.dart';

/// Bottom navigation shell for main app tabs.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    MatchScreen(),
    ConversationsScreen(),
    ProfileScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),
      floatingActionButton: _index == 0
          ? FloatingActionButton.extended(
              onPressed: () => setState(() => _index = 1),
              backgroundColor: AppColors.primary,
              icon: const Icon(Icons.explore, color: Colors.white),
              label: const Text(
                'Discover',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.people_outline),
            selectedIcon: Icon(Icons.people),
            label: 'Match',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
