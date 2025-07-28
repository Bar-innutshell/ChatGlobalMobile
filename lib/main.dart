import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth_wrapper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    print('Memuat .env...');
    await dotenv.load();
    print('ENV loaded: ' + dotenv.env.toString());
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized');
    runApp(const MainApp());
  } catch (e, stack) {
    print('Startup error: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                const Text('Terjadi error saat startup', style: TextStyle(fontSize: 18)),
                const SizedBox(height: 8),
                Text(e.toString(), style: const TextStyle(color: Colors.red)),
                const SizedBox(height: 8),
                Text(stack.toString(), maxLines: 10, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ),
      ),
    ));
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const AuthWrapper(),
    );
  }
}
