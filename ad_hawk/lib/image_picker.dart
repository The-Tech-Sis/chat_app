import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'constants.dart';


class ImagePickerWidget extends StatefulWidget{
  @override
  _ImagePickerWidgetState createState()=> _ImagePickerWidgetState();


}


class _ImagePickerWidgetState extends State<ImagePickerWidget>{
  File myCroppedImage; //this will be the image file that will be gotten and sent to the DB
  String picName = '';
  String imageLink = '';
  String senderImagePath = '';

   double loadingFileProgress = 0.0;
   bool loadingFile = false;

  String userImageLink = ''; //this will be the image link that will be retrieved after the image has successfully saved in fireStorage

  Future<bool> _getImageAndCrop() async {
   final  PickedFile image = await ImagePicker().getImage(
     source: ImageSource.gallery,
   );

    //image will be null if the user goes back and decides not to select a picture anymore

    if(image != null){
      print('*********image gotten');

      File croppedImage = await ImageCropper.cropImage(
          sourcePath: image.path,
          androidUiSettings: AndroidUiSettings(
            statusBarColor: Colors.black, //status bar color above appbar
            toolbarColor: Colors.blue, //appbar color
            toolbarWidgetColor: Colors.black, //text appBar color
            toolbarTitle: 'Crop picture',
          )
      );

      //cropped image will be null if the user goes back and decides not to crop the picture anymore

      if(croppedImage != null){
        print('*********Now uploading image cropped ${croppedImage.path}');
        // My cropped image returns a file with unique name, e.g
        // >> /data/user/0/com.example.firebase_lab_rat/cache/image_cropper_1600900552992.jpg

        List<String> fullImagePath = croppedImage.path.split('/');
        print('*************** FILE NAME IS ${fullImagePath.last} ');

        String imageName = fullImagePath.last;
        await sendImageToFirestorageAndGetDownloadUrl(croppedImage, imageName);
        return true;

      }else{
        print('*********Cancelled crop process');
        return false;
      }

    }else{
      print('*********User cancelled selecting image process');
      return false;
    }
  }




//FUNCTION TO UPLOAD IMAGE TO DB
  sendImageToFirestorageAndGetDownloadUrl(File image, String imageName)async{
    try{
      print('*********uploading to firestorage');
      //set image file to storage
      final String pictureName = '$imageName'+'.jpg';

      final Reference storageRef = FirebaseStorage.instance.ref().child('Pictures/$pictureName');

      print('***** IMAGE PATH: ${image.path}');
      picName = pictureName;
      senderImagePath = image.path;

      UploadTask uploadTask = storageRef.putFile(
          File(image.path),
          SettableMetadata(contentType: 'image/jpg')
      );

        //  THIS WILL HELP LISTEN TO THE PROGGRESS OF THE UPLOAD
      uploadTask.snapshotEvents.listen((event){
        setState(() {
          loadingFile = true;
          loadingFileProgress = event.bytesTransferred.toDouble()/event.totalBytes.toDouble();
          print(loadingFileProgress);
        });
      }).onError((e){
        setState(() {
          loadingFile = false;
          loadingFileProgress = 0.0;
        });

        print(e.toString());
      });

      //getDownloadUrlAfterLoadingToFireStorage
      print('*********getting downloadUrl');
      TaskSnapshot download = await uploadTask;
      String imageDownloadUrl = await download.ref.getDownloadURL();

      print('************ the imageDownload urs is $imageDownloadUrl');

      //if opacity = 0.0, the linearProgressIndicator will be hidden
      // and then the variable userImageLink will no longer be '', as it will now contain the link of the image in firestorage

      setState((){
        opacity = 0.0;
        // loadingImageProgress = 0.0;
        this.userImageLink = imageDownloadUrl;
      });

    }catch(e){
      print(e);
    }
  }

  bool absorb = false;
  double opacity = 0.0;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
        absorbing: absorb,
        child: Scaffold(
          appBar: AppBar(
              title: Text('Image test')
          ),
          floatingActionButton: FloatingActionButton.extended(
            label: Row(
              children: <Widget>[
                Icon(Icons.cloud_upload),
                SizedBox(width: 2),
                Text('Upload image')
              ],
            ),
            onPressed: () async {
              if(myCroppedImage !=null){

                //this function will receive the file and image name you want to use for the image in the database
                await sendImageToFirestorageAndGetDownloadUrl(myCroppedImage, 'SentImage');

                //after the above function runs, this will fire to save the image link to a document
                FirebaseFirestore.instance.collection(Constants.IMAGE_COLLECTION).doc(Constants.PICTURE).set({
                  'image': userImageLink,
                }).then((value){
                  print('********DONE');
                  setState(() {
                    myCroppedImage=null;
                  });
                });

              }else{

                print('select an image first');
              }

            },
          ),

          body: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(height: 5),
                    this.myCroppedImage == null
                        ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Choose image'),
                        IconButton(
                          icon: Icon(Icons.image),
                          onPressed: (){
                            _getImageAndCrop();
                          },
                        )
                      ],
                    ) : Container(
                        height: 100,
                        width: 100,
                        child: Image.file(this.myCroppedImage, fit: BoxFit.cover)
                    ),

                    SizedBox(height: 10),

                    Divider(thickness: 5,),

                    Text('A stream builder is used here to listen to the document that the image link will be sent to. Once an image has been succesfully saved in the database, it will reflect here'),

                    //THIS STREAM WILL LISTEN TO THE DOCUMENT WHERE THE IMAGE LINK WILL BE SENT IN FIRESTORE
                    // ONCE A DOCUMENT HAS BEEN CREATED WITH THE IMAGE LINK, YOU WILL SEE IT ON YOUR SCREEN
                    StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance.collection(Constants.IMAGE_COLLECTION).snapshots(),

                        builder: (context, snapshot) {
                          if (snapshot.data == null) {
                            return Center(child: Text('Loading... Please wait'));
                          }

                          if (snapshot.hasData) {

                            List<DocumentSnapshot> doc = snapshot.data.docs;

                            if (doc.isEmpty) {
                              return Center(
                                child: Text('No image yet'),
                              );
                            } else {
                              return Container(
                                  height: 100,
                                  width: 100,
                                  child: Image.network(doc[0]['image'])
                              );
                            }
                          } else {
                            return Center(
                              child: Text('Loading...'),
                            );
                          }
                        }
                    ),
                  ],
                ),
              ),
              Opacity(
                  opacity: opacity,
                  child: LinearProgressIndicator(minHeight: 8,)
              ),
            ],
          ),
        )
    );
  }
}