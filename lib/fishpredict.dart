import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CropPredictPage extends StatefulWidget {
  @override
  _CropPredictPageState createState() => _CropPredictPageState();
}

class _CropPredictPageState extends State<CropPredictPage> {
  String predictedCrop = 'Loading...';

  // Function to fetch latest sensor data from the API
  Future<Map<String, dynamic>> fetchLatestSensorData() async {
    try {
      // Make GET request to the latest_sensor_data endpoint
      var response = await http.get(
        Uri.parse('http://172.18.212.224:8000/latest_sensor_data'), // Replace with your FastAPI server IP
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        var data = jsonDecode(response.body);
        return data;
      } else {
        print('Failed to load sensor data: ${response.statusCode}');
        return {};
      }
    } catch (e) {
      print('Error fetching latest sensor data: $e');
      return {};
    }
  }

  // Function to fetch crop prediction from the API using latest sensor data
  Future<void> fetchCropPrediction() async {
    try {
      var latestSensorData = await fetchLatestSensorData();
      if (latestSensorData.isEmpty) {
        setState(() {
          predictedCrop = 'Failed to fetch sensor data';
        });
        return;
      }

      // Make POST request to the predict endpoint with latest sensor data
      var response = await http.post(
        Uri.parse('http://172.18.212.224:8000/predict_crop'), // Replace with your FastAPI server IP
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, double>{
          'N': latestSensorData['N'],
          'P': latestSensorData['P'],
          'K': latestSensorData['K'],
          'temperature': latestSensorData['temp'],
          'humidity': latestSensorData['hum'],
          'pH': latestSensorData['ph'],
          'rainfall': latestSensorData['rain'],
        }),
      );

      if (response.statusCode == 200) {
        // Parse the response JSON
        var predictionData = jsonDecode(response.body);

        // Update the state with the predicted crop
        setState(() {
          predictedCrop = predictionData['predicted_crop'];
        });
      } else {
        print('Failed to load prediction: ${response.statusCode}');
        setState(() {
          predictedCrop = 'Failed to load prediction';
        });
      }
    } catch (e) {
      print('Error fetching crop prediction: $e');
      setState(() {
        predictedCrop = 'Error fetching crop prediction';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchCropPrediction(); // Fetch crop prediction when the widget initializes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Prediction'),
        backgroundColor: Colors.green,
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background image
          Image.asset(
            'assets/crop_background.jpg',
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,
          ),
          // Content
          Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildPredictionBox('Predicted Crop', predictedCrop),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: fetchCropPrediction, // Fetch crop prediction again when button is pressed
                    child: Text('Predict Again'),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate back to the main page
                      Navigator.pop(context);
                    },
                    child: Text('Back'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionBox(String title, String prediction) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueGrey),
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.white.withOpacity(0.8), // Adjust opacity as needed
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10),
          Text(
            prediction,
            style: TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
