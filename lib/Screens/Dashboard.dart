import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Service/pure_p2p_service.dart';
import '../Service/id_service.dart';
import 'dart:convert';
import '../database/db_helper.dart';
import '../models/contact_model.dart';
import 'incoming_call_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ContactModel> contacts = [];
  String userId = "";

  @override
  void initState() {
    super.initState();
    loadContacts();
    loadUserId();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    PureP2PService.instance.setContext(context);
  }

  void loadContacts() async {
    contacts = await DBHelper().getContacts();
    setState(() {});
  }

  void loadUserId() async {
    String id = await IdService.getOrCreateUserId();
    setState(() {
      userId = id;
    });
  }

  /// ADD / EDIT CONTACT POPUP
  void openContactPopup({ContactModel? contact}) {
    TextEditingController nameController = TextEditingController();
    TextEditingController idController = TextEditingController();

    if (contact != null) {
      nameController.text = contact.name;
      idController.text = contact.uniqueId;
    }

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text(contact == null ? "Save Contact" : "Edit Contact"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: idController,
                decoration: const InputDecoration(labelText: "Unique ID"),
              ),
            ],
          ),

          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),

            ElevatedButton(
              child: const Text("Save"),
              onPressed: () async {
                if (contact == null) {
                  await DBHelper().insert(
                    ContactModel(
                      name: nameController.text,
                      uniqueId: idController.text,
                    ),
                  );
                } else {
                  contact.name = nameController.text;
                  contact.uniqueId = idController.text;

                  await DBHelper().update(contact);
                }

                Navigator.pop(context);
                loadContacts();
              },
            ),
          ],
        );
      },
    );
  }

  /// DELETE CONTACT
  void deleteContact(int id) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Delete Contact"),
          content: const Text("Are you sure you want to delete this contact?"),

          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () => Navigator.pop(context),
            ),

            ElevatedButton(
              child: const Text("Delete"),
              onPressed: () async {
                await DBHelper().delete(id);

                Navigator.pop(context);
                loadContacts();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CONTACT LIST
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF3B82F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Your ID",
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      userId,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.copy, color: Color(0xFF3B82F6)),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: userId));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("ID Copied to Clipboard")),
                    );
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child:
                contacts.isEmpty
                    ? const Center(
                      child: Text(
                        "No contacts yet",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];

                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.person),
                          ),

                          title: Text(contact.name),

                          subtitle: Text(contact.uniqueId),

                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.call,
                                  color: Colors.green,
                                ),
                                onPressed: () async {
                                  String targetId = contact.uniqueId.trim();
                                  if (targetId.isEmpty) return;

                                  try {
                                    final offerData = await PureP2PService
                                        .instance
                                        .callUser(targetId);

                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: const Text(
                                                "Share Call Offer",
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    "Send this code to the contact:",
                                                  ),
                                                  const SizedBox(height: 10),
                                                  SelectableText(
                                                    jsonEncode(offerData),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text: jsonEncode(
                                                          offerData,
                                                        ),
                                                      ),
                                                    );
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Copied to clipboard",
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Copy"),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text("Close"),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  }
                                },
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.videocam,
                                  color: Colors.blue,
                                ),
                                onPressed: () async {
                                  String targetId = contact.uniqueId.trim();
                                  if (targetId.isEmpty) return;

                                  try {
                                    final offerData = await PureP2PService
                                        .instance
                                        .callUser(targetId, isVideo: true);

                                    if (context.mounted) {
                                      showDialog(
                                        context: context,
                                        builder:
                                            (_) => AlertDialog(
                                              title: const Text(
                                                "Share Video Call Offer",
                                              ),
                                              content: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Text(
                                                    "Send this code to the contact:",
                                                  ),
                                                  const SizedBox(height: 10),
                                                  SelectableText(
                                                    jsonEncode(offerData),
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Clipboard.setData(
                                                      ClipboardData(
                                                        text: jsonEncode(
                                                          offerData,
                                                        ),
                                                      ),
                                                    );
                                                    Navigator.pop(context);
                                                    ScaffoldMessenger.of(
                                                      context,
                                                    ).showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                          "Copied to clipboard",
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  child: const Text("Copy"),
                                                ),
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text("Close"),
                                                ),
                                              ],
                                            ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  }
                                },
                              ),

                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed:
                                    () => openContactPopup(contact: contact),
                              ),

                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () => deleteContact(contact.id!),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),

      // FLOATING BUTTON
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF3B82F6),
        onPressed: () => openContactPopup(),
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
