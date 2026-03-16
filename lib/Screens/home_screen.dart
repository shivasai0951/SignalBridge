import 'package:flutter/material.dart';
import '../Utility/appColors.dart';
import 'Dashboard.dart';
import 'save_contact_screen.dart';
import 'history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int selectedIndex = 0;

  final List screens = const [
    DashboardScreen(),
    SaveContactScreen(),
    HistoryScreen(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: screens[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: AppColors.appBar,
        selectedItemColor: AppColors.primaryButton,
        unselectedItemColor: Colors.grey,
        currentIndex: selectedIndex,
        onTap: onTabTapped,

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Dashboard",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: "Save Contact",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "History",
          ),

        ],
      ),
    );
  }
}