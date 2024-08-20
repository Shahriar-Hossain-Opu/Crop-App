import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'Sensorpage.dart'; // Import your SensorPage.dart file
import 'pond.dart';

void main() {
  runApp(MyApp());
}

class User {
  int id;
  String username;
  String email;
  String role;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'role': role,
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crop Recommendation App',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController userIdController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController roleController = TextEditingController();

  User? currentUser;

  Future<void> _fetchUser(int userId) async {
    try {
      final response = await http.get(Uri.parse('http://172.18.212.224:8000/getusers/$userId'));
      if (response.statusCode == 200) {
        setState(() {
          currentUser = User.fromJson(json.decode(response.body));
          usernameController.text = currentUser!.username;
          emailController.text = currentUser!.email;
          roleController.text = currentUser!.role;
        });
      } else {
        throw Exception('Failed to fetch user');
      }
    } catch (error) {
      print('Error fetching user: $error');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching user'),
      ));
    }
  }

  // Define your _updateUser, _deleteUser, and other methods as before...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Information'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/a1.jpeg'), // Background image path
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: userIdController,
                  decoration: InputDecoration(labelText: 'Enter User ID'),
                  keyboardType: TextInputType.number,
                ),
                ElevatedButton(
                  onPressed: () {
                    int userId = int.tryParse(userIdController.text) ?? 0;
                    _fetchUser(userId);
                  },
                  child: Text('User Info'),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(labelText: 'Username'),
                ),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                ),
                TextField(
                  controller: roleController,
                  decoration: InputDecoration(labelText: 'Role'),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PondPage()), // Navigate to PondPage
                    );
                  },
                  icon: Icon(Icons.place),
                  label: Text('Field Information'),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  icon: Icon(Icons.logout),
                  label: Text('Logout'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
