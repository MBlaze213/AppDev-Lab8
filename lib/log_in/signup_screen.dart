import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController();
  final username = TextEditingController();
  final password = TextEditingController();
  final otpController = TextEditingController();

  bool _isLoading = false;
  String generatedOtp = "";

  // Gmail SMTP credentials (App Password required)
  final String gmailUser = "markangelochiamente@gmail.com";
  final String gmailAppPassword = "vfqfmijgucfbvnwx"; // ⚠ App Password

  InputDecoration modernField(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Color(0xFF4B2E2B)),
    filled: true,
    fillColor: const Color(0xFFF4E1D2),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD8B4A6)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.8),
    ),
  );

  // 🔢 Generate 6-digit OTP
  String generateOtp() {
    return (100000 + Random().nextInt(900000)).toString();
  }

  // 📧 Send OTP to Gmail using SMTP
  Future<void> sendOtpEmail(String toEmail, String otp) async {
    final smtpServer = gmail(gmailUser, gmailAppPassword);

    final message = Message()
      ..from = Address(gmailUser, "Your App")
      ..recipients.add(toEmail)
      ..subject = "Your OTP Code"
      ..html =
          """
          <h2>Your OTP Code</h2>
          <p>Your verification code is:</p>
          <h1>$otp</h1>
          <p>This code expires in 5 minutes.</p>
        """;

    await send(message, smtpServer);
  }

  // 🔐 OTP Dialog - Styled to match Theme
  void showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFEFD8C5), // Matches Scaffold background
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: Color(0xFFD8B4A6), width: 2),
        ),
        title: const Center(
          child: Text(
            "Verification Code",
            style: TextStyle(
              color: Color(0xFF4B2E2B), // Dark Brown
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "We have sent a 6-digit code to your email. Please enter it below.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7A4C41), fontSize: 14),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF4B2E2B),
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
              // Reusing your modernField but tweaking it for OTP
              decoration: modernField("").copyWith(
                counterText: "", // Hides the 0/6 counter
                contentPadding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        actions: [
          Row(
            children: [
              // Cancel Button
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    setState(
                      () => _isLoading = false,
                    ); // Stop loading if needed
                  },
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      color: Color(0xFF7A4C41),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Verify Button
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (otpController.text.trim() == generatedOtp) {
                      Navigator.pop(context);
                      completeRegistration();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Invalid OTP"),
                          backgroundColor: Color(0xFFB76E79), // Dusty Rose
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB284BE), // Purple/Lilac
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Verify",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ✅ Create account after OTP verification
  Future<void> completeRegistration() async {
    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim(),
          );

      await FirebaseFirestore.instance
          .collection("users")
          .doc(userCredential.user!.uid)
          .set({
            "firstName": firstName.text.trim(),
            "lastName": lastName.text.trim(),
            "email": email.text.trim(),
            "username": username.text.trim(),
            "createdAt": FieldValue.serverTimestamp(),
          });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  // 🟣 Signup button logic
  Future<void> registerUser() async {
    if (firstName.text.trim().isEmpty ||
        lastName.text.trim().isEmpty ||
        email.text.trim().isEmpty ||
        username.text.trim().isEmpty ||
        password.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("All fields are required")));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final existing = await FirebaseFirestore.instance
          .collection("users")
          .where("username", isEqualTo: username.text.trim())
          .get();

      if (existing.docs.isNotEmpty) {
        throw "Username already taken";
      }

      // Generate OTP
      generatedOtp = generateOtp();

      // Send OTP to Gmail
      await sendOtpEmail(email.text.trim(), generatedOtp);

      // Show OTP popup
      showOtpDialog();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFD8C5),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Create Account",
                style: TextStyle(
                  color: Color(0xFF4B2E2B),
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                "Join us today",
                style: TextStyle(color: Color(0xFF7A4C41), fontSize: 16),
              ),
              const SizedBox(height: 30),
              TextField(
                controller: firstName,
                decoration: modernField("First Name"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: lastName,
                decoration: modernField("Last Name"),
              ),
              const SizedBox(height: 16),
              TextField(controller: email, decoration: modernField("Email")),
              const SizedBox(height: 16),
              TextField(
                controller: username,
                decoration: modernField("Username"),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: password,
                obscureText: true,
                decoration: modernField("Password"),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : registerUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB284BE),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        )
                      : const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account? ",
                    style: TextStyle(color: Color(0xFF7A4C41)),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    ),
                    child: const Text(
                      "Login",
                      style: TextStyle(
                        color: Color(0xFF4B2E2E),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
