import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

void main() {
  runApp(const MyApp());
}

class Weather {
  final double currentTemp;
  final double highTemp;
  final double lowTemp;
  final String description;
  final String cityName;
  final String iconCode;

  Weather({
    required this.currentTemp,
    required this.highTemp,
    required this.lowTemp,
    required this.description,
    required this.cityName,
    required this.iconCode,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      currentTemp: (json['main']['temp'] as num?)?.toDouble() ?? 0.0,
      highTemp: (json['main']['temp_max'] as num?)?.toDouble() ?? 0.0,
      lowTemp: (json['main']['temp_min'] as num?)?.toDouble() ?? 0.0,
      description: json['weather'][0]['description'] ?? 'No description',
      cityName: json['name'] ?? 'Unknown location',
      iconCode: json['weather'][0]['icon'] ?? '',
    );
  }
}

class WeatherService {
  static const String apiKey = '71d522cdb55abba8a5bb542249b2f4eb';
  static const String url =
      'https://api.openweathermap.org/data/2.5/weather?q=Karachi&units=metric&appid=$apiKey';

  Future<Weather> fetchWeather() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Weather.fromJson(jsonData);
    } else {
      throw Exception('Failed to load weather data');
    }
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather> futureWeather;

  @override
  void initState() {
    super.initState();
    futureWeather = WeatherService().fetchWeather();
  }

  String getCurrentDateTime() {
    final now = DateTime.now();
    final formattedDate = DateFormat('EEEE, MMM d, y').format(now);
    final formattedTime = DateFormat('h:mm a').format(now);
    return '$formattedDate \n $formattedTime';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karachi Weather'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder(
        future: futureWeather,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('No data found'));
          } else {
            final weather = snapshot.data!;
            final String iconUrl = 'https://openweathermap.org/img/wn/${weather.iconCode}@2x.png';
            return Center(
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                elevation: 10,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        getCurrentDateTime(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18, color: Colors.black54),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        weather.cityName,
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Image.network(iconUrl, width: 100, height: 100),
                      ),
                      Text(
                        '${weather.currentTemp}°C',
                        style: const TextStyle(fontSize: 60, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        weather.description.toUpperCase(),
                        style: const TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'High: ${weather.highTemp}°C  |  Low: ${weather.lowTemp}°C',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}