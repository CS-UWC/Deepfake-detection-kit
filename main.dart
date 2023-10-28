import 'package:deepfake_detection_kit/presentation/screens/homepage.dart';
import 'package:flutter/material.dart';

// import 'presentation/screens/forgotpassword.dart';
// import 'presentation/screens/signinpage.dart';
// import 'presentation/screens/loginpage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Deepfake detection kit',
      theme: ThemeData(
      
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '',),
    );
  }
}


