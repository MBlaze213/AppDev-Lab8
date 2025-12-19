import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import '../navigation/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final usernameOrEmail = TextEditingController();
  final password = TextEditingController();
  final otpController = TextEditingController();

  bool _isLoading = false;
  bool _isGoogleLoading = false;

  String generatedOtp = "";
  String loginEmail = "";

  // 🔐 Gmail SMTP (APP PASSWORD)
  final String gmailUser = "markangelochiamente@gmail.com";
  final String gmailAppPassword = "vfqfmijgucfbvnwx"; // ⚠ DO NOT PUSH TO GITHUB

  // 🎨 Input style
  InputDecoration modernField(String label, {String? hint}) => InputDecoration(
    labelText: label,
    hintText: hint,
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

  // 🔢 Generate OTP
  String generateOtp() => (100000 + Random().nextInt(900000)).toString();

  // 📧 Send OTP Email
  Future<void> sendOtpEmail(String toEmail, String otp) async {
    final smtpServer = gmail(gmailUser, gmailAppPassword);

    final message = Message()
      ..from = Address(gmailUser, "KawaiiBeats")
      ..recipients.add(toEmail)
      ..subject = "Login OTP Verification"
      ..html =
          """
        <h2>Login Verification Code</h2>
        <p>Your OTP is:</p>
        <h1>$otp</h1>
        <p>This code expires in 5 minutes.</p>
      """;

    await send(message, smtpServer);
  }

  // 📩 Send Login Success Notification
  Future<void> sendLoginSuccessEmail(String toEmail) async {
    final smtpServer = gmail(gmailUser, gmailAppPassword);

    final message = Message()
      ..from = Address(gmailUser, "KawaiiBeats Security")
      ..recipients.add(toEmail)
      ..subject = "Login Successful"
      ..html =
          """
        <h2>Login Alert</h2>
        <p>Your account was successfully logged in.</p>
        <p><b>Date & Time:</b> ${DateTime.now()}</p>
        <p>If this wasn’t you, please reset your password immediately.</p>
      """;

    await send(message, smtpServer);
  }

  // 🔐 OTP Dialog
  void showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFEFD8C5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            "OTP Verification",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4B2E2B),
            ),
          ),
        ),
        content: TextField(
          controller: otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: Color(0xFF4B2E2B),
          ),
          decoration: const InputDecoration(counterText: ""),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isLoading = false);
            },
            child: const Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF7A4C41)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (otpController.text.trim() == generatedOtp) {
                otpController.clear();
                Navigator.pop(context);

                // 📩 SEND LOGIN SUCCESS EMAIL
                await sendLoginSuccessEmail(loginEmail);

                _snackSuccess("Login successful!");

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Playlist()),
                );
              } else {
                _snack("Invalid OTP");
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB284BE),
            ),
            child: const Text("Verify"),
          ),
        ],
      ),
    );
  }

  // 🔹 LOGIN USING USERNAME OR EMAIL
  Future<void> loginUser() async {
    final input = usernameOrEmail.text.trim();
    final pwd = password.text.trim();

    if (input.isEmpty || pwd.isEmpty) {
      _snack("Please fill in all fields");
      return;
    }

    setState(() => _isLoading = true);

    try {
      String email;

      if (input.contains("@")) {
        email = input;
      } else {
        final query = await FirebaseFirestore.instance
            .collection("users")
            .where("username", isEqualTo: input)
            .limit(1)
            .get();

        if (query.docs.isEmpty) throw "Username not found";
        email = query.docs.first["email"];
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pwd,
      );

      loginEmail = email;
      generatedOtp = generateOtp();

      await sendOtpEmail(loginEmail, generatedOtp);
      showOtpDialog();
    } catch (e) {
      _snack(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // 🔵 GOOGLE SIGN-IN
  Future<void> signInWithGoogle() async {
    setState(() => _isGoogleLoading = true);
    try {
      final gUser = await GoogleSignIn().signIn();
      if (gUser == null) return;

      final gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      final email = FirebaseAuth.instance.currentUser?.email;
      if (email != null) {
        await sendLoginSuccessEmail(email);
      }

      _snackSuccess("Login successful!");

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => Playlist()),
      );
    } finally {
      setState(() => _isGoogleLoading = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFFB76E79)),
    );
  }

  void _snackSuccess(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF6A9C89)),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFD8C5),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              "Log In",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B2E2B),
              ),
            ),
            const SizedBox(height: 30),
            TextField(
              controller: usernameOrEmail,
              decoration: modernField(
                "Username or Email (Gmail)",
                hint: "example@gmail.com",
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: password,
              obscureText: true,
              decoration: modernField("Password"),
            ),
            const SizedBox(height: 28),

            // Login button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB284BE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Login",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Create Account button (prominent)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFB76E79), width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFFF4E1D2),
                ),
                child: const Text(
                  "Create an Account",
                  style: TextStyle(
                    color: Color(0xFF4B2E2B),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Center(
              child: Text("— or —", style: TextStyle(color: Color(0xFF7A4C41))),
            ),
            const SizedBox(height: 20),

            // Google sign-in button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isGoogleLoading ? null : signInWithGoogle,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFFB76E79), width: 1.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: const Color(0xFFF4E1D2),
                ),
                child: _isGoogleLoading
                    ? const CircularProgressIndicator()
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.network(
                            "https://img.icons8.com/color/48/google-logo.png",
                            height: 22,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            "Sign in with Gmail",
                            style: TextStyle(
                              color: Color(0xFF4B2E2B),
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ),
  );
}
