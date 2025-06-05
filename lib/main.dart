import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:localquest/Admin/Adminpage.dart';
import 'package:localquest/Homepage.dart';
import 'package:localquest/Module_User_Account/Login.dart';
import 'firebase_options.dart';


void main() {
  Database();
  runApp(const MyApp());
}

Future<void> Database() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DFirebaseOptions.currentPlatform,
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: ListView(children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,  // or any specific height
            child: Login(),
            //child: Homepage(),
          ),
        ]),
      ),
    );
  }
}