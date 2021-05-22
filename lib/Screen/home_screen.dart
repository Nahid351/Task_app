import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _taskController = TextEditingController();
  final Firestore _db = Firestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseUser user;

  @override
  void initState() {
    getUid();
    super.initState();
  }
  void getUid()async{
    FirebaseUser u = await _auth.currentUser();
    setState(() {
      user = u;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _showAddTaskDialog();
        },
        child: Icon(
          Icons.add,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.menu),
              onPressed: (){},
            ),
            IconButton(
              icon: Icon(Icons.person_outline),
              onPressed: (){},
            ),
          ],
        ),
      ),
      body: Container(
        child: StreamBuilder(
          stream: _db.collection('users').document(user.uid).collection('tasks').snapshots(),
          builder: (ctx,AsyncSnapshot<QuerySnapshot>snapshot){
            if(snapshot.hasData){
              return ListView(
                children: snapshot.data.documents.map((snap){
                  return ListTile(
                    title: Text(snap.data['task']),
                  );
                }).toList(),
              );
            }
            return Container(
              child: Center(
                child: Image(
                  image: AssetImage('assets/no_task.png'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  void _showAddTaskDialog(){
    showDialog(
        context: context,
        builder: (ctx){
          return SimpleDialog(
            title: Text('Add Task'),
            children: [
              Container(
                  margin: EdgeInsets.all(10.0),
                  child: TextField(
                    controller: _taskController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Write Your Task Here',
                      labelText: 'Task Name',
                    ),
                  )),
              Container(
                margin: EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    FlatButton(
                      child: Text('Cancel'),
                      onPressed: (){
                        Navigator.pop(context);
                      },
                    ),
                    RaisedButton(
                      color: Colors.blueAccent,
                      child: Text('Add',style: TextStyle(color: Colors.white)),
                      onPressed: () async{

                        String task = _taskController.text.trim();
                        // Remove this line
                        _db.collection('users').document(user.uid).collection('tasks').add({
                          'task':task,
                          'date':DateTime.now(),
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
          );
        }
    );
  }
}


