import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weatherapp/apis/models/weather_model.dart';
import 'package:weatherapp/apis/service/weather_service.dart';

class WeatherViewModel extends ChangeNotifier {
  final WeatherService _weatherService;
  WeatherModel? _weather;
  bool _isLoading = false;
  String _addressLocation = "";
  String _weatherId = "";

  WeatherViewModel(this._weatherService);

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String get addressLocation => _addressLocation;
  String get weatherId => _weatherId;

  Future<void> fetchWeather(double lat, double lon) async {
    _isLoading = true;
    notifyListeners();
    try {
      _weather = await _weatherService.fetchWeather(lat, lon);
    } catch (e) {
      print(e.toString());
      // handle error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCoordinatesFromAddress(String address) async {
    try {
      // Perform the geocoding lookup
      List<Location> locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        Location location = locations.first;
        double latitude = location.latitude;
        double longitude = location.longitude;
        _addressLocation = address;
        fetchWeather(latitude, longitude);
      } else {
        print('No location found for the address.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  String _getWeatherIcon(int weatherId) {
    if (weatherId < 300) {
      return '🌩';
    } else if (weatherId < 400) {
      return '🌧';
    } else if (weatherId < 600) {
      return '🌦';
    } else if (weatherId < 700) {
      return '🌨';
    } else if (weatherId < 800) {
      return '🌫';
    } else if (weatherId == 800) {
      return '☀️';
    } else if (weatherId <= 804) {
      return '☁️';
    } else {
      return '❓';
    }
  }
}
