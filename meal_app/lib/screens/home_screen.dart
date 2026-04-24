import 'package:flutter/material.dart';
import 'discover_screen.dart';
import 'favourites_screen.dart';
import 'my_recipes_screen.dart';
import 'today_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DiscoverScreen(),
    const FavouritesScreen(),
    const MyRecipesScreen(),
    const TodayScreen(),
  ];

  final List<String> _titles = [
    'Discover',
    'Favourites',
    'My Recipes',
    'Today',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.book),
            label: 'My Recipes',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant),
            label: 'Today',
          ),
        ],
      ),
    );
  }
}
