import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'login.dart';
import 'home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CROP Recommendation System',
      debugShowCheckedModeBanner: false,
      home: WelcomePage(), // Use SplashScreen as the home page
      routes: {
        '/welcome': (context) => WelcomePage(), // WelcomePage route
        '/login': (context) => LoginScreen(),
        '/registration': (context) => OTPGenerator(),
        '/home': (context) => HomePage(),
      },
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.lightBlue[100],
      ),
    );
  }
}


class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crop Recommendation App'),
        backgroundColor: Colors.white70,

      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/a3.jpeg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to CROP Recommendation App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                child: Text('Login'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/registration');
                },
                child: Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class User {
  final String username;
  final String password;
  final String email;
  final String role;

  User({
    required this.username,
    required this.password,
    required this.email,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'role': role,
    };
  }
}

class OTPGenerator extends StatefulWidget {
  @override
  _OTPGeneratorState createState() => _OTPGeneratorState();
}

class _OTPGeneratorState extends State<OTPGenerator> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _roleController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _isOTPGenerated = false;
  String _otp = '';
  String _verificationMessage = '';

  Future<void> _createUser() async {
    final user = User(
      username: _usernameController.text,
      password: _passwordController.text,
      email: _emailController.text,
      role: _roleController.text,
    );

    final response = await http.post(
      Uri.parse('http://172.18.212.224:8000/users/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final String message = responseData['msg'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create user')),
      );
    }
  }

  Future<void> _generateOTP() async {
    final String apiUrl = 'http://172.18.212.224:8000/generate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {'email': _emailController.text});

    final response = await http.post(
      uri,
    );

    if (response.statusCode == 200) {
      print('OTP generated successfully');
      _showOTPDialog();
    } else {
      print('Failed to generate OTP: ${response.body}');
    }
  }

  Future<void> _validateOTP() async {
    final String apiUrl = 'http://172.18.212.224:8000/validate_otp/';
    final Uri uri = Uri.parse(apiUrl).replace(queryParameters: {
      'email': _emailController.text,
      'entered_otp': _otpController.text,
    });

    final response = await http.post(
      uri,
    );

    if (response.statusCode == 200) {
      setState(() {
        _verificationMessage = 'OTP verified successfully';
      });
    } else {
      setState(() {
        _verificationMessage = 'Failed to verify OTP';
      });
    }
  }

  Future<void> _showOTPDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    'Enter OTP',
                    style: Theme.of(context).textTheme.headline6,
                  ),
                  SizedBox(height: 16.0),
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'OTP'),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _validateOTP();
                _createUser();
                Navigator.of(context).pop();
              },
              child: Text('Verify'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Registration'),

      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _usernameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Username',
              ),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                labelText: 'Password',
              ),
            ),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
              ),
            ),
            TextField(
              controller: _roleController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                labelText: 'Role',
              ),
            ),
            SizedBox(height: 5.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _generateOTP,
                  icon: Icon(Icons.person_add),
                  label: Text('SignUp'),
                ),
                ElevatedButton.icon(
                  onPressed:(){
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                  ,
                  icon: Icon(Icons.login),
                  label: Text('Login'),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            if (_isOTPGenerated)
              Text(
                'OTP Generated: $_otp',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 16.0),
            Text(
              _verificationMessage,
              style: TextStyle(
                color: _verificationMessage.contains('successfully')
                    ? Colors.green
                    : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
