import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(MyApp());
}

class SensorData {
  final int id;
  final double N;
  final double P;
  final double K;
  final double temp;
  final double hum;
  final double ph;
  final double rain;

  SensorData({
    required this.id,
    required this.N,
    required this.P,
    required this.K,
    required this.temp,
    required this.hum,
    required this.ph,
    required this.rain,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      id: json['Id'],
      N: json['N'],
      P: json['P'],
      K: json['K'],
      temp: json['temp'],
      hum: json['hum'],
      ph: json['ph'],
      rain: json['rain'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Recommendation',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SensorDataPage(),
    );
  }
}

class SensorDataPage extends StatefulWidget {
  @override
  _SensorDataPageState createState() => _SensorDataPageState();
}

class _SensorDataPageState extends State<SensorDataPage> {
  late Future<SensorData> sensorData;
  bool isListView = true;

  Future<SensorData> fetchSensorData() async {
    final response = await http.get(Uri.parse('http://172.18.212.224:8000/latest_sensor_data/'));
    if (response.statusCode == 200) {
      return SensorData.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sensor data');
    }
  }

  @override
  void initState() {
    super.initState();
    sensorData = fetchSensorData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Recommendation'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                isListView = !isListView;
              });
            },
            icon: Icon(isListView ? Icons.grid_view : Icons.list),
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/a3.jpeg',
            fit: BoxFit.cover,
          ),
          // Content
          Center(
            child: FutureBuilder<SensorData>(
              future: sensorData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return isListView
                      ? SensorDataListView(sensorData: snapshot.data!)
                      : SensorDataGridView(sensorData: snapshot.data!);
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CropPredictPage(sensorData: sensorData)),
          );
        },
        label: Text('Predict Crop'),
        icon: Icon(Icons.search),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class SensorDataListView extends StatelessWidget {
  final SensorData sensorData;

  const SensorDataListView({Key? key, required this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.all(16),
      children: [
        SensorDataCard(title: 'ID', value: '${sensorData.id}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'N', value: '${sensorData.N}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'P', value: '${sensorData.P}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'K', value: '${sensorData.K}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'Temperature', value: '${sensorData.temp}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'Humidity', value: '${sensorData.hum}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'pH', value: '${sensorData.ph}'),
        SizedBox(height: 16),
        SensorDataCard(title: 'Rainfall', value: '${sensorData.rain}'),
      ],
    );
  }
}

class SensorDataGridView extends StatelessWidget {
  final SensorData sensorData;

  const SensorDataGridView({Key? key, required this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      padding: EdgeInsets.all(16),
      children: [
        SensorDataCard(title: 'ID', value: '${sensorData.id}'),
        SensorDataCard(title: 'N', value: '${sensorData.N}'),
        SensorDataCard(title: 'P', value: '${sensorData.P}'),
        SensorDataCard(title: 'K', value: '${sensorData.K}'),
        SensorDataCard(title: 'Temperature', value: '${sensorData.temp}'),
        SensorDataCard(title: 'Humidity', value: '${sensorData.hum}'),
        SensorDataCard(title: 'pH', value: '${sensorData.ph}'),
        SensorDataCard(title: 'Rainfall', value: '${sensorData.rain}'),
      ],
    );
  }
}

class SensorDataCard extends StatelessWidget {
  final String title;
  final String value;

  const SensorDataCard({Key? key, required this.title, required this.value}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 28, // Increased font size
              ),
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 27, // Increased font size
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CropPredictPage extends StatelessWidget {
  final Future<SensorData> sensorData;

  const CropPredictPage({Key? key, required this.sensorData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Predict Crop'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/a3.jpeg',
            fit: BoxFit.cover,
          ),
          // Content
          Center(
            child: FutureBuilder<SensorData>(
              future: sensorData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('N: ${snapshot.data!.N}'),
                      Text('P: ${snapshot.data!.P}'),
                      Text('K: ${snapshot.data!.K}'),
                      Text('Temperature: ${snapshot.data!.temp}'),
                      Text('Humidity: ${snapshot.data!.hum}'),
                      Text('pH: ${snapshot.data!.ph}'),
                      Text('Rainfall: ${snapshot.data!.rain}'),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () async {
                          final cropPrediction = await predictCrop(snapshot.data!);
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Crop Prediction'),
                                content: Text('Predicted Crop: $cropPrediction'),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Text('Predict Crop'),
                      ),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('${snapshot.error}');
                }
                return CircularProgressIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String> predictCrop(SensorData data) async {
    final response = await http.post(
      Uri.parse('http://172.18.212.224:8000/predict_crop'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({
        'N': data.N,
        'P': data.P,
        'K': data.K,
        'temp': data.temp,
        'hum': data.hum,
        'ph': data.ph,
        'rain': data.rain,
      }),
    );
    if (response.statusCode == 200) {
      final prediction = jsonDecode(response.body);
      return prediction['predicted_crop'];
    } else {
      throw Exception('Failed to predict crop');
    }
  }
}
