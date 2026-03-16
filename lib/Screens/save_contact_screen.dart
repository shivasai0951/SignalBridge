import 'package:flutter/material.dart';
import '../Utility/appColors.dart';

class SaveContactScreen extends StatelessWidget {
  const SaveContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Save Contact"),
        backgroundColor: AppColors.appBar,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            TextField(
              decoration: InputDecoration(
                hintText: "Name",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: "Unique ID",
                filled: true,
                fillColor: Colors.white10,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryButton,
              ),
              onPressed: () {},
              child: const Text("Save Contact"),
            )

          ],
        ),
      ),
    );
  }
}