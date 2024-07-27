import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/apis/models/weather_model.dart';
import 'package:weatherapp/src/core/images.dart';
import 'package:weatherapp/src/views/weather/weather_view_model.dart';
import 'package:weatherapp/src/views/weather/widgets/search_field.dart';

class WeatherView extends StatefulWidget {
  const WeatherView({super.key});

  @override
  State<WeatherView> createState() => _WeatherViewState();
}

class _WeatherViewState extends State<WeatherView> {
  String? currentAddress;
  Position? currentPosition;
  TextEditingController locationController = TextEditingController();
  @override
  void initState() {
    _getCurrentPosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final kSize = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<WeatherViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.weather == null) {
            return const Center(child: Text('Failed to load weather'));
          }

          final weather = viewModel.weather!;
          return Container(
            decoration: const BoxDecoration(
                image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage(AppImages.backgroundImage))),
            height: kSize.height,
            width: kSize.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                Align(
                    alignment: Alignment.topRight,
                    child: SearchField(
                        onFieldSubmitted: (value) {
                          viewModel.getCoordinatesFromAddress(
                              locationController.text);
                        },
                        locationController: locationController)),
                const SizedBox(
                  height: 15,
                ),
                locationDetails(weather, viewModel),
                const Spacer(),
                weatherDetails(kSize, weather)
              ],
            ),
          );
        },
      ),
    );
  }

  Widget locationDetails(WeatherModel weather, WeatherViewModel viewModel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "${weather.main.temp}°",
            style: const TextStyle(color: Colors.white, fontSize: 40),
          ),
          Text(
            viewModel.addressLocation == ""
                ? weather.name
                : viewModel.addressLocation,
            style: const TextStyle(color: Colors.white, fontSize: 30),
          ),
          Text(
            formattedTime(),
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget weatherDetails(Size kSize, WeatherModel weather) {
    return Container(
      height: kSize.height * .5,
      width: kSize.width,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      decoration: BoxDecoration(color: Colors.black.withOpacity(.08)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.weather.first.main,
                    style: const TextStyle(color: Colors.white, fontSize: 28),
                  ),
                  Text(
                    weather.weather.first.description,
                    style: const TextStyle(color: Colors.white, fontSize: 22),
                  ),
                ],
              ),
              Image.network(
                'http://openweathermap.org/img/w/${weather.weather.first.icon}.png',
                height: 45,
              )
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          const Spacer(),
          rowWidget("Temp max", "${weather.main.tempMax}°", AppImages.tempIcon,
              Colors.red),
          rowWidget("Temp min", "${weather.main.tempMin}°", AppImages.tempIcon,
              Colors.blue),
          rowWidget("Humidity", "${weather.main.humidity}%",
              AppImages.humidityIcon, Colors.white),
          rowWidget("Cloudy", "${weather.clouds.all}%", AppImages.cloudIcon,
              Colors.white),
          rowWidget("Wind", "${weather.wind.speed}Km/h", AppImages.windIcon,
              Colors.white),
        ],
      ),
    );
  }

  Widget rowWidget(String title, String value, String image, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Image.asset(
            image,
            height: 20,
            color: color,
          )
        ],
      ),
    );
  }

  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location services are disabled. Please enable the services')));
      return false;
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')));
        return false;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Location permissions are permanently denied, we cannot request permissions.')));
      return false;
    }
    return true;
  }

  Future<void> _getCurrentPosition() async {
    final hasPermission = await _handleLocationPermission();

    if (!hasPermission) return;
    await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) {
      setState(() => currentPosition = position);
      _getAddressFromLatLng(currentPosition!);
      log("${currentPosition!.latitude}");
      log("${currentPosition!.longitude}");
      final viewModel = Provider.of<WeatherViewModel>(context, listen: false);
      viewModel.fetchWeather(
          currentPosition!.latitude, currentPosition!.longitude);
    }).catchError((e) {
      debugPrint(e);
    });
  }

  Future<void> _getAddressFromLatLng(Position position) async {
    await placemarkFromCoordinates(
            currentPosition!.latitude, currentPosition!.longitude)
        .then((List<Placemark> placemarks) {
      Placemark place = placemarks[0];
      setState(() {
        currentAddress =
            '${place.street}, ${place.subLocality}, ${place.subAdministrativeArea}, ${place.postalCode}';
      });
    }).catchError((e) {
      debugPrint(e);
    });
  }

  String formattedTime() {
    final now = DateTime.now();
    final format = DateFormat('hh:mm a - EEEE dd, MMM yy');
    final formattedDate = format.format(now);
    return formattedDate;
  }
}
