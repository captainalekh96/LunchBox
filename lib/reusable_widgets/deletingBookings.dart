import 'package:cloud_firestore/cloud_firestore.dart';

void checkVaildMenu(String hotelId) async {
  DateTime now = DateTime.now();

  // Get the `Time end` from the hotel's menu
  DocumentSnapshot<Map<String, dynamic>> menuSnapshot = await FirebaseFirestore
      .instance
      .collection('Hotels')
      .doc(hotelId)
      .collection('Menu')
      .doc('menu')
      .get();
  Timestamp? timeEnd = menuSnapshot.data()?['Time End'];

  if (timeEnd != null && now.isAfter(timeEnd.toDate())) {
    // Get a reference to the `BookedAt` subcollection

    //Hotel Collection

    CollectionReference<Map<String, dynamic>> hotelBookings = FirebaseFirestore
        .instance
        .collection('Hotels')
        .doc(hotelId)
        .collection('Menu')
        .doc('menu')
        .collection('Bookings');
    QuerySnapshot<Map<String, dynamic>> hotelbookingSnapshot =
        await hotelBookings.get();
    for (var doc in hotelbookingSnapshot.docs) {
      doc.reference.delete();
    }
    CollectionReference<Map<String, dynamic>> hotelCollectionRef =
        FirebaseFirestore.instance
            .collection('Hotels')
            .doc(hotelId)
            .collection('Menu');
    QuerySnapshot<Map<String, dynamic>> hotelquerySnapshot =
        await hotelCollectionRef.get();

    // Delete the documents in the subcollection

    for (var doc in hotelquerySnapshot.docs) {
      doc.reference.delete();
    }
  }
}

void checkVaildBookingClient(String userId, String hotelId) async {
  DateTime now = DateTime.now();

  // Get the `Time end` from the hotel's menu
  DocumentSnapshot<Map<String, dynamic>> menuSnapshot = await FirebaseFirestore
      .instance
      .collection('Hotels')
      .doc(hotelId)
      .collection('Menu')
      .doc('menu')
      .get();
  Timestamp? timeEnd = menuSnapshot.data()?['Time End'];

  if (!menuSnapshot.exists || now.isAfter(timeEnd!.toDate())) {
    // Get a reference to the `BookedAt` subcollection

    CollectionReference<Map<String, dynamic>> collectionRef = FirebaseFirestore
        .instance
        .collection('Clients')
        .doc(userId)
        .collection('BookedAt');

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await collectionRef.get();

    // Delete the documents in the subcollection

    for (var doc in querySnapshot.docs) {
      doc.reference.delete();
    }
  }
}
