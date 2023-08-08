import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class HotelDetailsScreenState extends ChangeNotifier {
  double _rating = 0.0;
  TimeOfDay? _bookingTime;
  String? _hotelName;
  TimeOfDay get bookingTime => _bookingTime!;
  String get hotelName => _hotelName!;
  double get rating => _rating;

  void setBookingTime(TimeOfDay booking) {
    _bookingTime = booking;
    notifyListeners();
  }

  void setBookedHotel(String hotelName) {
    _hotelName = hotelName;
    notifyListeners();
  }

  void updateRating(double value) {
    _rating = value;
    notifyListeners();
  }
}
