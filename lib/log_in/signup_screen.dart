import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Controllers for text fields
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final email = TextEditingController(); // Renamed from 'username' for clarity
  final password = TextEditingController();

  // Loading state for the button
  bool _isLoading = false;

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    firstName.dispose();
    lastName.dispose();
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> registerUser() async {
    // Set loading state
    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Create Firebase Auth Account
      UserCredential user = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.text.trim(),
            password: password.text.trim(),
          );

      // 2. Save user data in Firestore (NO PASSWORD!)
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.user!.uid)
          .set({
            "id": user.user!.uid,
            "firstName": firstName.text.trim(),
            "lastName": lastName.text.trim(),
            "email": email.text.trim(), // Use 'email' key
            "createdAt": FieldValue.serverTimestamp(),
          });

      // Check if the widget is still mounted before using context
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Account Created Successfully!")),
      );
      Navigator.pop(context); // Go back to the previous screen
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase auth errors
      String message;
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists for that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = 'An error occurred. Please try again.';
      }

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      // Handle other generic errors
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      // Always stop loading, whether success or error
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: firstName,
                decoration: const InputDecoration(labelText: "First Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lastName,
                decoration: const InputDecoration(labelText: "Last Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: email,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: password,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : registerUser, // Disable button when loading
                child: _isLoading
                    ? const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
