import 'package:flutter/material.dart';

import 'Screens/Dashboard.dart';
import 'Screens/home_screen.dart';
import 'Screens/splashScreen.dart';
import 'Service/id_service.dart';
import 'Service/pure_p2p_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String userId = await IdService.getOrCreateUserId();
  await PureP2PService.instance.init(userId);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Signal Bridge',
      theme: ThemeData(primarySwatch: Colors.red),
      home: const SplashScreen(),
      routes: {
        '/dashboard': (context) {
          PureP2PService.instance.setContext(context);
          return const HomeScreen();
        },
      },
    );
  }
}
