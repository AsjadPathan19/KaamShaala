import 'package:flutter/material.dart';
import 'package:work/screens/Home/NavBar/HomeScreen.dart';
import 'package:work/screens/Home/NavBar/profile_screen.dart';
import 'package:work/screens/Home/NavBar/post_job_screen.dart';

/// The main screen of the application that contains the bottom navigation bar
/// and manages navigation between different sections of the app
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // Current selected tab index
  int _selectedIndex = 0;

  // List of screens to display based on selected tab
  final List<Widget> _screens = [
    const HomeScreen(),
    const PostJobScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Main content area that displays the selected screen
      body: IndexedStack(index: _selectedIndex, children: _screens),

      // Bottom navigation bar for switching between screens
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline),
            activeIcon: Icon(Icons.add_circle),
            label: 'Post Job',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
