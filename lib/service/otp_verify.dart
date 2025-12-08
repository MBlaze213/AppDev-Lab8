import 'package:flutter/material.dart';
import '../navigation/home_page.dart';

class OTPVerificationScreen extends StatefulWidget {
  final String email;
  final String otp; // generated OTP

  const OTPVerificationScreen({super.key, required this.email, required this.otp});

  @override
  State<OTPVerificationScreen> createState() => _OTPVerificationScreenState();
}

class _OTPVerificationScreenState extends State<OTPVerificationScreen> {
  final otpController = TextEditingController();
  bool _isVerifying = false;

  void verifyOtp() async {
    setState(() => _isVerifying = true);
    if (otpController.text.trim() == widget.otp) {
      // OTP correct, navigate to home
      Navigator.pushReplacement(context, PageRouteBuilder(
        pageBuilder: (_, __, ___) => Playlist(), // your home page
        transitionsBuilder: (_, animation, __, child) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),
          child: child,
        ),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid OTP. Try again."),
          backgroundColor: Color(0xFFB76E79),
        ),
      );
    }
    setState(() => _isVerifying = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFD8C5),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text("Enter OTP", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: Color(0xFF4B2E2B))),
          const SizedBox(height: 20),
          TextField(
            controller: otpController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: "OTP sent to your email",
              filled: true,
              fillColor: const Color(0xFFF4E1D2),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isVerifying ? null : verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB284BE),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _isVerifying
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text("Verify OTP", style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
        ]),
      ),
    ),
  );
}
