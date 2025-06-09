import 'package:flutter/material.dart';
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

    final passwordQuery = passwordsCollection.orderBy('createdAt', descending: true);

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: passwordQuery.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting){
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
                padding: const EdgeInsets.all(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 40, 40, 40),
                    borderRadius: BorderRadius.circular(10)
                  ),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              data['websiteName'][0].toUpperCase() + data['websiteName'].substring(1), 
                              style: TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w900, fontSize: 19)
                            ),
                          ),
                          GestureDetector(
                            child: Icon(Icons.delete)
                          )
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        height: .7, width: double.infinity,
                        color: Colors.white,
                      ),
                      SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              "User Name", 
                              style: TextStyle(overflow: TextOverflow.ellipsis, fontWeight: FontWeight.w900, fontSize: 19)
                            ),
                          ),
                          GestureDetector(
                            child: Icon(Icons.copy)
                          )
                        ],
                      ),
                    ],
                  ),
                  // title: Text(data['websiteName'] ?? ''),
                  // subtitle: Text('${data['usernameOrEmail']}'),
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.delete),
                  //   onPressed: () => passwordsCollection.doc(data.id).delete(),
                  // ),
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
    if(websiteNameController.text.trim().isEmpty){
      showSnackBar("Website name can't be empty");
    }
    else if(usernameController.text.trim().isEmpty){
      showSnackBar("User ID can't be empty");
    }
    else if(passwordController.text.trim().isEmpty){
      showSnackBar("Passsword can't be empty");
    }
    else{
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
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Password", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 21)),
      backgroundColor: Color.fromARGB(255, 40, 40, 40),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(controller: websiteNameController, cursorColor: Colors.white, decoration: InputDecoration(labelText: 'Website Name')),
            SizedBox(height: 10),
            TextField(controller: usernameController, cursorColor: Colors.white, decoration: InputDecoration(labelText: 'Username or Email')),
            SizedBox(height: 10),
            TextField(controller: passwordController, cursorColor: Colors.white, decoration: InputDecoration(labelText: 'Password')),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        SizedBox(
          child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: Color.fromARGB(255, 40, 40, 40), foregroundColor: Colors.white, shape: RoundedRectangleBorder(side: BorderSide(color: Colors.white, width: 1), borderRadius: BorderRadius.circular(10))), child: const Text("Cancel"))
        ),
        SizedBox(

          child: ElevatedButton(onPressed: savePassword, style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))), child: const Text("Save"))
        ),
      ],
    );
  }
}
