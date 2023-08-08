import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';

import 'package:lunchbox/Screens/LocationandTracking.dart';
//import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

import '../reusable_widgets/deletingBookings.dart';
import 'HotelDetailsScreenState.dart';
import 'Review.dart';

class HotelDetailsScreen extends StatelessWidget {
  final String hotelId;
  late GeoPoint currentHotelLocation;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  TextEditingController _commentController = TextEditingController();
  static TimeOfDay? bookingTime;
  static String bookedHotel = '';
  HotelDetailsScreen({required this.hotelId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HotelDetailsScreenState(),
      child:
          Consumer<HotelDetailsScreenState>(builder: (context, state, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Hotel Details'),
          ),
          body: StreamBuilder<DocumentSnapshot>(
            stream: _firestore.collection('Hotels').doc(hotelId).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Something went wrong'),
                );
              }

              //Deleting if the Booking has excede the time limit or the previous old Bookings
              FirebaseAuth auth = FirebaseAuth.instance;
              String userId = auth.currentUser!.uid;
              checkVaildBookingClient(userId, hotelId);
              checkVaildMenu(hotelId);
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }

              Map<String, dynamic>? data =
                  snapshot.data?.data() as Map<String, dynamic>?;

              String hotelName = data!['resturantName'];
              String hotelNamecancel = hotelName;
              String hotel_phone = "Ph: " + data['phoneNumber'];
              String hotelAddress = "Address: " + data['Location'];
              String hotelPhotoUrl = data['imageUrl'];
              currentHotelLocation = data['currentHotel'];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 200.0,
                    child: Image.network(
                      hotelPhotoUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            hotelName,
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => LocationTrackin(
                                currentHotel: currentHotelLocation,
                              ),
                            ));
                          },
                          child: Container(
                            width: 40.0,
                            height: 40.0,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue,
                            ),
                            child: Icon(
                              Icons.directions,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      hotel_phone,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Text(
                      hotelAddress,
                      style: TextStyle(fontSize: 12.0),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Divider(thickness: 1.0, color: Color.fromARGB(255, 0, 0, 0)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      'Menu of the day:',
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Expanded(
                    child: StreamBuilder<DocumentSnapshot>(
                      stream: _firestore
                          .collection('Hotels')
                          .doc(hotelId)
                          .collection('Menu')
                          .doc('menu')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Center(
                            child: Text('Something went wrong'),
                          );
                        }

                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        Map<String, dynamic>? menuData =
                            snapshot.data?.data() as Map<String, dynamic>?;
                        if (menuData == null) {
                          return Text(
                            'Menu Not available',
                            style: TextStyle(
                              fontSize: 18.0,
                              //fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                        String dishName = menuData['DishName'];
                        String dishImage = menuData['DishImage'];
                        String nameOfVegetable = menuData['NameOfVegetable'];
                        String price = menuData['Price'];

                        DateTime timeStartDt =
                            (menuData['Time Start'] as Timestamp).toDate();
                        String timeStart = DateFormat('MMM dd, yyyy hh:mm a')
                            .format(timeStartDt);

                        DateTime timeEndDt =
                            (menuData['Time End'] as Timestamp).toDate();
                        String timeEnd = DateFormat('MMM dd, yyyy hh:mm a')
                            .format(timeEndDt);

                        return SingleChildScrollView(
                            child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                dishName,
                                style: TextStyle(
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 16.0),
                              Image.network(
                                dishImage,
                                height: 250.0,
                                fit: BoxFit.cover,
                              ),
                              SizedBox(height: 16.0),
                              Text(
                                'Name of Vegetable: $nameOfVegetable',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Price: Rs $price',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Time Start: $timeStart',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Time End: $timeEnd',
                                style: TextStyle(fontSize: 15.0),
                              ),
                              //Booking Seat
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        TimeOfDay? selectedTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                          initialEntryMode:
                                              TimePickerEntryMode.input,
                                        );

                                        //Checking if the User has booked somewhere else

                                        DocumentReference docRef =
                                            FirebaseFirestore
                                                .instance
                                                .collection('Clients')
                                                .doc(FirebaseAuth
                                                    .instance.currentUser!.uid)
                                                .collection('BookedAt')
                                                .doc('clientBooking');

// Retrieve the clientBooking document
                                        DocumentSnapshot snapshot =
                                            await docRef.get();
                                        if (snapshot.exists &&
                                            snapshot.get('HotelName') !=
                                                hotelName) {
                                          bookedHotel =
                                              snapshot.get('HotelName');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            content: Text(
                                                'You have already booked at ${snapshot.get('HotelName')}'),
                                          ));
                                        } else {
                                          if (selectedTime != null) {
                                            if (timeStartDt.hour >
                                                    selectedTime.hour ||
                                                (timeStartDt.hour ==
                                                        selectedTime.hour &&
                                                    timeStartDt.minute >
                                                        selectedTime.minute) ||
                                                timeEndDt.hour <
                                                    selectedTime.hour ||
                                                (timeEndDt.hour ==
                                                        selectedTime.hour &&
                                                    timeEndDt.minute <
                                                        selectedTime.minute)) {
                                              // Display a snackbar to inform the user that the selected time is invalid
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      'Please select a valid time between $timeStart and $timeEnd'),
                                                ),
                                              );
                                            } else {
                                              final booked = DateTime(
                                                DateTime.now().year,
                                                DateTime.now().month,
                                                DateTime.now().day,
                                                selectedTime.hour,
                                                selectedTime.minute,
                                              );
                                              String username =
                                                  await FirebaseFirestore
                                                      .instance
                                                      .collection('Clients')
                                                      .doc(FirebaseAuth.instance
                                                          .currentUser!.uid)
                                                      .get()
                                                      .then((doc) =>
                                                          doc.get('Username'));
                                              print(username);
                                              final clientUser = FirebaseAuth
                                                  .instance.currentUser;
                                              final bookingRef =
                                                  FirebaseFirestore.instance
                                                      .collection('Hotels')
                                                      .doc(hotelId)
                                                      .collection('Menu')
                                                      .doc('menu')
                                                      .collection('Bookings');
                                              final bookingatclient =
                                                  FirebaseFirestore.instance
                                                      .collection('Clients')
                                                      .doc(clientUser?.uid)
                                                      .collection('BookedAt')
                                                      .doc('clientBooking');

                                              final querySnapshot =
                                                  await bookingRef
                                                      .where('username',
                                                          isEqualTo: username)
                                                      .limit(1)
                                                      .get();

                                              if (querySnapshot
                                                  .docs.isNotEmpty) {
                                                final reviewDoc =
                                                    querySnapshot.docs.first;
                                                await reviewDoc.reference
                                                    .update({
                                                  'BookingTime':
                                                      Timestamp.fromDate(
                                                          booked),
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Updated successfully.'),
                                                  ),
                                                );
                                              } else {
                                                final data = {
                                                  'username': username,
                                                  'BookingTime':
                                                      Timestamp.fromDate(
                                                          booked),
                                                };
                                                await bookingatclient.set({
                                                  'HotelName': hotelName,
                                                  'BookingTime':
                                                      Timestamp.fromDate(
                                                          booked),
                                                });
                                                await bookingRef.add(data);
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Booking successful.'),
                                                  ),
                                                );
                                              }
                                              Provider.of<HotelDetailsScreenState>(
                                                      context,
                                                      listen: false)
                                                  .setBookingTime(selectedTime);
                                              bookingTime = selectedTime;
                                              Provider.of<HotelDetailsScreenState>(
                                                      context,
                                                      listen: false)
                                                  .setBookedHotel(hotelName);
                                              bookedHotel = hotelName;
                                            }
                                          }
                                        }
                                      },
                                      icon: const Icon(Icons.lock_open),
                                      label: const Text("Book your vist Time"),
                                    ),
                                  ),
                                  const SizedBox(width: 30),
                                  Text(
                                    bookingTime != null
                                        ? bookingTime!.format(context)
                                        : '',
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    bookedHotel,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  const SizedBox(width: 100),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        TimeOfDay selectedTime =
                                            TimeOfDay.now();
                                        final clientUser =
                                            FirebaseAuth.instance.currentUser;
                                        final username = await FirebaseFirestore
                                            .instance
                                            .collection('Clients')
                                            .doc(clientUser!.uid)
                                            .get()
                                            .then((doc) => doc.get('Username'));

                                        // Get a reference to the user's booking document
                                        final bookingClientRef =
                                            FirebaseFirestore.instance
                                                .collection('Clients')
                                                .doc(clientUser.uid)
                                                .collection('BookedAt')
                                                .doc('clientBooking');

                                        // Check if the document exists
                                        final snapshot =
                                            await bookingClientRef.get();
                                        if (snapshot.exists) {
                                          // Delete the corresponding booking at the hotel
                                          final bookingQuerySnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('Hotels')
                                                  .doc(hotelId)
                                                  .collection('Menu')
                                                  .doc('menu')
                                                  .collection('Bookings')
                                                  .where('username',
                                                      isEqualTo: username)
                                                  .get();
                                          if (bookingQuerySnapshot
                                                  .docs.isNotEmpty &&
                                              snapshot.get('HotelName') ==
                                                  hotelNamecancel) {
                                            final bookingDoc =
                                                bookingQuerySnapshot.docs.first;
                                            await bookingClientRef.delete();
                                            await bookingDoc.reference.delete();
                                            Provider.of<HotelDetailsScreenState>(
                                                    context,
                                                    listen: false)
                                                .setBookingTime(selectedTime);
                                            bookingTime = null;
                                            Provider.of<HotelDetailsScreenState>(
                                                    context,
                                                    listen: false)
                                                .setBookedHotel(hotelName);
                                            bookedHotel = '';

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Booking has been cancled of ${snapshot.get('HotelName')}.'),
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'No booking for selected Mess, you have booked at ${snapshot.get('HotelName')}.'),
                                              ),
                                            );
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content:
                                                  Text('No booking found.'),
                                            ),
                                          );
                                        }
                                      },
                                      icon: Icon(Icons.delete),
                                      label: Text('Cancel Booking'),
                                    ),
                                  ),
                                  const SizedBox(width: 130),
                                ],
                              ),

                              SizedBox(height: 8.0),
                              Divider(
                                  thickness: 1.0,
                                  color: Color.fromARGB(255, 0, 0, 0)),
                              SizedBox(height: 5.0),

                              StreamBuilder<QuerySnapshot>(
                                stream: _firestore
                                    .collection('Hotels')
                                    .doc(hotelId)
                                    .collection('Reviews')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Center(
                                      child: Text('Something went wrong'),
                                    );
                                  }

                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
