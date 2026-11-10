import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
class StudentFormPage extends StatefulWidget {
final String? documentId;
final Map<String, dynamic>? initialData;
const StudentFormPage({super.key, this.documentId, this.initialData});
@override
State<StudentFormPage> createState() => _StudentFormPageState();



}
class _StudentFormPageState extends State<StudentFormPage> {
final _key = GlobalKey<FormState>();
late final TextEditingController _number;
late final TextEditingController _name;
late final TextEditingController _course;
late final TextEditingController _year;
late final TextEditingController _email;
bool _saving = false;
@override
void initState() {
super.initState();
final d = widget.initialData ?? {};
_number = TextEditingController(text: d['studentNumber'] ?? '');
_name = TextEditingController(text: d['fullName'] ?? '');
_course = TextEditingController(text: d['course'] ?? '');
_year = TextEditingController(text: d['yearLevel'] ?? '');
_email = TextEditingController(text: d['email'] ?? '');
}
@override
void dispose() {
for (final c in [_number, _name, _course, _year, _email]) { c.dispose(); }
super.dispose();
}
Future<void> _save() async {
if (!_key.currentState!.validate()) return;
setState(() => _saving = true);
final uid = FirebaseAuth.instance.currentUser!.uid;
final collection = FirebaseFirestore.instance.collection('users').doc(uid).collection('students');
final data = <String, dynamic>{
'studentNumber': _number.text.trim(),
'fullName': _name.text.trim(),
'course': _course.text.trim(),
'yearLevel': _year.text.trim(),
'email': _email.text.trim(),
'updatedAt': FieldValue.serverTimestamp(),
};
try {
if (widget.documentId == null) {
await collection.add({...data, 'createdAt': FieldValue.serverTimestamp()});
} else {
await collection.doc(widget.documentId).update(data);
}
if (mounted) Navigator.pop(context);
} catch (e) {
if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
} finally {
if (mounted) setState(() => _saving = false);
}
}
Widget _field(TextEditingController controller, String label, {bool email = false}) {
return Padding(
padding: const EdgeInsets.only(bottom: 12),
child: TextFormField(
controller: controller,
keyboardType: email ? TextInputType.emailAddress : TextInputType.text,
decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
validator: (v) {
if (v == null || v.trim().isEmpty) return '$label is required';
if (email && !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
return null;
},
),
);
}
@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(title: Text(widget.documentId == null ? 'Add Student' : 'Edit Student')),
body: SingleChildScrollView(
padding: const EdgeInsets.all(20),
child: Form(
key: _key,
child: Column(children: [


_field(_number, 'Student Number'),
_field(_name, 'Full Name'),
_field(_course, 'Course'),
_field(_year, 'Year Level'),
_field(_email, 'Email', email: true),
FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving...' : 'Save Student')),
]),
),
),
);
}
}