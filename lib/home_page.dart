import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({super.key});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  final tugas = TextEditingController();
  final auth = FirebaseAuth.instance;
  final firestore = FirebaseFirestore.instance;

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.logout, size: 60, ),
                SizedBox(height: 20),
                Text(
                  'Konfirmasi Logout',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Anda akan keluar dari akun ${FirebaseAuth.instance.currentUser?.email}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Batal'),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: () async {
                          Navigator.of(context).pop();
                          await FirebaseAuth.instance.signOut();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => LoginPage()),
                          );
                        },
                        child: Text(
                          'Keluar',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _tambahtugas() {
    final user = auth.currentUser;
    if (user != null && tugas.text.isNotEmpty) {
      firestore.collection('user').doc(user.uid).collection('todo').add({
        'tugas': tugas.text,
        'createAt': Timestamp.now(),
        'isDone': false,
      });
      tugas.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = auth.currentUser!;
    return Scaffold(
      appBar: AppBar(
        title: Text('Menu To-do List'),
      
       
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestore
                  .collection('user')
                  .doc(user.uid)
                  .collection('todo')
                  .orderBy('createAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData) {
                  return Center(child: Text('Data Kosong'));
                }

                final docs = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index];
                    final bool isDone = data['isDone'] ?? false;

                    return Card(
                      child: ListTile(
                        leading: Checkbox(
                          value: isDone,
                          onChanged: (value) {
                            data.reference.update({'isDone': value});
                          },
                        ),
                        title: Text(
                          data['tugas'],
                          style: TextStyle(
                            decoration: isDone
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                            color: isDone ? Colors.grey : Colors.black,
                          ),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => data.reference.delete(),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: EdgeInsets.all(25),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: tugas,
                    decoration: InputDecoration(
                      labelText: 'Masukan Tugas Baru',
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _tambahtugas,
                  icon: Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
