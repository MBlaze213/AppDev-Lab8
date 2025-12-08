import 'dart:math';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class OTPService {
  // Generate a 6-digit OTP
  static String generateOtp() {
    final random = Random();
    return (100000 + random.nextInt(900000)).toString();
  }

  static Future<String> sendOtpToEmail(String email) async {
    try {
      final otp = generateOtp();

      // YOUR GMAIL LOGIN
      final smtpServer = gmail(
        "markangelochiamente@gmail.com",        
        "vfqf mijg ucfb vnwx", 
      );

      final message = Message()
        ..from = const Address("yourEmail@gmail.com", "Kawaii Beats App")
        ..recipients.add(email)
        ..subject = "Your OTP Code"
        ..html = """
          <h2>Your OTP Code</h2>
          <p>Your verification code is:</p>
          <h1>$otp</h1>
          <p>This code expires in 5 minutes.</p>
        """;

      await send(message, smtpServer);
      return otp;
    } catch (e) {
      print("OTP send error: $e");
      return "";
    }
  }
}
