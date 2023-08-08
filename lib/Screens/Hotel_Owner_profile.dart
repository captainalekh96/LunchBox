import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'Home_Screen.dart';
import 'update_menu.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final TextEditingController _ownerNameController = TextEditingController();
  final TextEditingController _restaurantNameController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _geopointController = TextEditingController();
  final TextEditingController _contactNumber = TextEditingController();
  int _selectedIndex = 2;

  late Stream<DocumentSnapshot> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = FirebaseFirestore.instance
        .collection('Hotels')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  Future<void> _updateProfile() async {
    LocationPermission permission;
    do {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        // Show dialog box
        await showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: Text('Location Permission Required'),
            content: Text(
              'Please grant location permission to use this feature.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('CANCEL'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('OKAY'),
              ),
            ],
          ),
        );
      }
    } while (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse);

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    GeoPoint userLocation = const GeoPoint(18.519995, 73.874158);
    userLocation = GeoPoint(position.latitude, position.longitude);
    FirebaseFirestore.instance
        .collection('Hotels')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'ownerName': _ownerNameController.text,
      'resturantName': _restaurantNameController.text,
      'Location': _addressController.text,
      'currentHotel': userLocation,
      'phoneNumber': _contactNumber.text,
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated successfully.'),
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: _profileStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data!;
            _ownerNameController.text = data['ownerName'] ?? '';
            _restaurantNameController.text = data['resturantName'] ?? '';
            _addressController.text = data['Location'] ?? '';
            _geopointController.text =
                '${data['currentHotel'].latitude},${data['currentHotel'].longitude}';
            _contactNumber.text = data['phoneNumber'];

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 32),
                    CircleAvatar(
                      radius: 80,
                      child: ClipOval(
                        child: Image.network(
                          data['imageUrl'],
                          fit: BoxFit.cover,
                          width: 160,
                          height: 160,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Owner Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _ownerNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter owner name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Restaurant Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _restaurantNameController,
                      decoration: InputDecoration(
                        hintText: 'Enter restaurant name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Address',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        hintText: 'Enter address',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Contact Number',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    TextFormField(
                      controller: _contactNumber,
                      decoration: InputDecoration(
                        hintText: 'Contact Number',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _updateProfile,
                      icon: Icon(Icons.edit),
                      label: Text('Update Profile'),
                    ),
                  ],
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
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
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: (value) {
          setState(() {
            _selectedIndex = value;
          });

          switch (value) {
            case 0:
              // Navigate to HomeScreen()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
              break;
            case 1:
              // Navigate to UpdateMenu()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const UpdateMenu()),
              );
              break;
            case 2:
              // Navigate to UpdateMenu()
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
              break;
          }
        },
      ),
    );
  }
}
