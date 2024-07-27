import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:weatherapp/apis/models/weather_model.dart';

class WeatherService {
  final String apiKey = '71ced824c06aeece5832d666f4f632a8';
  final String baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> fetchWeather(double lat, double lon) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl?lat=$lat&lon=$lon&exclude=minutely,hourly,daily,alerts&units=metric&appid=$apiKey'),
    );
    if (response.statusCode == 200) {
      log(response.body);
      return WeatherModel.fromJson(
          jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}
