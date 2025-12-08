import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final firstName = TextEditingController(), lastName = TextEditingController(),
      email = TextEditingController(), username = TextEditingController(),
      password = TextEditingController();
  bool _isLoading = false;

  InputDecoration modernField(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Color(0xFF4B2E2B)),
    filled: true, fillColor: const Color(0xFFF4E1D2),
    enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD8B4A6))),
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.8)),
  );

  Future<void> registerUser() async {
    if (username.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Username is required"), backgroundColor: Color(0xFFB76E79)));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final existing = await FirebaseFirestore.instance.collection("users")
          .where("username", isEqualTo: username.text.trim()).get();
      if (existing.docs.isNotEmpty) throw "Username already taken!";
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text.trim(), password: password.text.trim());
      final uid = userCredential.user!.uid;
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        "firstName": firstName.text.trim(), "lastName": lastName.text.trim(),
        "email": email.text.trim(), "username": username.text.trim(),
        "password": password.text.trim(), "createdAt": FieldValue.serverTimestamp(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account Created!"), backgroundColor: Color(0xFFB76E79)));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Color(0xFFB76E79)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFD8C5), // muted pastel cream
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Create Account",
                style: TextStyle(color: Color(0xFF4B2E2B), fontSize: 34, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            const Text("Join us today",
                style: TextStyle(color: Color(0xFF7A4C41), fontSize: 16)),
            const SizedBox(height: 30),
            TextField(controller: firstName, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("First Name")),
            const SizedBox(height: 16),
            TextField(controller: lastName, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Last Name")),
            const SizedBox(height: 16),
            TextField(controller: email, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Email")),
            const SizedBox(height: 16),
            TextField(controller: username, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Username")),
            const SizedBox(height: 16),
            TextField(controller: password, obscureText: true, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Password")),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : registerUser,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB284BE),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Colors.white))
                    : const Text("Create Account", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 16),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Text("Already have an account? ", style: TextStyle(color: Color(0xFF7A4C41))),
              GestureDetector(
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())),
                child: const Text("Login", style: TextStyle(color: Color(0xFF4B2E2E), fontWeight: FontWeight.bold)),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}
