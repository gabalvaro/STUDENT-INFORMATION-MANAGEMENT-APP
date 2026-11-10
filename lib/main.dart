import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';


import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'pages/dashboard_page.dart';
import 'pages/login_page.dart';
Future<void> main() async {
WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
runApp(const StudentInformationApp());
}
class StudentInformationApp extends StatelessWidget {
const StudentInformationApp({super.key});
@override
Widget build(BuildContext context) {
return MaterialApp(
title: 'Student Information App',
debugShowCheckedModeBanner: false,
theme: ThemeData(colorSchemeSeed: Colors.indigo, useMaterial3: true),
home: StreamBuilder<User?>(
stream: FirebaseAuth.instance.authStateChanges(),
builder: (context, snapshot) {
if (snapshot.connectionState == ConnectionState.waiting) {
return const Scaffold(body: Center(child: CircularProgressIndicator()));
}
return snapshot.hasData ? const DashboardPage() : const LoginPage();
},
),
);
}
}