import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import 'Review.dart';

class OwnerReviewScreen extends StatefulWidget {
  const OwnerReviewScreen({super.key});

  @override
  State<OwnerReviewScreen> createState() => _OwnerReviewScreenState();
}

class _OwnerReviewScreenState extends State<OwnerReviewScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _reply = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ratings and Reviews'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('Hotels')
            .doc(FirebaseAuth.instance.currentUser!.uid)
            .collection('Reviews')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child:
                  Text('Oops! Something went wrong. Please try again later.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          QuerySnapshot reviewSnapshot = snapshot.data!;
          List<QueryDocumentSnapshot> reviewDocs = reviewSnapshot.docs;
          List<Review> reviews =
              reviewDocs.map((doc) => Review.fromSnapshot(doc)).toList();

          double averageRating = reviews.fold(
                  0.0, (double sum, Review review) => sum + review.rating) /
              reviews.length;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.0),
                  Text(
                    'Reviews:',
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Montserrat',
                    ),
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      SizedBox(width: 4.0),
                      Text(
                        '${averageRating.toStringAsFixed(1)}',
                        style: TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(width: 4.0),
                      Text(
                        '(${reviews.length} ${reviews.length == 1 ? 'review' : 'reviews'})',
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0),
                  reviews.length > 0
                      ? Column(
                          children: reviews
                              .map((review) => Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.person,
                                            size: 16.0,
                                          ),
                                          SizedBox(width: 8.0),
                                          Text(
                                            review.username,
                                            style: TextStyle(
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Row(
                                        children: [
                                          SizedBox(width: 8.0),
                                          Icon(
                                            Icons.star,
                                            size: 16.0,
                                            color: Colors.yellow,
                                          ),
                                          SizedBox(width: 4.0),
                                          Text(
                                            '${review.rating.toStringAsFixed(1)}',
                                            style: TextStyle(fontSize: 16.0),
                                          ),
                                          Spacer(),
                                        ],
                                      ),
                                      SizedBox(height: 8.0),
                                      Text(
                                        review.comment,
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                        textAlign: TextAlign.right,
                                      ),
                                      /* TextFormField(
                                        controller: _reply,
                                        decoration: InputDecoration(
                                            hintText: "Reply",
                                            icon: Icon(Icons.reply)),
                                      ),*/
                                      Divider(
                                        thickness: 1.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                        height: 32.0,
                                      ),
                                    ],
                                  ))
                              .toList(),
                        )
                      : Text(
                          'No reviews yet. Be the first to add one!',
                          style: TextStyle(fontSize: 16.0),
                        ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
