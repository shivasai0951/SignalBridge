import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../Service/id_service.dart';
import '../Service/profile_service.dart';


class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {

  final TextEditingController nameController = TextEditingController();

  String userId = "";
  File? image;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {

    String name = await ProfileService.getName();
    String id = await IdService.getOrCreateUserId();
    String? img = await ProfileService.getImage();

    nameController.text = name;

    setState(() {
      userId = id;
      if (img != null) image = File(img);
    });
  }

  Future pickImage() async {

    final picked =
    await ImagePicker().pickImage(source: ImageSource.gallery);

    if (picked != null) {

      await ProfileService.saveImage(picked.path);

      setState(() {
        image = File(picked.path);
      });
    }
  }

  void saveName() async {

    await ProfileService.saveName(nameController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile Updated")),
    );
  }

  void copyId() {
    Clipboard.setData(ClipboardData(text: userId));

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("ID Copied")),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("User Profile"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [

            GestureDetector(
              onTap: pickImage,

              child: CircleAvatar(
                radius: 60,
                backgroundImage:
                image != null ? FileImage(image!) : null,
                child: image == null
                    ? const Icon(Icons.person, size: 60)
                    : null,
              ),
            ),

            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: "Your Name",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: saveName,
              child: const Text("Save"),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                Text(
                  userId,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                IconButton(
                  onPressed: copyId,
                  icon: const Icon(Icons.copy),
                )

              ],
            ),

            const Text(
              "Unique ID (Cannot be edited)",
              style: TextStyle(color: Colors.grey),
            ),

          ],
        ),
      ),
    );
  }
}