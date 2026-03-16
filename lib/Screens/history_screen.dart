import 'package:flutter/material.dart';

import '../Utility/appColors.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Call History"),
        backgroundColor: AppColors.appBar,
      ),

      body: ListView(
        children: const [

          ListTile(
            leading: Icon(Icons.call_received, color: Colors.green),
            title: Text("Rahul"),
            subtitle: Text("Today 10:45 AM"),
          ),

          ListTile(
            leading: Icon(Icons.call_made, color: Colors.blue),
            title: Text("Ajay"),
            subtitle: Text("Yesterday 8:20 PM"),
          ),

        ],
      ),
    );
  }
}