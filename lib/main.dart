import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/edit_person_screen.dart';
import 'screens/add_person_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',  // Start the app from the login screen
      routes: {
        '/login': (context) => LoginScreen(),  // Login screen route
        '/home': (context) => HomeScreen(),  // Home screen route
        '/add-person': (context) => AddPersonScreen(),  // Add the route for AddPersonScreen
        '/edit-person': (context) => EditPersonScreen(),  // Edit person screen route
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
