import 'package:flutter/material.dart';

import '../Utility/appColors.dart';


class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("SignalBridge"),
        backgroundColor: AppColors.appBar,
      ),

      body: ListView(
        children: const [

          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Rahul"),
            subtitle: Text("ID: 123456"),
            trailing: Icon(Icons.call, color: Colors.green),
          ),

          ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text("Ajay"),
            subtitle: Text("ID: 654321"),
            trailing: Icon(Icons.call, color: Colors.green),
          ),

        ],
      ),
    );
  }
}