import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:weather_app/additioanl_info_item.dart';
import 'package:weather_app/hourly_forecast_item.dart';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Map<String, dynamic>> weatherData;
  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Lagos';
      String apiKey = 'af1a7f3fcee15d34c9b5ad2b6a45d0ce';
      final url = Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$apiKey');
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (data['cod'] != '200') {
        throw 'An Unexpected Error Occured';
      }
      return data;
    } catch (e) {
      // debugPrint('Error: $e');
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    weatherData = getCurrentWeather();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                weatherData = getCurrentWeather();
              });
              debugPrint('Refresh button tapped');
            },
          ),
        ],
      ),
      body: FutureBuilder(
        future: weatherData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator.adaptive(),
            );
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Text('No Data Received'),
            );
          }
          final data = snapshot.data as Map<String, dynamic>;
          final currentWeatherData = data['list'][0];
          final currentTemp = currentWeatherData['main']['temp'];
          final currentSky = currentWeatherData['weather'][0]['main'];
          final currentPressure = currentWeatherData['main']['pressure'];
          final currentHumidity = currentWeatherData['main']['humidity'];
          final currentWindSpeed = currentWeatherData['wind']['speed'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // main card
                SizedBox(
                  width: double.infinity,
                  child: Card(
                    elevation: 10,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(
                          sigmaX: 10,
                          sigmaY: 10,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              Text(
                                '$currentTemp K',
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Icon(
                                currentSky == 'Clouds' || currentSky == 'Rain'
                                    ? Icons.cloud
                                    : Icons.wb_sunny,
                                size: 64,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                currentSky,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    itemCount: 5,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final hourlyForecast = data['list'][index + 1];
                      final hourlySky = hourlyForecast['weather'][0]['main'];
                      final hourlyTemp = hourlyForecast['main']['temp'];
                      final hourlyTime =
                          DateTime.parse(hourlyForecast['dt_txt']);
                      final time = DateFormat('HH:mm').format(hourlyTime);

                      return HourlyForecastItem(
                        time: time,
                        icon: hourlySky == 'Clouds' || hourlySky == 'Rain'
                            ? Icons.cloud
                            : Icons.wb_sunny,
                        temp: hourlyTemp.toString(),
                      );
                    },
                  ),
                ),
                // weather forecast cards
                // additional information
                const SizedBox(height: 20),
                const Text(
                  'Additional Information',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  children: [
                    AdditionalInfoWidget(
                      // humidity
                      icon: Icons.water_drop,
                      title: 'Humidity',
                      value: currentHumidity.toString(),
                    ),
                    AdditionalInfoWidget(
                      // wind speed
                      icon: Icons.air,
                      title: 'Wind Speed',
                      value: currentWindSpeed.toString(),
                    ),
                    AdditionalInfoWidget(
                      // pressure
                      icon: Icons.beach_access_sharp,
                      title: 'Pressure',
                      value: currentPressure.toString(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// class AdditionalInfoItem extends StatelessWidget {
//   const AdditionalInfoItem({super.key, this.title, this.iconName, this.value});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       elevation: 6,
//       child: Container(
//         width: 100,
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: const Column(
//           children: [
//             Text(
//               '03:00',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(height: 8),
//             Icon(
//               Icons.cloud,
//               size: 32,
//             ),
//             Text('320.12'),
//           ],
//         ),
//       ),
//     );
//   }
// }
