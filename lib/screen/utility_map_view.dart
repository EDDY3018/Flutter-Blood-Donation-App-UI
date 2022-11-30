import 'dart:async';
import 'package:google_maps_webservice/places.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

final places =
    GoogleMapsPlaces(apiKey: "AIzaSyA0gOwMox4dRKcnAyLedbS5ex0RcbK1PGI");

class UtilityMapView extends StatefulWidget {
  const UtilityMapView({Key? key}) : super(key: key);

  @override
  _UtilityMapViewState createState() => _UtilityMapViewState();
}

class _UtilityMapViewState extends State<UtilityMapView> {
  late Future<Position> _currentLocation;
  final Set<Marker> _markers = {};

  Future<void> _retrieveNearbyRestaurants(LatLng _userLocation) async {
    PlacesSearchResponse _response = await places.searchNearbyWithRadius(
        Location(lat: _userLocation.latitude, lng: _userLocation.longitude),
        10000,
        type: "restaurant");
    print("ERROR :- " + _response.errorMessage!);
    Set<Marker> _restaurantMarkers = _response.results
        .map((result) => Marker(
            markerId: MarkerId(result.name),
            icon: BitmapDescriptor.defaultMarkerWithHue(
                BitmapDescriptor.hueAzure),
            infoWindow: InfoWindow(
                title: result.name,
                snippet: "Ratings: " + (result.rating.toString())),
            position: LatLng(
                result.geometry!.location.lat, result.geometry!.location.lng)))
        .toSet();
    setState(() {
      _markers.addAll(_restaurantMarkers);
    });
  }

  @override
  void initState() {
    _currentLocation = Geolocator.getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _currentLocation,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              // The user location returned from the snapshot
              Position? snapshotData = snapshot.data as Position?;
              LatLng _userLocation =
                  LatLng(snapshotData!.latitude, snapshotData.longitude);

              if (_markers.isEmpty) {
                _retrieveNearbyRestaurants(_userLocation);
              }
              return GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: _userLocation,
                  zoom: 12,
                ),
                markers: _markers
                  ..add(Marker(
                      markerId: const MarkerId("User Location"),
                      infoWindow: const InfoWindow(title: "User Location"),
                      position: _userLocation)),
              );
            } else {
              return const Center(child: Text("Failed to get user location."));
            }
          }
          // While the connection is not in the done state yet
          return const Center(child: CircularProgressIndicator());
        });
  }
}
