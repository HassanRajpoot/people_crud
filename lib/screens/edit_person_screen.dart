import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EditPersonScreen extends StatefulWidget {
  @override
  _EditPersonScreenState createState() => _EditPersonScreenState();
}

class _EditPersonScreenState extends State<EditPersonScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _surnameController;
  late TextEditingController _southAfricanIdController;
  late TextEditingController _mobileNumberController;
  late TextEditingController _emailController;
  late TextEditingController _birthDateController;
  late TextEditingController _languageController;
  List<String> _interests = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _authToken;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Extract arguments passed from the previous screen in didChangeDependencies
    final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;

    // Initialize controllers with dynamic data
    _nameController = TextEditingController(text: arguments['name']);
    _surnameController = TextEditingController(text: arguments['surname']);
    _southAfricanIdController = TextEditingController(text: arguments['southAfricanId']);
    _mobileNumberController = TextEditingController(text: arguments['mobileNumber']);
    _emailController = TextEditingController(text: arguments['email']);
    _birthDateController = TextEditingController(text: arguments['birthDate']);
    _languageController = TextEditingController(text: arguments['language']);
    _interests = List<String>.from(arguments['interests']);  // Copy the interests list
  }

  // Function to handle person update
  Future<void> _updatePerson() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      _authToken = prefs.getString('auth_token');
      final arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final personId = arguments['personId'];

      final response = await http.put(
        Uri.parse('http://127.0.0.1:8000/api/person/$personId'),
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Origin': 'http://localhost:49902', // Match your Flutter app's origin
        },
        body: json.encode({
          'name': _nameController.text,
          'surname': _surnameController.text,
          'south_african_id': _southAfricanIdController.text,
          'mobile_number': _mobileNumberController.text,
          'email': _emailController.text,
          'birth_date': _birthDateController.text,
          'language': _languageController.text,
          'interests': _interests,
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to the home screen and replace current screen
      } else {
        setState(() {
          _isLoading = false;
          final errorResponse = json.decode(response.body);
          _errorMessage = _parseErrorResponse(errorResponse);
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  String _parseErrorResponse(Map<String, dynamic> errorResponse) {
    if (errorResponse.containsKey('errors')) {
      var errors = errorResponse['errors'];
      // Handle the error parsing as needed, example:
      if (errors is Map) {
        return errors.values.join(', ');
      }
    }
    return 'An unknown error occurred';
  }

  // Helper function to display error messages
  Widget _buildErrorMessage() {
    if (_errorMessage != null && _errorMessage!.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          _errorMessage!,
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
        ),
      );
    }
    return SizedBox.shrink(); // Return an empty widget if no error message
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Person')),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    _buildErrorMessage(),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _surnameController,
                      decoration: InputDecoration(labelText: 'Surname'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a surname';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _southAfricanIdController,
                      decoration: InputDecoration(labelText: 'South African ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a South African ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: InputDecoration(labelText: 'Mobile Number'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a mobile number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an email address';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _birthDateController,
                      decoration: InputDecoration(labelText: 'Birth Date'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a birth date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _languageController,
                      decoration: InputDecoration(labelText: 'Language'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a language';
                        }
                        return null;
                      },
                    ),
                    // Add additional widgets for handling interests if needed
                    ElevatedButton(
                      onPressed: _updatePerson,
                      child: Text('Update Person'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
