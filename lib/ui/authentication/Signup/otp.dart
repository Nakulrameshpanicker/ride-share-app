import 'package:flutter/material.dart';

class OTPVerificationPage extends StatefulWidget {
  final String mobileNumber;

  const OTPVerificationPage({Key? key, required this.mobileNumber})
      : super(key: key);

  @override
  _OTPVerificationPageState createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  final TextEditingController _otpController = TextEditingController();
  bool _otpError = false;

  void _verifyOTP() {
    // ignore: unused_local_variable
    String enteredOTP = _otpController.text.trim();
    // Here, you'll implement the logic to verify the entered OTP
    // against the OTP sent to the user's mobile number.
    // For demonstration purposes, let's assume OTP verification is successful.
    bool isOTPValid = true; // Replace this with actual OTP verification logic

    if (isOTPValid) {
      // If OTP verification is successful, navigate back to signup page
      Navigator.pop(
          context); // Navigate back to the previous page (signup page)
      // ignore: dead_code
    } else {
      // If OTP verification fails, display an error message to the user
      setState(() {
        _otpError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('OTP Verification'),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter OTP sent to ${widget.mobileNumber}',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            TextFormField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: 'Enter OTP',
                errorText: _otpError ? 'Incorrect OTP' : null,
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _verifyOTP,
              child: const Text('Verify OTP'),
            ),
          ],
        ),
      ),
    );
  }
}
