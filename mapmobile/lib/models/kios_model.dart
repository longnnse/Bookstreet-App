import 'package:flutter/material.dart';

class KiosModel extends ChangeNotifier {
  int _kiosId = 0;
  String _kiosName = '';
  double _xLocation = 0;
  double _yLocation = 0;
  int get kiosId => _kiosId;
  String get kiosName => _kiosName;
  double get xLocation => _xLocation;
  double get yLocation => _yLocation;

  KiosModel setKiosId(int kiosId) {
    _kiosId = kiosId;
    return this;
  }

  KiosModel setkiosName(String kiosName) {
    _kiosName = kiosName;
    return this;
  }

  KiosModel setxLocation(double xLocation) {
    _xLocation = xLocation;
    return this;
  }

  KiosModel setyLocation(double yLocation) {
    _yLocation = yLocation;
    return this;
  }
}
