import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'home_screen.dart';
import 'matches_screen.dart';
import 'teams_screen.dart';
import 'bracket_screen.dart';
import 'history/history_home_screen.dart';
import '../providers/match_provider.dart';

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    MatchesScreen(),
    TeamsScreen(),
    BracketScreen(),
    HistoryHomeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: NavigationBar(
        height: 68,
        elevation: 8,
        backgroundColor: isDark ? const Color(0xFF131A22) : Colors.white,
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          if (index == 1) {
            Provider.of<MatchProvider>(
              context,
              listen: false,
            ).setSearchQuery('');
          }
          setState(() {
            _currentIndex = index;
          });
        },
        indicatorColor: Theme.of(context).primaryColor.withValues(alpha: 0.15),
        destinations: [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.home,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.sports_soccer_outlined,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.sports_soccer,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Matches',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.leaderboard_outlined,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.leaderboard,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Groups',
          ),
          NavigationDestination(
            icon: Icon(
              Icons.emoji_events_outlined,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.emoji_events,
              color: Theme.of(context).primaryColor,
            ),
            label: 'Bracket',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.history_edu_outlined,
              color: isDark ? Colors.grey : Colors.grey.shade600,
            ),
            selectedIcon: Icon(
              Icons.history_edu,
              color: Theme.of(context).primaryColor,
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
