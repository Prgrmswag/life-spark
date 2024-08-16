import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:ls/home_screen.dart';
import 'package:pinput/pinput.dart';

class OtpScreen extends StatelessWidget {
  final String phoneval;
  final String emailVal;
  String verificationId;
  OtpScreen(
      {super.key,
      required this.verificationId,
      required this.phoneval,
      required this.emailVal});

  final TextEditingController otpCntr = TextEditingController();
  var code = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/otp.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              'OTP Verification',
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.w600),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 12),
              child: Text(
                'Otp has been sent successfully on $phoneval',
                style: const TextStyle(fontSize: 17),
              ),
            ),
            const SizedBox(height: 30),
            Pinput(
              onChanged: (value) {
                code = value;
              },
              length: 6,

              defaultPinTheme: PinTheme(
                width: 56,
                height: 56,
                textStyle: const TextStyle(
                  fontSize: 22,
                  color: Color.fromRGBO(30, 60, 87, 1),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(19),
                  border: Border.all(
                      color: Colors.black), 
                ),
              ),
            
            ),

          
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              height: 50,
              width: 150,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () async {
                  try {
                  
                    PhoneAuthCredential credential =
                        PhoneAuthProvider.credential(
                            verificationId: verificationId, smsCode: code);

                   
                    await FirebaseAuth.instance
                        .signInWithCredential(credential)
                        .then((value) async {
                      User? user = FirebaseAuth.instance.currentUser;
                      if (user != null) {
                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(user.uid)
                            .set({
                          'email': emailVal,
                          'uid': user.uid,
                          'phone': user.phoneNumber,
                        });

                       
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        );
                      } else {
                        print('User is null after sign-in.');
                      }
                    });
                  } catch (ex) {
                   
                    print('Error verifying OTP: $ex');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: Colors.red,
                        content: Text('Failed to verify OTP: $ex'),
                      ),
                    );
                  }
                },
                child: const Text(
                  'Verify OTP',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
