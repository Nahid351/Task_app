import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final Firestore _db = Firestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child:Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent,
                      blurRadius: 30,
                      offset: Offset(10, 10),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                margin: EdgeInsets.only(top: 50.0),
                child: Image(
                  image: AssetImage('assets/logo_round.png'),
                  height: 130.0,width: 130.0,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 30.0),
                child: Text(
                  'Register',
                  style: TextStyle(fontSize: 30.0),
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                margin: EdgeInsets.only(top: 20.0),
                child: TextField(
                  controller:_emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Email',
                    hintText: 'Write Email Here',
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
              ),
              Container(
                padding: EdgeInsets.all(20.0),
                child: TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Password',
                    hintText: 'Write Password Here',
                  ),
                  obscureText: true,
                ),
              ),
              InkWell(
                onTap: (){
                  _signUp();
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
                      'Register',
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
  void _signUp()async{
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    if(email.isNotEmpty && password.isNotEmpty){
      _auth.createUserWithEmailAndPassword(email: email, password: password)
          .then((user){
        _db.collection('users').document(user.user.uid).setData({
          'email': email,
          'lastSeen':DateTime.now(),
          'sign_in_method':user.user.providerId,
        });
        showDialog(
          context: context,
          builder: (ctx){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text('Done'),
              content: Text('Sign in Success'),
              actions: [
                FlatButton(
                  child: Text('Ok'),
                  onPressed: (){
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      }).catchError((e){
        showDialog(
          context: context,
          builder: (ctx){
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              title: Text('Error'),
              content: Text(e),
              actions: [
                FlatButton(
                  child: Text('Cancel'),
                  onPressed: (){
                    Navigator.of(ctx).pop();
                  },
                ),
              ],
            );
          },
        );
      });
    }else{
      showDialog(
        context: context,
        builder: (ctx){
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            title: Text('Error'),
            content: Text('Provide email and password'),
            actions: [
              FlatButton(
                child: Text('Cancel'),
                onPressed: (){
                  Navigator.of(ctx).pop();
                },
              ),
              FlatButton(
                child: Text('Ok'),
                onPressed: (){
                  _emailController.text ='';
                  _passwordController.text ='';
                  Navigator.of(ctx).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }
}
