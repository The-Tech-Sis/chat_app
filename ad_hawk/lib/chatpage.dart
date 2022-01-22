import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:focused_menu/modals.dart';
import 'constants.dart';
import 'package:flutter/services.dart';
import 'image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:focused_menu/focused_menu.dart';
import 'package:flutter/services.dart';

class ChatPage extends StatefulWidget{

  String chatUserNickname;
  String chatUserId;
  String chatUserImage;
  String senderUserId;



  ChatPage(this.chatUserId, this. chatUserNickname, this.chatUserImage, this.senderUserId);
  @override
  createState()=>_ChatPageState();
}

class _ChatPageState extends State<ChatPage>{

  String content;
  String messageType = 'text';
  String imageName;

  String chatDocId;
  TextEditingController messageController = TextEditingController();

  @override
  void initState(){
    super.initState();
    chatDocId ='';

    if(widget.senderUserId.hashCode <=widget.chatUserId.hashCode){
      chatDocId = '${widget.senderUserId} - ${widget.chatUserId}';
    }else{
      chatDocId = '${widget.chatUserId} - ${widget.senderUserId}';
    }
  }

  sendMessage(){
    // next line of code will clear the text field
    messageController.text = '';
    FirebaseFirestore.instance
    .collection(Constants.MESSAGES_COLLECTION)
    .doc(chatDocId)
    .collection(chatDocId)
    .doc(DateTime.now().millisecondsSinceEpoch.toString())
    .set({
      Constants.CONTENT : content,
      Constants.FROM_ID : widget.senderUserId,
      Constants.TO_ID : widget.chatUserId,
      Constants. MESSAGE_TYPE : messageType,
      Constants.TIME_STAMP : DateTime.now().millisecondsSinceEpoch.toString(),
      Constants.PICTURE: imageName,
    }).catchError((e)=>print('Error is : $e'));
  }
  // function to adjust the height of the text field

  int maxLines = 1;
  adjustTextFieldHeight(String textFieldContent){

  }

  @override
  build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title:Row(
          children: <Widget>[
            CircleAvatar(
              backgroundImage: NetworkImage(widget.chatUserImage),
            ),

            SizedBox(width:10,),
            Text(widget.chatUserNickname)
          ],

        ),
      ),

      body:Column(
        children: <Widget>[
          Flexible(
            child:StreamBuilder(
              stream: FirebaseFirestore.instance.collection(Constants.MESSAGES_COLLECTION)
                  .doc(chatDocId)
                  .collection(chatDocId)
                  .orderBy(Constants.TIME_STAMP, descending: false)
                  .limit(20)
                  .snapshots(),
              // ignore: missing_return

              // ignore: missing_return
              builder: (BuildContext context, AsyncSnapshot asyncSnapshot){
                if(asyncSnapshot.hasData){
                  return ListView.builder(
                    itemCount: asyncSnapshot.data.documents.length,
                    // ignore: missing_return
                    itemBuilder:(BuildContext context, int index){

                      bool isSender;

                      if(asyncSnapshot.data.documents[index][Constants.FROM_ID]==widget.senderUserId){
                        isSender = true;
                      }else{
                        isSender = false;
                      }
                      return Padding(
                        padding:const EdgeInsets.only(top:8, left: 8, right: 8),
                        child: Row(
                          mainAxisAlignment: isSender ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: <Widget>[
                            asyncSnapshot.data.document[index][Constants.MESSAGE_TYPE] == 'text'?
                                FocusedMenuHolder(
                                  child:   Material(
                                      color: isSender ? Colors.green[400] : Colors.white24,

                                      child: Padding(
                                        padding: const EdgeInsets.all(12),

                                        child: Flex(
                                          direction: Axis.vertical,
                                          children:<Widget>[
                                            SizedBox(child: Text(asyncSnapshot.data.documents[index]
                                            [Constants.CONTENT],
                                            ),
                                              width: 200,
                                            )
                                          ],
                                        ),
                                      ),

                                      borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16),
                                          bottomRight: Radius.circular(16),
                                          topRight: isSender? Radius.circular(4):Radius.circular(16),
                                          topLeft: isSender? Radius.circular(16): Radius.circular(4)
                                      ),
                                  ),
                                  onPressed:(){
                                    print('tapped focused menu innit');
                                  },
                                  animateMenuItems: true,
                                  duration:Duration(milliseconds:200),
                                  blurSize: 1,
                                  menuWidth: MediaQuery.of(context).size.width/2,
                                  menuItems: <FocusedMenuItem>[
                                    FocusedMenuItem(
                                      title:Text('Copy'),
                                      trailingIcon: Icon(Icons.content_copy),
                                      onPressed:(){
                                        Clipboard.setData(ClipboardData(
                                            text: asyncSnapshot.data.document[index][Constants.CONTENT],
                                        )
                                        );
                                      },
                                    ),
                                    FocusedMenuItem(
                                      title:Text('Delete'),
                                      trailingIcon: Icon(Icons.delete, color: Colors.red),
                                      onPressed:(){
                                        FirebaseFirestore.instance.collection(Constants.MESSAGES_COLLECTION)
                                            .doc(chatDocId)
                                            .collection(chatDocId)
                                            .doc(asyncSnapshot.data.document[index].id)
                                            .delete().catchError((e){
                                              print(e);
                                        });
                                      }
                                    )
                                  ],
                                )
                                  :
                            (// TEXT ELSE
                                // >>>>>>>IF IMAGE
                                asyncSnapshot.data.document[index][Constants.MESSAGE_TYPE] == 'image'
                                ? FocusedMenuHolder(
                                  child:Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Container(
                                        height:100,
                                        width:140,
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding:const EdgeInsets.symmetric(horizontal: 3.0),
                                          child: Stack(
                                            children: [
                                              Align(
                                                alignment: Alignment.center,
                                                child:Icon(FontAwesomeIcons.image, size: 50),
                                              ),
                                              Positioned(
                                                bottom: 5,
                                                child: Text(asyncSnapshot.data.document[index]
                                                [Constants.PICTURE]?? '', maxLines: 1, overflow: TextOverflow.ellipsis,
                                                )
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        color: isSender ? Colors.green[400] : Colors.white24,
                                        width: 150,
                                        child: Container(
                                          alignment:Alignment.centerRight,
                                          child: null,

                                        ),
                                      ),
                                    ],
                                  ),
                                  onPressed:(){
                                    // if the imagePath exists on the users device that sent the image (the sender)


                                  }
                                )


                            )
                          ],
                        )
                      );
                    }
                  );
                }else{
                  // add loading screen
                  return Center();
                }
              },
            ),
          ),

          Row(
            children: <Widget>[
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius:  BorderRadius.circular(16)
                      ),
                    ),

                    maxLines: null,

                    onChanged: (textVal){
                      content = textVal;
                      // adjust the height of the textField

                      adjustTextFieldHeight(textVal);
                    },
                    keyboardType: TextInputType.multiline,
                  ),
                ),
              ),
              SizedBox(width: 6,
              ),

              IconButton(icon:Icon(Icons.image),
                onPressed: (){
                Navigator.of(context).push(MaterialPageRoute(builder:(_)=>ImagePickerWidget()));
                },
              ),

              IconButton(
                icon: Icon(Icons.send),
                onPressed: (){
                  // send message
                  if(content == null || content == ''){
                    // don't send
                  }else{
                    sendMessage();
                  }
                },
              )
            ],
          )
        ],
      )
    );
  }
}