import 'dart:developer';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:weatherapp/src/core/textfield.dart';
import 'package:weatherapp/src/views/weather/weather_view.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key, required this.verificationId});
  final String verificationId;
  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  TextEditingController otpController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;
  // String verificationId = "";
  @override
  Widget build(BuildContext context) {
    final kSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: .5,
        shadowColor: Colors.black,
        backgroundColor: Colors.white,
      ),
      resizeToAvoidBottomInset: false,
      body: SizedBox(
        height: kSize.height,
        width: kSize.width,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                height: 40,
              ),
              const Text(
                "Enter OTP",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w600),
              ),
              const SizedBox(
                height: 15,
              ),
              const Text(
                "Please enter your mobile number\nto verify your account",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
              const SizedBox(
                height: 40,
              ),
              CustomTextField(controller: otpController, hintText: "Enter OTP"),
              const Spacer(),
              SizedBox(
                height: kSize.height * .08,
                width: kSize.width,
                child: TextButton(
                    style: TextButton.styleFrom(
                        backgroundColor: Colors.orange.shade400,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5))),
                    onPressed: () {
                      signInWithOTP();
                    },
                    child: const Text(
                      "Continue",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    )),
              ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void signInWithOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: widget.verificationId,
      smsCode: otpController.text,
    );
    log(otpController.text);
    log(widget.verificationId);
    try {
      await FirebaseAuth.instance.signInWithCredential(credential);
      _navigateToHomeScreen();
    } catch (e) {
      print('Failed to sign in: $e');
    }
  }

  void _navigateToHomeScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const WeatherView(),
      ),
    );
  }
}
