import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return ListView(

      children: const [

        ListTile(
          leading: Icon(Icons.call_received, color: Colors.green),
          title: Text("Rahul"),
          subtitle: Text("Today 10:30 AM"),
        ),

        ListTile(
          leading: Icon(Icons.call_made, color: Colors.blue),
          title: Text("Ajay"),
          subtitle: Text("Yesterday 9:00 PM"),
        ),

        ListTile(
          leading: Icon(Icons.call_missed, color: Colors.red),
          title: Text("Kiran"),
          subtitle: Text("Missed call"),
        ),

      ],
    );
  }
}