import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'Home_Screen.dart';
import 'update_menu.dart';

class ViewBookings extends StatefulWidget {
  final String hotelOwnerId;
  ViewBookings(this.hotelOwnerId);

  @override
  _ViewBookingsState createState() => _ViewBookingsState();
}

class _ViewBookingsState extends State<ViewBookings> {
  TextEditingController _searchController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (_searchController.text.isEmpty) {
        setState(() {
          _searchText = '';
        });
      } else {
        setState(() {
          _searchText = _searchController.text.toLowerCase();
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Today\'s Bookings'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: _firestore
                    .collection('Hotels')
                    .doc(widget.hotelOwnerId)
                    .collection('Menu')
                    .doc('menu')
                    .collection('Bookings')
                    // .orderBy('BookingTime', descending: true)
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  print(widget.hotelOwnerId);
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  List<QueryDocumentSnapshot> bookings = snapshot.data!.docs;

                  // Filter hotels based on search text
                  if (_searchText.isNotEmpty) {
                    bookings = bookings
                        .where((booking) => booking['username']
                            .toString()
                            .toLowerCase()
                            .contains(_searchText.toLowerCase()))
                        .toList();
                  }

                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      QueryDocumentSnapshot booking = bookings[index];
                      // String hotelId = hotel.id; // use document ID as hotel ID
                      Map<String, dynamic> data =
                          booking.data() as Map<String, dynamic>;

                      String Username = data['username'] ?? '';

                      DateTime BookingTimeinDT =
                          (data['BookingTime'] as Timestamp).toDate();
                      String BookingTime = DateFormat('MMM dd, yyyy hh:mm a')
                          .format(BookingTimeinDT);

                      return Column(
                        children: [
                          ListTile(
                            leading: CircleAvatar(
                              child: Icon(Icons.person),
                            ),
                            title: Text(
                              Username,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(BookingTime),
                          ),
                          Divider(
                            thickness: 1,
                            color:
                                Color.fromARGB(255, 0, 0, 0).withOpacity(0.5),
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit),
              label: 'Update Menu',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
          selectedItemColor: Colors.blue,
          onTap: (value) {
            switch (value) {
              case 0:
                // Navigate to HomeScreen()
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
                break;
              case 1:
                // Navigate to UpdateMenu()
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UpdateMenu()),
                );

                // Navigate to Profile screen

                break;
            }
          },
        ));
  }
}
