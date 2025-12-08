import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import '../navigation/home_page.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController(), password = TextEditingController();
  bool _isLoading = false;

  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    try {
      final unameDoc = await FirebaseFirestore.instance.collection("users")
          .where("username", isEqualTo: username.text.trim()).limit(1).get();
      if (unameDoc.docs.isEmpty) throw "Username not found";
      final uid = unameDoc.docs.first.id;
      final userDoc = await FirebaseFirestore.instance.collection("users").doc(uid).get();
      final email = userDoc["email"];
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email, password: password.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Login Successful!"), backgroundColor: Color(0xFFB76E79))
      );
      Navigator.pushReplacement(context, _slideRoute(Playlist()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Color(0xFFB76E79))
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  InputDecoration modernField(String label) => InputDecoration(
    labelText: label, 
    labelStyle: const TextStyle(color: Color(0xFF4B2E2B)),
    filled: true, 
    fillColor: const Color(0xFFF4E1D2), // slightly darker pastel cream
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD8B4A6))
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.8)
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFD8C5), // muted pastel cream
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Log In",
                style: TextStyle(color: Color(0xFF4B2E2B), fontSize: 34, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("Welcome back",
                style: TextStyle(color: Color(0xFF7A4C41), fontSize: 16)),
            const SizedBox(height: 30),
            TextField(controller: username, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Username")),
            const SizedBox(height: 16),
            TextField(controller: password, obscureText: true, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Password")),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : loginUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB284BE), // caramel pink button
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () => Navigator.push(context, _slideRoute(const SignUpScreen())),
                child: const Text("Create an Account", style: TextStyle(color: Color(0xFF4B2E2E), fontSize: 15, fontWeight: FontWeight.w500)),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

Route _slideRoute(Widget page) => PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (_, animation, __) => SlideTransition(
    position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero)
        .animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuad)),
    child: page,
  ),
);
