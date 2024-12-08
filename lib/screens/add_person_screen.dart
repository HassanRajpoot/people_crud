import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AddPersonScreen extends StatefulWidget {
  @override
  _AddPersonScreenState createState() => _AddPersonScreenState();
}

class _AddPersonScreenState extends State<AddPersonScreen> {
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
    _nameController = TextEditingController();
    _surnameController = TextEditingController();
    _southAfricanIdController = TextEditingController();
    _mobileNumberController = TextEditingController();
    _emailController = TextEditingController();
    _birthDateController = TextEditingController();
    _languageController = TextEditingController();
  }

  // Function to handle adding a new person
  Future<void> _addPerson() async {
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

      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/api/person'), // API endpoint to create a new person
        headers: {
          'Authorization': 'Bearer $_authToken',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
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

      if (response.statusCode == 201) {
        Navigator.pushReplacementNamed(context, '/home'); // Navigate to the home screen after success
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
      return errors.toString();
    }
    return 'Something went wrong';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add New Person')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: _isLoading
            ? Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the name';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _surnameController,
                      decoration: InputDecoration(labelText: 'Surname'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the surname';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _southAfricanIdController,
                      decoration: InputDecoration(labelText: 'South African ID'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the South African ID';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _mobileNumberController,
                      decoration: InputDecoration(labelText: 'Mobile Number'),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the mobile number';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the email';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _birthDateController,
                      decoration: InputDecoration(labelText: 'Birth Date'),
                      keyboardType: TextInputType.datetime,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the birth date';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _languageController,
                      decoration: InputDecoration(labelText: 'Language'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter the language';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _addPerson,
                      child: Text('Save Person'),
                    ),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}
