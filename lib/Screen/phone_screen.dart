import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';

class PhoneScreen extends StatefulWidget {
  @override
  _PhoneScreenState createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  PhoneNumber _phoneNumber;
  String _message;
  String _verificationId;

  bool _isSMSSent = false;
  FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  final TextEditingController _smsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Phone Sign In'),
      ),
      body: SingleChildScrollView(
        child: AnimatedContainer(
          duration: Duration(milliseconds: 500),
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.0,vertical: 10.0),
                child: InternationalPhoneNumberInput(
                  onInputChanged: (phoneNumberTxt){
                    _phoneNumber = phoneNumberTxt;
                  },
                  inputBorder: OutlineInputBorder(),
                ),
              ),
              _isSMSSent?Container(
                margin: EdgeInsets.all(10.0),
                child: TextField(
                  controller: _smsController,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'OTP Here',
                      labelText: 'OTP'
                  ),
                  maxLength: 6,
                  keyboardType: TextInputType.number,
                ),
              ):Container(),
              !_isSMSSent ?InkWell(
                onTap: (){
                  setState(() {
                    _isSMSSent = true;
                  });
                  _verifyPhoneNumber();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent, Colors.lightGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
                  margin: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
                  child: Center(
                    child: Text(
                      'Send OTP',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ):InkWell(
                onTap: (){
                  _signInWithPhoneNumber();
                },
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.greenAccent, Colors.lightGreen,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
                  margin: EdgeInsets.symmetric(horizontal: 30.0,vertical: 20.0),
                  child: Center(

                      child: Text(
                        'Verify OTP',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ),

            ],
          ),
        ),
      ),
    );
  }
  void _verifyPhoneNumber() async {
    setState(() {
      _message = '';
    });

    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      _auth.signInWithCredential(phoneAuthCredential);
      setState(() {
        _message = 'Received phone auth credential: $phoneAuthCredential';
      });
    };

    final PhoneVerificationFailed verificationFailed =
        (AuthException authException) {
      setState(() {
        _message =
        'Phone number verification failed. Code: ${authException.code}. Message: ${authException.message}';
      });
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int forceResendingToken]) async {
      _verificationId = verificationId;
    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      _verificationId = verificationId;
    };

    await _auth.verifyPhoneNumber(
        phoneNumber: _phoneNumber.phoneNumber,
        timeout: const Duration(seconds: 120),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  // Example code of how to sign in with phone.
  void _signInWithPhoneNumber() async {
    final AuthCredential credential = PhoneAuthProvider.getCredential(
      verificationId: _verificationId,
      smsCode: _smsController.text,
    );
    final FirebaseUser user =
        (await _auth.signInWithCredential(credential)).user;
    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    setState(() {
      if (user != null) {
        _db.collection('users').document(user.uid).setData({
          'phoneNumber': user.phoneNumber,
          'lastSeen':DateTime.now(),
          'sign_in_method':user.providerId,
        });
        _message = 'Successfully signed in, uid: ' + user.uid;
        print(_message);
      } else {
        _message = 'Sign in failed';
      }
    });
  }
}
