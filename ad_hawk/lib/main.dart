import 'package:flutter/material.dart';
import 'auth/signup_page.dart';
import 'package:firebase_core/firebase_core.dart';


void main()async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  build(BuildContext context ){

    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.green
      ),
      home: SignUpPage(),
      debugShowCheckedModeBanner: false,

    );

  }
  }

