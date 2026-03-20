import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Service/id_service.dart';
import '../Service/profile_service.dart';


class ProfileViewScreen extends StatefulWidget {
  const ProfileViewScreen({super.key});

  @override
  State<ProfileViewScreen> createState() => _ProfileViewScreenState();
}

class _ProfileViewScreenState extends State<ProfileViewScreen> {

  String userName = "";
  String userId = "";
  String? imagePath;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  void loadProfile() async {

    String name = await ProfileService.getName();
    String id = await IdService.getOrCreateUserId();
    String? image = await ProfileService.getImage();

    setState(() {
      userName = name;
      userId = id;
      imagePath = image;
    });
  }

  void copyId() {
    Clipboard.setData(ClipboardData(text: userId));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ID Copied")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          CircleAvatar(
            radius: 60,
            backgroundImage:
            imagePath != null ? FileImage(File(imagePath!)) : null,
            child: imagePath == null
                ? const Icon(Icons.person, size: 60)
                : null,
          ),

          const SizedBox(height: 20),

          Text(
            userName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Text(
                userId,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(width: 5),

              IconButton(
                icon: const Icon(Icons.copy, size: 20),
                onPressed: copyId,
              ),

            ],
          ),

        ],
      ),
    );
  }
}