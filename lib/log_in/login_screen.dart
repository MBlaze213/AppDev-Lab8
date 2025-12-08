import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'signup_screen.dart';
import '../navigation/home_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../service/otp_services.dart';
import '../service/otp_verify.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final username = TextEditingController(), password = TextEditingController();
  bool _isLoading = false, _isGoogleLoading = false;

  Future<void> loginUser() async {
    setState(() => _isLoading = true);
    try {
      final unameDoc = await FirebaseFirestore.instance.collection("users")
          .where("username", isEqualTo: username.text.trim()).limit(1).get();
      if (unameDoc.docs.isEmpty) throw "Username not found";
      final uid = unameDoc.docs.first.id;
      final userDoc = await _retryFirestoreFetch(uid);
      final email = userDoc["email"];
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password.text.trim());
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Login Successful!"), backgroundColor: Color(0xFFB76E79)));
      Navigator.pushReplacement(context, _slideRoute(Playlist()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed: Check your internet connection."), backgroundColor: const Color(0xFFB76E79)));
    } finally { if (mounted) setState(() => _isLoading = false); }
  }

  Future<DocumentSnapshot> _retryFirestoreFetch(String uid) async {
    int retries = 3;
    while (retries > 0) {
      try { return await FirebaseFirestore.instance.collection("users").doc(uid).get(); }
      catch (e) {
        if (e.toString().contains("unavailable") && retries > 1) { await Future.delayed(const Duration(seconds: 2)); retries--; continue; }
        rethrow;
      }
    }
    throw Exception("Failed to fetch user document after retries");
  }

Future<void> signInWithGoogle() async {
  setState(() => _isGoogleLoading = true);
  try {
    await GoogleSignIn().signOut();
    final gUser = await GoogleSignIn().signIn();
    if (gUser == null) return;
    final gAuth = await gUser.authentication;
    final credential = GoogleAuthProvider.credential(accessToken: gAuth.accessToken,idToken: gAuth.idToken,
    );
    final userCred = await FirebaseAuth.instance.signInWithCredential(credential);
    final uid = userCred.user!.uid;
    final userDoc = FirebaseFirestore.instance.collection("users").doc(uid);
    final doc = await userDoc.get();
    if (!doc.exists) {
      await userDoc.set({
        "fullName": gUser.displayName ?? "",
        "email": gUser.email,
        "username": gUser.email.split("@")[0],
        "createdAt": FieldValue.serverTimestamp(),
      });
    }
    final otp = await OTPService.sendOtpToEmail(gUser.email);
    if (otp.isEmpty) {ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to send OTP. Check your internet."),backgroundColor: Color(0xFFB76E79),),
      ); return;
    }
    Navigator.push(context, PageRouteBuilder(pageBuilder: (_, __, ___) => OTPVerificationScreen(email: gUser.email, otp: otp),
        transitionsBuilder: (_, animation, __, child) =>
            SlideTransition(position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero).animate(animation),child: child,),),);
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar( content: Text("Google Sign-In failed: $e\nCheck your internet connection."), backgroundColor: const Color(0xFFB76E79),),);
  } finally { if (mounted) setState(() => _isGoogleLoading = false);}
}

  InputDecoration modernField(String label) => InputDecoration(
    labelText: label, labelStyle: const TextStyle(color: Color(0xFF4B2E2B)),
    filled: true, fillColor: const Color(0xFFF4E1D2),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFD8B4A6))),
    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFB76E79), width: 1.8)),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFFEFD8C5),
    body: Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Log In", style: TextStyle(color: Color(0xFF4B2E2B), fontSize: 34, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text("Welcome back", style: TextStyle(color: Color(0xFF7A4C41), fontSize: 16)),
          const SizedBox(height: 30),
          TextField(controller: username, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Username")),
          const SizedBox(height: 16),
          TextField(controller: password, obscureText: true, style: const TextStyle(color: Color(0xFF4B2E2B)), decoration: modernField("Password")),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : loginUser,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB284BE), padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _isLoading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Login", style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 20),
          Center(child: GestureDetector(onTap: () => Navigator.push(context, _slideRoute(const SignUpScreen())), child: const Text("Create an Account", style: TextStyle(color: Color(0xFF4B2E2E), fontSize: 15, fontWeight: FontWeight.w500)))),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isGoogleLoading ? null : signInWithGoogle,
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), side: const BorderSide(color: Color(0xFFB76E79), width: 1.4), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), backgroundColor: const Color(0xFFF4E1D2)),
              child: _isGoogleLoading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Color(0xFF4B2E2B), strokeWidth: 2))
                  : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Image.network("https://img.icons8.com/color/48/google-logo.png", height: 22),
                      const SizedBox(width: 10),
                      const Text("Sign in with Google", style: TextStyle(color: Color(0xFF4B2E2B), fontSize: 16, fontWeight: FontWeight.w600)),
                    ]),
            ),
          ),
        ]),
      ),
    ),
  );
}

Route _slideRoute(Widget page) => PageRouteBuilder(
  transitionDuration: const Duration(milliseconds: 280),
  pageBuilder: (_, animation, __) => SlideTransition(position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuad)), child: page),
);