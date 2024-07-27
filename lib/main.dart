import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weatherapp/apis/service/weather_service.dart';
import 'package:weatherapp/firebase_options.dart';
import 'package:weatherapp/src/views/auth/auth_view.dart';
import 'package:weatherapp/src/views/weather/weather_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => WeatherService()),
        ChangeNotifierProvider(
            create: (context) =>
                WeatherViewModel(context.read<WeatherService>())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Weather App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFF8B00A)),
          useMaterial3: true,
        ),
        home: const AuthView(),
      ),
    );
  }
}
