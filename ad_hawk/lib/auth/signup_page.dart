import 'package:flutter/material.dart';
import 'loginpage.dart';
import 'auth.dart';
import 'package:ad_hawk/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ad_hawk/homepage.dart';


class SignUpPage extends StatefulWidget{
  @override
  createState()=>SignUpPageState();
}


class SignUpPageState extends State<SignUpPage>{

  String userNickname ='';
  String userEmail ='';
  String userPassword ='';
  String itIsEmpty = 'it is empty';
  Auth auth = new Auth();

  void signUp()async{
    if(userEmail==null|| userPassword==null){
      // dont sign up
      print(itIsEmpty);
    }else{
      FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: userEmail,
          password: userPassword).then((UserCredential newUser){
            String userId = newUser.user.uid;
            FirebaseFirestore.instance.collection(Constants.USERS_COLLECTION)
            .doc(userId)
            .set({
              Constants.NICK_NAME: userNickname,
              Constants.USER_ID: userId,
              Constants.USER_IMAGE_THUMB:'',
              Constants. USER_IMAGE:''
            }).then((_){
              // navigate to home page
              Navigator.of(context).push(MaterialPageRoute(builder:(_)=>HomePage(newUser)));
              print(userId);
            }).catchError((e)=>print(e));
      });
    }

    }

    @override
   build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: ListView(
        children: <Widget>[
          SizedBox(height:100),

          Padding(
            padding:EdgeInsets.symmetric(
              horizontal: 50,vertical: 0
            ),
            child: Material(
              elevation: 2.0,
              borderRadius: BorderRadius.all(Radius.circular(30)),
              child: TextField(
                onChanged: (String nickname){
                  userNickname = nickname.toString()??'';
                },
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: 'Enter Nickname',
                  prefixIcon: Material(
                    elevation: 0,
//                    borderRadius: BorderRadius.all(Radius.circular(30)),
                    child: Icon(
                      Icons.account_circle,
                      color: Colors.green,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 25,vertical:13 )
                ),
              ),
            ),
          ),
          SizedBox(height: 20,),

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
                    print(userPassword);
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
                  // signup function
                  signUp();
            },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30)
                  )
              ),

              child: Text('Sign Up',),
              color: Colors.green,
            ),
          ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text('Already have an account?'),
              MaterialButton(child: Text('Sign in',
                style: TextStyle(
                    fontSize: 18,color: Colors.green
                )
              ),
                onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder: (_)=>LoginPage()));
                }
              )
            ],
          )
        ],
      )


    );
  }

}


