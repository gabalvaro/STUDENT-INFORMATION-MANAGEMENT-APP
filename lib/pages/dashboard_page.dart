import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'account_settings_page.dart';
import 'students_page.dart';
class DashboardPage extends StatelessWidget {
const DashboardPage({super.key});
@override
Widget build(BuildContext context) {
final user = FirebaseAuth.instance.currentUser!;
final students = FirebaseFirestore.instance.collection('users').doc(user.uid).collection('students');
return Scaffold(
appBar: AppBar(title: const Text('Dashboard')),
body: Padding(
padding: const EdgeInsets.all(20),
child: Column(
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
Text('Welcome, ${user.email ?? 'User'}!', style: Theme.of(context).textTheme.titleLarge),
const SizedBox(height: 20),
StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
stream: students.snapshots(),
builder: (context, snapshot) {
if (snapshot.hasError) return const Text('Unable to load student count.');
if (!snapshot.hasData) return const LinearProgressIndicator();
return Card(child: Padding(
padding: const EdgeInsets.all(20),
child: Text('Total Students: ${snapshot.data!.docs.length}', style: const TextStyle(fontSize: 22)),
));
},
),
const SizedBox(height: 20),
FilledButton.icon(
onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const StudentsPage())),
icon: const Icon(Icons.people), label: const Text('Manage Students'),
),
const SizedBox(height: 12),
OutlinedButton.icon(
onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountSettingsPage())),
icon: const Icon(Icons.settings), label: const Text('Account Settings'),
),
],
),
),
);
}
}