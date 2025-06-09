import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For Clipboard
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final passwordsCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('passwords');

    final passwordQuery =
        passwordsCollection.orderBy('createdAt', descending: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: passwordQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("Please add a password"));
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final data = docs[index];
              return Padding(
                padding: const EdgeInsets.all(15),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 40, 40, 40),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              data['websiteName'][0].toUpperCase() +
                                  data['websiteName'].substring(1),
                              style: const TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w900,
                                fontSize: 19,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () =>
                                passwordsCollection.doc(data.id).delete(),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                          height: 0.7,
                          width: double.infinity,
                          color: Colors.white),
                      const SizedBox(height: 10),

                      // Username row with icon snugged
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Username",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final text = data['usernameOrEmail'];
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Username copied!')),
                              );
                            },
                            child: const Icon(Icons.copy, color: Colors.white),
                          ),
                        ],
                      ),

                      // Username Container
                      Padding(
                        padding: const EdgeInsets.only(top: 10, bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text('${data['usernameOrEmail']}'),
                        ),
                      ),

                      // Password row with icon snugged
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Password",
                            style: TextStyle(
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              final text = data['password'];
                              Clipboard.setData(ClipboardData(text: text));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Password copied!')),
                              );
                            },
                            child: const Icon(Icons.copy, color: Colors.white),
                          ),
                        ],
                      ),

                      // Password Container
                      Padding(
                        padding: const EdgeInsets.all(top: 10, bottom: 10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Text('${data['password']}'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const AddPasswordDialog(),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddPasswordDialog extends StatefulWidget {
  const AddPasswordDialog({super.key});

  @override
  State<AddPasswordDialog> createState() => _AddPasswordDialogState();
}

class _AddPasswordDialogState extends State<AddPasswordDialog> {
  final websiteNameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> savePassword() async {
    if (websiteNameController.text.trim().isEmpty) {
      showSnackBar("Website name can't be empty");
    } else if (usernameController.text.trim().isEmpty) {
      showSnackBar("User ID can't be empty");
    } else if (passwordController.text.trim().isEmpty) {
      showSnackBar("Password can't be empty");
    } else {
      final user = FirebaseAuth.instance.currentUser!;
      final ref = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('passwords');

      await ref.add({
        'websiteName': websiteNameController.text.trim(),
        'usernameOrEmail': usernameController.text.trim(),
        'password': passwordController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        "Add Password",
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21),
      ),
      backgroundColor: const Color.fromARGB(255, 40, 40, 40),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: websiteNameController,
              cursorColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Website Name'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: usernameController,
              cursorColor: Colors.white,
              decoration:
                  const InputDecoration(labelText: 'Username or Email'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              cursorColor: Colors.white,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        ElevatedButton(
          onPressed: () => Navigator.pop(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 40, 40, 40),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: savePassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Save"),
        ),
      ],
    );
  }
}