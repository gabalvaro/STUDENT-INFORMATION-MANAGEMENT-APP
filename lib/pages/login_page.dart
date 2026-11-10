import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class LoginPage extends StatefulWidget {
const LoginPage({super.key});
@override
State<LoginPage> createState() => _LoginPageState();
}
class _LoginPageState extends State<LoginPage> {
final _formKey = GlobalKey<FormState>();
final _email = TextEditingController();
final _password = TextEditingController();
bool _loading = false;



@override
void dispose() {
_email.dispose();
_password.dispose();
super.dispose();
}
Future<void> _login() async {
if (!_formKey.currentState!.validate()) return;
setState(() => _loading = true);
try {
await FirebaseAuth.instance.signInWithEmailAndPassword(
email: _email.text.trim(), password: _password.text,
);
// The auth listener in main.dart automatically opens the dashboard.
} on FirebaseAuthException catch (e) {
if (!mounted) return;
ScaffoldMessenger.of(context).showSnackBar(
SnackBar(content: Text(e.message ?? 'Unable to log in.')),
);
} finally {
if (mounted) setState(() => _loading = false);
}
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: const Text('Student Information App')),
body: Center(
child: ConstrainedBox(
constraints: const BoxConstraints(maxWidth: 420),
child: Padding(
padding: const EdgeInsets.all(24),
child: Form(
key: _formKey,
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
const Icon(Icons.school, size: 70),
const SizedBox(height: 16),
const Text('Login', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
const SizedBox(height: 24),
TextFormField(
controller: _email,

keyboardType: TextInputType.emailAddress,
decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
validator: (v) => v == null || !v.contains('@') ? 'Enter a valid email' : null,

),
const SizedBox(height: 12),
TextFormField(
controller: _password,
obscureText: true,
decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
validator: (v) => v == null || v.isEmpty ? 'Enter your password' : null,

),
const SizedBox(height: 20),
FilledButton(
onPressed: _loading ? null : _login,

child: _loading ? const CircularProgressIndicator() : const Text('Login'),

),
],
),
),
),
),
),
);
}
}