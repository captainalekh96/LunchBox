import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:geodesy/geodesy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lunchbox/Screens/Customer_Login.dart';
import 'package:lunchbox/Screens/Customer_signinupScreen.dart';
import 'package:lunchbox/Screens/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import 'Hotel_details_Screen.dart';

class CustHomeScreen extends StatefulWidget {
  @override
  _CustHomeScreenState createState() => _CustHomeScreenState();
}

class _CustHomeScreenState extends State<CustHomeScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _searchController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  String _searchText = '';
  LatLng currentLocation = LatLng(18.519995, 73.874158);

  double _distanceBetween(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371.0; // In kilometers
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLon = _degreesToRadians(lon2 - lon1);
    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            pow(sin(dLon / 2), 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }

  void setcurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final newLocate = LatLng(position.latitude, position.longitude);
    print(newLocate);
    // update sourceLocation with the new location
    currentLocation = newLocate;
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    setcurrentLocation();

    _searchController.addListener(() {
      setState(() {
        _searchText = _searchController.text;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hotels'),
        backgroundColor: Colors.orange,
        centerTitle: true,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await auth.signOut();
              var sharedPref = await SharedPreferences.getInstance();
              sharedPref.setBool(SplashScreenState.keyLogin, false);
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => CustomerLoginScreen()));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white.withOpacity(0.1),
            ),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search for Messes...',
                hintStyle: TextStyle(
                  color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.6),
                ),
                prefixIcon: Icon(Icons.search,
                    color: Color.fromARGB(255, 0, 0, 0).withOpacity(0.6)),
                suffixIcon: Icon(Icons.search,
                    color: Color.fromARGB(
                        255, 130, 129, 129)), // add a grey search icon
                filled: true, // make the search bar filled with grey color
                fillColor: Colors.grey.withOpacity(0.1), // set the fill color
                contentPadding: EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16), // set the content padding
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ), // remove the border when the search bar is focused
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(16),
                ), // remove the border when the search bar is not focused
              ),
              style: TextStyle(
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.collection('Hotels').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Something went wrong'),
                  );
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<QueryDocumentSnapshot> hotels = snapshot.data!.docs;
                const double radius = 2.0; // In kilometers
                List<QueryDocumentSnapshot> nearbyHotels =
                    hotels.where((hotel) {
                  GeoPoint hotelLocation = hotel.get('currentHotel');
                  double distance = _distanceBetween(
                    currentLocation.latitude,
                    currentLocation.longitude,
                    hotelLocation.latitude,
                    hotelLocation.longitude,
                  );
                  return distance <= radius;
                }).toList();

                // Filter hotels based on search text
                if (_searchText.isNotEmpty) {
                  nearbyHotels = nearbyHotels
                      .where((hotel) => hotel['resturantName']
                          .toString()
                          .toLowerCase()
                          .contains(_searchText.toLowerCase()))
                      .toList();
                }
                if (nearbyHotels.isEmpty) {
                  return Text(
                      "No Registered Mess in 2km around you.Kindly suggest the Messes to register on the app if you know any");
                }
                return ListView.builder(
                  itemCount: nearbyHotels.length,
                  itemBuilder: (context, index) {
                    QueryDocumentSnapshot hotel = nearbyHotels[index];
                    String hotelId = hotel.id; // use document ID as hotel ID
                    Map<String, dynamic> data =
                        hotel.data() as Map<String, dynamic>;

                    String imageUrl = data['imageUrl'] ?? '';
                    String restaurantName = data['resturantName'] ?? '';
                    String location = data['Location'] ?? '';
                    // String email = data['email'] ?? '';

                    print('Restaurant Name: $restaurantName');
                    print('Location: $location');

                    return Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundImage: NetworkImage(imageUrl),
                          ),
                          title: Text(
                            restaurantName,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(location),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    HotelDetailsScreen(hotelId: hotel.id),
                              ),
                            );
                          },
                        ),
                        Divider(
                          thickness: 1,
                          color: Colors.grey.withOpacity(0.5),
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
    );
  }
}
