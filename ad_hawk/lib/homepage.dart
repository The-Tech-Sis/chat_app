import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constants.dart';
import 'chatpage.dart';
import 'settings.dart';

class HomePage extends StatefulWidget{
  createState()=>HomePageState();

  UserCredential user;
  HomePage(this.user);

}


class HomePageState extends State<HomePage>{
  String userNickname ='';
  String userImage;

  @override
  initState(){
    super.initState();
    getUserDetails();
  }

  getUserDetails(){
    FirebaseFirestore.instance.collection(Constants.USERS_COLLECTION)
        .doc(widget.user.user.uid)
        .get().then((DocumentSnapshot snapshot){
          userNickname = snapshot[Constants.NICK_NAME];
          userImage = snapshot[Constants.USER_IMAGE];
          print(userNickname);
          setState((){

          });
    }).catchError((e)=>print('error is $e'));
  }

  void choiceAction(String choice){
    if(choice == Constants.settings){
      Navigator.of(context).push(MaterialPageRoute(builder:(_)=>SettingsPage()));
    }
  }

  @override
  build(BuildContext context){
    return DefaultTabController(
      length: 3,
      child:Scaffold(

        appBar: AppBar(
            actions: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 20.0),
                  child: GestureDetector(
                    onTap: () {},
                    child: Icon(
                      Icons.search,
                      size: 26.0,
                    ),
                  )
              ),
         PopupMenuButton(
            onSelected: choiceAction,
            itemBuilder: (BuildContext context){
              return Constants.choices.map((String choice){
                return PopupMenuItem<String>(
                  value: choice,
                  child: Text(choice),
                );
              }).toList();
            }
        ),
            ],
          automaticallyImplyLeading: false,
          bottom:TabBar(
            tabs: [
              Tab(child: Text('Users')),
              Tab(icon: Icon(Icons.camera_alt)),
              Tab(child: Text('Chats')),
            ],
          )
        ),
        body: TabBarView(
           children: <Widget>[
             StreamBuilder(
               stream: FirebaseFirestore.instance.collection(Constants.USERS_COLLECTION).snapshots(),
                 // ignore: missing_return
               builder: (BuildContext context, AsyncSnapshot snapshot){


                 if(snapshot.hasData){
                   // ignore: missing_return, missing_return
                   return ListView.builder(
                     itemCount: snapshot.data.documents.length,
                     // ignore: missing_return
                     itemBuilder: (BuildContext context, int index){
                       // ignore: missing_return
                       return snapshot.data.documents[index][Constants.USER_ID]
                           == widget.user.user.uid ?
                       Center(): Padding(
                         // ignore: missing_return
                         padding: EdgeInsets.only(top: 8),
                         child:ListTile(
                           title: Text(snapshot.data.documents[index][Constants.NICK_NAME]),
                           leading: CircleAvatar(
                             backgroundImage: NetworkImage(snapshot.data.documents[index][Constants.USER_IMAGE]),
                           ),
                           onTap: (){
                             //Load up the chat area for this particular user
                             Navigator.of(context).push(MaterialPageRoute(builder:(_)=>ChatPage(
                               snapshot.data.documents[index][Constants.USER_ID],
                               snapshot.data.documents[index][Constants.NICK_NAME],
                               snapshot.data.documents[index][Constants.USER_IMAGE],
                               widget.user.user.uid
                             )));
                           },
                         )
                       );

                     },
                   );
                 }else{
                   return Center();
                 }
               }
             ),
             Scaffold(),

             Scaffold()
           ],
        )
      ),
    );
  }
}