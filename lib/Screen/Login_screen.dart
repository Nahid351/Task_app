import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:task_app/Screen/phone_screen.dart';
import 'package:task_app/Screen/register_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn=GoogleSignIn();
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
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
                'Login',
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
                _signIn();
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
                    'Login With Email',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
            FlatButton(
              onPressed: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterScreen()));
              },
              child: Text('Signup using Email'),
            ),
            Wrap(
              children: [
                FlatButton.icon(
                  onPressed: (){
                    _signInUsingGoogle();
                  },
                  icon: Icon(FontAwesomeIcons.google,color: Colors.red),
                  label: Text(
                    'Signup Using Gmail',style: TextStyle(color: Colors.red),
                  ),
                ),
                FlatButton.icon(
                  onPressed: (){
                    Navigator.pushReplacement(context, MaterialPageRoute(builder:(context)=>PhoneScreen()));
                  },
                  icon: Icon(FontAwesomeIcons.phone,color: Colors.blue),
                  label: Text(
                    'Signup Using Phone',style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _signIn()async{
    String email = _emailController.text.trim();
    String password = _passwordController.text;
    if(email.isNotEmpty && password.isNotEmpty){
      _auth.signInWithEmailAndPassword(email: email, password: password)
          .then((user){
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
  void  _signInUsingGoogle()async{
      try{
        final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        final AuthCredential credential = GoogleAuthProvider.getCredential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
        print("signed in " + user.displayName);


      }catch(e){
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



      }

  }
}
