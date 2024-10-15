import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _emailError = false;
  bool _mobileError = false;
  bool _passwordMatchError = false;
  // ignore: unused_field
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signup() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String mobile = _mobileController.text.trim(); // Remove Indian format
    String address = _addressController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        mobile.isEmpty ||
        address.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All fields are mandatory')),
      );
      return;
    }

    if (!_isValidEmail(email)) {
      setState(() {
        _emailError = true;
      });
      return;
    }

    if (!_isValidMobile(mobile)) {
      setState(() {
        _mobileError = true;
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        _passwordMatchError = true;
      });
      return;
    }

    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _storeUserDetails(name, email, mobile, address);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration successful')),
      );

      // Navigate back to the login page
      Navigator.pop(
          context); // This line will navigate back to the previous page (login page)
    } catch (e) {
      print("Registration failed: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Registration failed: $e'),
        ),
      );
    }
  }

  Future<void> _storeUserDetails(
      String name, String email, String mobile, String address) async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance
            .collection('user_details')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'name': name,
          'email': email,
          'mobile': mobile,
          'address': address,
        });
      }
    } catch (e) {
      print("Error storing user details: $e");
    }
  }

  bool _isValidEmail(String email) {
    String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    RegExp regex = RegExp(emailRegex);
    return regex.hasMatch(email);
  }

  bool _isValidMobile(String mobile) {
    return mobile.length == 10 && int.tryParse(mobile) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sign Up',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildInputField(_nameController, 'Name', true),
              const SizedBox(height: 16.0),
              _buildInputField(_emailController, 'Email', true,
                  error: _emailError ? 'Invalid email format' : null),
              const SizedBox(height: 16.0),
              _buildInputField(_mobileController, 'Mobile Number', true,
                  error: _mobileError ? 'Invalid mobile number' : null),
              const SizedBox(height: 16.0),
              _buildInputField(_addressController, 'Address', true),
              const SizedBox(height: 16.0),
              _buildInputField(_passwordController, 'Password', true,
                  isPassword: true),
              const SizedBox(height: 16.0),
              _buildInputField(
                  _confirmPasswordController, 'Confirm Password', true,
                  isPassword: true,
                  error: _passwordMatchError ? 'Passwords do not match' : null),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _signup,
                child: const Text('Sign Up'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
      TextEditingController controller, String labelText, bool mandatory,
      {String? error, bool isPassword = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              labelText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (mandatory)
              const Text(
                ' *',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8.0),
        Container(
          color: Colors.white.withOpacity(0.7),
          child: TextFormField(
            controller: controller,
            onChanged: (_) {
              setState(() {
                if (labelText == 'Email') {
                  _emailError = !_isValidEmail(controller.text.trim());
                } else if (labelText == 'Mobile Number') {
                  _mobileError = !_isValidMobile(controller.text.trim());
                } else if (labelText == 'Confirm Password') {
                  _passwordMatchError =
                      controller.text.trim() != _passwordController.text.trim();
                }
              });
            },
            obscureText: isPassword,
            decoration: InputDecoration(
              border: const OutlineInputBorder(),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
              errorText: error,
            ),
          ),
        ),
        if (controller.text.isEmpty && mandatory)
          const Text(
            'Field is mandatory',
            style: TextStyle(
              color: Colors.red,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }
}
