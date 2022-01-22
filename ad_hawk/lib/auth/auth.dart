import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';


class Auth {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String userEmail = '';
  String userPassword = '';
  String userNickname = '';

  Future<User> handleSignInEmailAndPassword(String email, String password)async{
     UserCredential userCredential= await firebaseAuth.signInWithEmailAndPassword(
        email:userEmail?? '' ,
        password: userPassword?? '',);

    final User user = userCredential.user;

    await Future.delayed(Duration(milliseconds: 50));

    assert (user!=null);
    assert (await user.getIdToken()!=null);

    final User currentUser = await firebaseAuth.currentUser;
    assert (user.uid == currentUser.uid);
    print('signInEmail succedded: ${user.uid}');

    return user;

  }

  // ignore: missing_return
  Future<User> handleSignUpEmailAndPassword(String email, String password)async{

    UserCredential userCredential = await firebaseAuth.createUserWithEmailAndPassword(
        email: userEmail??'' ,
        password: userPassword??'',
    );



    final User user = userCredential.user;
    await Future.delayed(Duration(milliseconds: 50));

    assert (user !=null);
    assert (await user.getIdToken()!=null);
    print ('signUpEmail succedded: ${user.uid}');
    return userCredential.user;
  }



}