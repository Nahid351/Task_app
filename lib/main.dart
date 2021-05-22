import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:task_app/screen/home_screen.dart';
import 'package:task_app/screen/login_screen.dart';

void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Strembuilder is Used when event is change
      body: StreamBuilder(
        stream: _auth.onAuthStateChanged,
        // use to firebase user retrive
        builder: (ctx, AsyncSnapshot<FirebaseUser> snapshot){
          if(snapshot.hasData){
            FirebaseUser user = snapshot.data;
            if(user !=null){
              return HomeScreen();
            }else{
              return LoginScreen();
            }
          }
          return LoginScreen();
        },
      ),
    );
  }
}

