import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ad_hawk/homepage.dart';


class LoginPage extends StatefulWidget{
  createState()=> LoginPageState();
}


class LoginPageState extends State<LoginPage>{

  String userEmail = '';
  String userPassword = '';
  User user;

  void signIn(){
    if(userEmail == null || userPassword ==null){
      // dont sign in
    }else {
      FirebaseAuth.instance.signInWithEmailAndPassword(
          email: userEmail,
          password: userPassword
      ).then((UserCredential newUser){
        Navigator.of(context).push(MaterialPageRoute(builder:(_)=>HomePage(newUser)));
        print('Signed in as user; ${newUser.user.uid}');
      }).catchError((e)=>print('error is $e'));
    }

  }
  build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: ListView(
        children: <Widget>[
          SizedBox(height: 100,),
          Padding(
              padding:EdgeInsets.symmetric(horizontal: 50),
              child:Material(
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: TextField(
                  onChanged: (String email){
                    userEmail = email.toString()??'';
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      hintText: 'Enter Email',
                      prefixIcon: Material(
                        elevation: 0,
//                    borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Icon(
                          Icons.email,
                          color: Colors.green,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 25,vertical:13 )
                  ),
                ),
              )
          ),

          SizedBox(height: 20,),
          Padding(
              padding:EdgeInsets.symmetric(horizontal: 50),

              child:Material(
                elevation: 2.0,
                borderRadius: BorderRadius.all(Radius.circular(30)),
                child: TextField(
                  onChanged: (String password){
                    userPassword = password.toString()??'';
                  },
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                      hintText: 'Enter Password',
                      prefixIcon: Material(
                        elevation: 0,
//                    borderRadius: BorderRadius.all(Radius.circular(30)),
                        child: Icon(
                          Icons.lock,
                          color: Colors.green,
                        ),
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 25,vertical:13 )
                  ),
                ),
              )
          ),
          SizedBox(height: 20,),

          Padding(padding: EdgeInsets.symmetric(horizontal: 100),
            child: Material(
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: RaisedButton(
                onPressed: (){
                  // signIn function
                  signIn();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(30)
                    )
                ),

                child: Text('Sign In',),
                color: Colors.green,
              ),
            ),
          ),


        ],
      )
    );
  }
}