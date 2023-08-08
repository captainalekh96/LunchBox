import 'package:cloud_firestore/cloud_firestore.dart';

class Review {
  final String username;
  final String comment;
  final double rating;
  final Timestamp timestamp;

  Review({
    required this.username,
    required this.comment,
    required this.rating,
    required this.timestamp,
  });

  factory Review.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Review(
      username: data['username'] ?? '',
      comment: data['comment'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      timestamp: data['timestamp'] ?? Timestamp.now(),
    );
  }
}