//double averageRating=0.0;
                                  //if (snapshot.hasData && snapshot.data != null) {
                                  QuerySnapshot reviewSnapshot = snapshot.data!;
                                  List<QueryDocumentSnapshot> reviewDocs =
                                      reviewSnapshot.docs;
                                  List<Review> reviews = reviewDocs
                                      .map((doc) => Review.fromSnapshot(doc))
                                      .toList();
                                  double averageRating = reviews.fold(
                                          0.0,
                                          (double sum, Review review) =>
                                              sum + review.rating) /
                                      reviews.length;
//}

                                  return Padding(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(height: 16.0),
                                        Text(
                                          'Reviews:',
                                          style: TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        Row(
                                          children: [
                                            Icon(Icons.star,
                                                color: Colors.yellow),
                                            SizedBox(width: 4.0),
                                            Text(
                                              '${averageRating.toStringAsFixed(1)}',
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                            SizedBox(width: 4.0),
                                            Text(
                                              '(${reviews.length} reviews)',
                                              style: TextStyle(fontSize: 18.0),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 8.0),
                                        reviews.length > 0
                                            ? Column(
                                                children: reviews
                                                    .map((review) => Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Row(children: [
                                                              Icon(
                                                                Icons.person,
                                                                size: 16.0,
                                                              ),
                                                              SizedBox(
                                                                  height: 8.0),
                                                              Text(
                                                                review.username,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      18.0,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                ),
                                                              ),
                                                            ]),
                                                            SizedBox(
                                                                height: 5.0),
                                                            Row(
                                                              children: [
                                                                SizedBox(
                                                                    width: 8.0),
                                                                Icon(
                                                                  Icons.star,
                                                                  size: 16.0,
                                                                  color: Colors
                                                                      .yellow,
                                                                ),
                                                                SizedBox(
                                                                    width: 4.0),
                                                                Text(
                                                                  '${review.rating.toStringAsFixed(1)}',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.0),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                                height: 8.0),
                                                            Text(
                                                              review.comment,
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      16.0),
                                                            ),
                                                            Divider(
                                                                thickness: 1.0,
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        0,
                                                                        0,
                                                                        0)),
                                                          ],
                                                        ))
                                                    .toList(),
                                              )
                                            : Text(
                                                'No reviews yet',
                                                style:
                                                    TextStyle(fontSize: 16.0),
                                              ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Add a Review',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8.0),
                                    Consumer<HotelDetailsScreenState>(
                                      builder: (context, state, _) {
                                        return RatingBar.builder(
                                          initialRating: state.rating,
                                          minRating: 1,
                                          direction: Axis.horizontal,
                                          allowHalfRating: true,
                                          itemCount: 5,
                                          itemSize: 24.0,
                                          unratedColor: Colors.grey[300],
                                          itemPadding: EdgeInsets.zero,
                                          itemBuilder: (context, index) {
                                            switch (index) {
                                              case 0:
                                                return Icon(
                                                  Icons.star_border,
                                                  color: Colors.yellow,
                                                );
                                              default:
                                                return Icon(
                                                  Icons.star,
                                                  color: index <=
                                                          state.rating.toInt()
                                                      ? Colors.yellow
                                                      : Colors.grey[300],
                                                );
                                            }
                                          },
                                          onRatingUpdate: (rating) {
                                            state.updateRating(rating);
                                          },
                                        );
                                      },
                                    ),
                                    SizedBox(height: 8.0),
                                    TextField(
                                      controller: _commentController,
                                      decoration: InputDecoration(
                                        hintText: 'Add your comments here',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 16.0),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        ElevatedButton(
                                          onPressed: () async {
                                            String username =
                                                await FirebaseFirestore.instance
                                                    .collection('Clients')
                                                    .doc(FirebaseAuth.instance
                                                        .currentUser!.uid)
                                                    .get()
                                                    .then((doc) =>
                                                        doc.get('Username'));
                                            print(username);
                                            Map<String, dynamic> data = {
                                              'username': username,
                                              'rating': state.rating,
                                              'comment': _commentController.text
                                                  .trim(),
                                              'timestamp':
                                                  FieldValue.serverTimestamp(),
                                            };
                                            final reviewsRef = FirebaseFirestore
                                                .instance
                                                .collection('Hotels')
                                                .doc(hotelId)
                                                .collection('Reviews');

                                            final querySnapshot =
                                                await reviewsRef
                                                    .where('username',
                                                        isEqualTo: username)
                                                    .limit(1)
                                                    .get();

                                            if (querySnapshot.docs.isNotEmpty) {
                                              final reviewDoc =
                                                  querySnapshot.docs.first;
                                              await reviewDoc.reference.update({
                                                'rating': state.rating,
                                                'comment': _commentController
                                                    .text
                                                    .trim(),
                                                'timestamp': FieldValue
                                                    .serverTimestamp(),
                                              });
                                            } else {
                                              final data = {
                                                'username': username,
                                                'rating': state.rating,
                                                'comment': _commentController
                                                    .text
                                                    .trim(),
                                                'timestamp': FieldValue
                                                    .serverTimestamp(),
                                              };
                                              await reviewsRef.add(data);
                                            }

                                            _commentController.clear();
                                            Provider.of<HotelDetailsScreenState>(
                                                    context,
                                                    listen: false)
                                                .updateRating(0.0);

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                    'Review added successfully.'),
                                              ),
                                            );
                                          },
                                          child: Text('Submit'),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ));
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        );
      }),
    );
  }
}
