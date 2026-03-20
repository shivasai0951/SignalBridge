import 'package:flutter/material.dart';
import 'package:signalbridge/Screens/ProfileEditScreen.dart';
import 'package:signalbridge/Screens/profile_view_screen.dart';
import 'Dashboard.dart';
import 'history_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  int currentIndex = 0;

  final List<Widget> pages  = const [
    DashboardScreen(),
    HistoryScreen(),
    ProfileViewScreen(),
  ];

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: AppBar(
          backgroundColor: const Color(0xFF1E293B),
          title: const Text(
            "SignalBridge",
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            PopupMenuButton(

              onSelected: (value) {

                if (value == 1) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProfileEditScreen(),
                    ),
                  );
                }

              },

              itemBuilder: (context) => const [

                PopupMenuItem(
                  value: 1,
                  child: Text("User Profile"),
                ),

                PopupMenuItem(
                  value: 2,
                  child: Text("Settings"),
                ),

                PopupMenuItem(
                  value: 3,
                  child: Text("App Info"),
                ),

              ],
            )
          ],
        ),
      ),


      body: pages[currentIndex],

      bottomNavigationBar: BottomNavigationBar(

        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },

        selectedItemColor: const Color(0xFF3B82F6),

        items: const [

          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.call),
            label: "Call History",
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),

        ],
      ),
    );
  }
}



