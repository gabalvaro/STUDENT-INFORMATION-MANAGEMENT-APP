
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'student_form_page.dart';

class StudentsPage extends StatelessWidget {
  const StudentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final collection = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('students');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Records'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => const StudentFormPage(),
          ),
        ),
        icon: const Icon(Icons.add),
        label: const Text('Add Student'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: collection.orderBy('fullName').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Unable to load students.'),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No student records yet. Tap Add Student.',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();

              return Card(
                child: ListTile(
                  title: Text('${data['fullName'] ?? ''}'),
                  subtitle: Text(
                    '${data['studentNumber'] ?? ''} • '
                    '${data['course'] ?? ''} • '
                    '${data['yearLevel'] ?? ''}\n'
                    '${data['email'] ?? ''}',
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (action) async {
                      if (action == 'edit') {
                        if (!context.mounted) return;

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentFormPage(
                              documentId: doc.id,
                              initialData: data,
                            ),
                          ),
                        );
                      } else if (action == 'delete') {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) => AlertDialog(
                            title: const Text('Delete student?'),
                            content: Text(
                              'Delete ${data['fullName']}? '
                              'This cannot be undone.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(
                                  dialogContext,
                                  false,
                                ),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(
                                  dialogContext,
                                  true,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          try {
                            await collection.doc(doc.id).delete();
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text('Delete failed: $e'),
                                ),
                              );
                            }
                          }
                        }
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
