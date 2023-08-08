import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
//import 'package:geocoding/geocoding.dart' hide Location;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as R;
//import 'package:location/location.dart';

import '../constants.dart';

class LocationTrackin extends StatefulWidget {
  //final String hotelId;
  final GeoPoint currentHotel;
  //const LocationTrackin({Key? key, required this.hotelId}) : super(key: key);
  const LocationTrackin({Key? key, required this.currentHotel})
      : super(key: key);
  @override
  State<LocationTrackin> createState() => _LocationTrackinState();
}

class _LocationTrackinState extends State<LocationTrackin> {
  final Completer<GoogleMapController> _controller = Completer();
  static LatLng sourceLocation = const LatLng(18.4552275, 73.8180502);
  static LatLng destination = const LatLng(18.521014, 73.871606);

  List<LatLng> polylineCoordinates = [];
  Position? currentLocation;

  //BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  void setDestination() {
    destination = LatLng(
      widget.currentHotel.latitude,
      widget.currentHotel.longitude,
    );

    if (mounted) {
      setState(() {});
    }
  }

  void setCustomMarkerIcon() {
    BitmapDescriptor.fromAssetImage(
            const ImageConfiguration(size: Size(12, 12)),
            "assets/images/restaurant-pin.png")
        .then(
      (icon) {
        destinationIcon = icon;
      },
    );
    BitmapDescriptor.fromAssetImage(
            ImageConfiguration.empty, "assets/images/man.png")
        .then(
      (icon) {
        currentLocationIcon = icon;
      },
    );
  }

  void setSourceLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    final newLocate = LatLng(position.latitude, position.longitude);
    print(
        "********************************************************************");
    print(newLocate);
    // update sourceLocation with the new location
    sourceLocation = newLocate;
    if (mounted) {
      setState(() {});
    }
  }

  R.LocationData? newLocation;
  void getCurrentLocation() {
    R.Location location = R.Location();
    location.getLocation().then(
      (location) {
        newLocation = location;
      },
    );

    location.onLocationChanged.listen(
      (newLoc) {
        newLocation = newLoc;

        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 15.5,
            target: LatLng(newLoc.latitude!, newLoc.longitude!),
          ),
          // ),
        );

        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void getPolyPoints() async {
    PolylinePoints polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      google_api_key,
      PointLatLng(sourceLocation.latitude, sourceLocation.longitude),
      PointLatLng(destination.latitude, destination.longitude),
    );
    if (result.points.isNotEmpty) {
      result.points.forEach(
        (PointLatLng point) => polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        ),
      );
      if (mounted) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    setDestination();
    setSourceLocation();

    setCustomMarkerIcon();
    getCurrentLocation();
    getPolyPoints();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Direction",
          ),
        ),
        body: newLocation == null
            ? const Center(
                child: Text("Loading"),
              )
            : GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: sourceLocation,
                  zoom: 15.5,
                ),
                polylines: {
                  Polyline(
                      polylineId: PolylineId("route"),
                      points: polylineCoordinates,
                      color: primaryColor,
                      width: 6)
                },
                markers: {
                  Marker(
                      markerId: const MarkerId("currentLocation"),
                      icon: currentLocationIcon,
                      position: LatLng(
                          newLocation!.latitude!, newLocation!.longitude!)),
                  Marker(
                      markerId: MarkerId("Source"), position: sourceLocation),
                  Marker(
                      markerId: MarkerId("Destination"),
                      icon: destinationIcon,
                      position: destination)
                },
                onMapCreated: (mapcontroller) {
                  _controller.complete(mapcontroller);
                },
              ));
  }
}
