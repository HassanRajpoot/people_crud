import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAuthenticated = false;
  String? _authToken;
  bool _isLoading = false;
  String? _errorMessage;
  List<dynamic> _people = [];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }
  void _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      _errorMessage  = 'Logout failed';
    }
  }
  // Check if the user is authenticated by checking if the auth_token is present
  void _checkAuthStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('auth_token');
    if (_authToken != null) {
      setState(() {
        _isAuthenticated = true;
      });
      _fetchPeople();
    } else {
      setState(() {
        _isAuthenticated = false;
      });
    }
  }

  // Fetch the list of people from the API using the auth_token
  Future<void> _fetchPeople() async {
    if (_authToken == null) {
      setState(() {
        _errorMessage = 'Authentication token not found';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/person'), // API endpoint
        headers: {
          'Authorization': 'Bearer $_authToken', // Sending the token in the header
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        setState(() {
          _people = responseData['people'];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to load people data';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  // Function to delete a person (this could be connected to your backend API)
  Future<void> _deletePerson(int personId) async {
    try {
      final response = await http.delete(
        Uri.parse('http://127.0.0.1:8000/api/person/$personId'), // Modify API endpoint
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Accept': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        setState(() {
          _people.removeWhere((person) => person['id'] == personId);
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to delete person';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error deleting person: $e';
      });
    }
  }

  // Function to edit a person (just an example - you can implement as needed)
void _editPerson(int personId) {
  // Find the person from the list by their personId
  final person = _people.firstWhere((person) => person['id'] == personId);

  // Navigate to the EditPersonScreen with the dynamic data
  Navigator.pushNamed(
    context,
    '/edit-person',
    arguments: {
      'personId': personId,  // Pass person ID
      'name': person['name'],  // Pass person's name
      'surname': person['surname'],  // Pass surname
      'southAfricanId': person['south_african_id'],  // Pass south african id
      'mobileNumber': person['mobile_number'],  // Pass mobile number
      'email': person['email'],  // Pass email
      'birthDate': person['birth_date'],  // Pass birth date
      'language': person['language'],  // Pass language
      'interests': person['interests'] is List ? person['interests'] : json.decode(person['interests']),  // Pass interests as list
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('People Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _isAuthenticated
              ? Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to add new person screen
                          Navigator.pushNamed(context, '/add-person');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue, // Button color
                          padding: EdgeInsets.symmetric(vertical: 14.0, horizontal: 32.0),
                          textStyle: TextStyle(fontSize: 18),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: Text('Add New Person'),
                      ),
                    ),
                    _people.isNotEmpty
                        ? Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Table(
                              border: TableBorder.all(
                                color: Colors.grey,
                                style: BorderStyle.solid,
                                width: 1,
                              ),
                              children: [
                                // Table header row
                                TableRow(
                                  children: [
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('ID'),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Name'),
                                    )),
                                    TableCell(child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text('Actions'),
                                    )),
                                  ],
                                ),
                                // Table data rows
                                for (var person in _people)
                                  TableRow(
                                    children: [
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(person['id'].toString()),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(person['name']),
                                      )),
                                      TableCell(child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(Icons.edit),
                                              onPressed: () => _editPerson(person['id']),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.delete),
                                              onPressed: () => _deletePerson(person['id']),
                                            ),
                                          ],
                                        ),
                                      )),
                                    ],
                                  ),
                              ],
                            ),
                          )
                        : Center(child: Text('No people found')),
                  ],
                )
              : Center(child: Text('Please log in to view data')),
    );
  }
}
