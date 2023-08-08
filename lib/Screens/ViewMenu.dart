import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  late final User _user;
  late final CollectionReference _menuRef;

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser!;
    _menuRef = FirebaseFirestore.instance
        .collection('Hotels')
        .doc(_user.uid)
        .collection('Menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu'),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: _menuRef.snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final List<QueryDocumentSnapshot> docs = snapshot.data!.docs;
            if (docs.isEmpty) {
              return const Center(child: Text('No menu found.'));
            }

            return ListView.builder(
              itemCount: docs.length,
              itemBuilder: (BuildContext context, int index) {
                final dish = docs[index];
                final startTime = (dish['Time Start'] as Timestamp).toDate();
                final endTime = (dish['Time End'] as Timestamp).toDate();

                return Card(
                  margin: const EdgeInsets.all(8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dish['DishName'],
                          style: Theme.of(context).textTheme.headline6,
                        ),
                        const SizedBox(height: 8),
                        Text(dish['Details']),
                        const SizedBox(height: 8),
                        Text('Price: ${dish['Price']}'),
                        const SizedBox(height: 8),
                        Text(
                            'Available between ${startTime.hour}:${startTime.minute} and ${endTime.hour}:${endTime.minute}'),
                        const SizedBox(height: 8),
                        Image.network(dish['DishImage']),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
    );
  }
}
