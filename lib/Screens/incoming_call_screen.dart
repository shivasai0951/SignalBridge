import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../Service/pure_p2p_service.dart';

class IncomingCallScreen extends StatelessWidget {
  final String callerId;

  const IncomingCallScreen({super.key, required this.callerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),

            const SizedBox(height: 30),

            const Text(
              "Incoming Call",
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),

            const SizedBox(height: 10),

            Text(
              callerId,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 80),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: "reject",
                      backgroundColor: Colors.red,
                      onPressed: () async {
                        await PureP2PService.instance.rejectCall();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Icon(
                        Icons.call_end,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Reject",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),

                Column(
                  children: [
                    FloatingActionButton(
                      heroTag: "accept",
                      backgroundColor: Colors.green,
                      onPressed: () async {
                        try {
                          final answerData =
                              await PureP2PService.instance.acceptCall();

                          if (context.mounted) {
                            showDialog(
                              context: context,
                              builder:
                                  (_) => AlertDialog(
                                    title: const Text("Share Answer"),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          "Send this answer code back to caller:",
                                        ),
                                        const SizedBox(height: 10),
                                        SelectableText(
                                          jsonEncode(answerData),
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Clipboard.setData(
                                            ClipboardData(
                                              text: jsonEncode(answerData),
                                            ),
                                          );
                                          Navigator.pop(context);
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                              builder:
                                                  (_) => ActiveCallScreen(
                                                    callerId: callerId,
                                                    isIncoming: true,
                                                  ),
                                            ),
                                          );
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                "Answer copied! Send to caller",
                                              ),
                                            ),
                                          );
                                        },
                                        child: const Text("Copy & Continue"),
                                      ),
                                    ],
                                  ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e")),
                            );
                          }
                        }
                      },
                      child: const Icon(
                        Icons.call,
                        color: Colors.white,
                        size: 35,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Accept",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ActiveCallScreen extends StatelessWidget {
  final String callerId;
  final bool isIncoming;

  const ActiveCallScreen({
    super.key,
    required this.callerId,
    this.isIncoming = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E293B),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 80, color: Colors.white),
            ),

            const SizedBox(height: 30),

            Text(
              callerId,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              "Call Connected",
              style: TextStyle(color: Colors.green, fontSize: 18),
            ),

            const SizedBox(height: 80),

            FloatingActionButton(
              backgroundColor: Colors.red,
              onPressed: () async {
                await PureP2PService.instance.endCall();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Icon(Icons.call_end, color: Colors.white, size: 35),
            ),

            const SizedBox(height: 10),

            const Text("End Call", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
