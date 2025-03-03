import 'package:flutter/material.dart';

class MapModel extends ChangeNotifier {
  int _streetId = 0;
  String _streetName = "";
  String _imageUrl = "";
  dynamic _locations = null;
  int get streetId => _streetId;
  String get streetName => _streetName;
  String get imageUrl => _imageUrl;
  dynamic get locations => _locations;

  setStreetName(String streetName) {
    _streetName = streetName;
    notifyListeners();
  }

  setImage(String imageUrl) {
    _imageUrl = imageUrl;
    notifyListeners();
  }

  setLocations(locations) {
    _locations = locations;
    notifyListeners();
  }

  setStreetId(streetId) {
    _streetId = streetId;
    notifyListeners();
  }
}
