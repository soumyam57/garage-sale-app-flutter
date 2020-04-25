import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'HomePage.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'DialogBox.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PostPage extends StatefulWidget {
  State<StatefulWidget> createState() {
    return _PostPageState();
  }
}

class _PostPageState extends State<PostPage> {

  List<String> imageLables=[];
  List<String> displayImageLables=[];
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  File sampleImage;
  int count=0;
  String _myValue, _myPrice, _myDesc, _myEmail;
  String _url;
  int imageLabelSize;
  Position _myCurPosition;
  bool shareLocation = true;
  final formKey = new GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
    var android = new AndroidInitializationSettings('@mipmap/ic_launcher');
    var iOS = new IOSInitializationSettings();
    var initSetttings = new InitializationSettings(android, iOS);
    flutterLocalNotificationsPlugin.initialize(initSetttings,
        onSelectNotification: onSelectNotification);
  }

  Future onSelectNotification(String payload) {
    debugPrint("payload : $payload");
    showDialog(
      context: context,
      builder: (_) => new AlertDialog(
        title: new Text('Notification'),
        content: new Text('$payload'),
      ),
    );
  }

  Future getImageFromGallery() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      sampleImage = tempImage;
    });
  }

  Future getImageFromCamera() async {
    var tempImage = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      sampleImage = tempImage;
    });
  }

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    } else {
      return false;
    }
  }

  void _getImageLabels() async {
    imageLables.clear();
    displayImageLables.clear();
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(sampleImage);
    final ImageLabeler labeler = FirebaseVision.instance.imageLabeler(
      ImageLabelerOptions(confidenceThreshold: 0.75),
    );
    final List<ImageLabel> labels = await labeler.processImage(visionImage);
    setState(() {
      imageLables = imageLables;
    });
    for (ImageLabel label in labels) {
      imageLables.add(label.text);
    }
    //to restrict number of images to display to 3
    if(imageLables.length>3){
      imageLabelSize=3;
    }
    else{
      imageLabelSize=imageLables.length;
    }
    for(var i=0;i<imageLabelSize;i++){
      displayImageLables.add(imageLables[i]);
    }

  }

  void uploadStatusImage() async {
    DialogBox dialogBox = new DialogBox();
    if (validateAndSave()) {
      _getCurrentLocation();
      final StorageReference postItemRef =
      FirebaseStorage.instance.ref().child("SRPosts - New items");
      var timeKey = new DateTime.now();
      final StorageUploadTask uploadTask =
      postItemRef.child(timeKey.toString() + ".jpg").putFile(sampleImage);
      var imageUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
      _url = imageUrl.toString();
      print("Image url= " + _url);
      saveToDatabase(_url);
      await new Future.delayed(const Duration(seconds: 1));
      showNotification();
      goToHomePage();
    }
  }

  _getCurrentLocation() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    await geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation)
        .then((Position position) {
      _myCurPosition = position;
    }).catchError((e) {
      print(e);
    });
  }

  void goToHomePage() {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return new HomePage();
    }));
  }

  void saveToDatabase(url) async {
    var currentTime = new DateTime.now();
    var formatDate = new DateFormat('MMM d, yyyy');
    var formatTime = new DateFormat('EEEE, hh:mm aaa');
    String date = formatTime.format(currentTime);
    double latitude;
    double longitude;

    if (shareLocation == true) {
      await _getCurrentLocation();
      if (_myCurPosition != null) {
        latitude = _myCurPosition.latitude;
        longitude = _myCurPosition.longitude;
      }
    }

    DatabaseReference ref = FirebaseDatabase.instance.reference();
    var data = {
      "itemName": _myValue,
      "price": _myPrice,
      "email": _myEmail,
      "description": _myDesc,
      "image": url,
      "date": date,
      "labels":displayImageLables,
      "latitude": latitude,
      "longitude": longitude
    };

    ref.child("SRPosts").push().set(data);
  }

  showNotification() async {
    var android = new AndroidNotificationDetails(
        'channel id', 'channel NAME', 'CHANNEL DESCRIPTION',
        priority: Priority.High, importance: Importance.Max);

    var iOS = new IOSNotificationDetails();

    var platform = new NotificationDetails(android, iOS);

    await flutterLocalNotificationsPlugin.show(
        0, 'New post is added', 'Notification', platform,
        payload: 'New item added');
  }



  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text("Create a new Post"),
          backgroundColor: Colors.pink,
          centerTitle: true,
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.add_photo_alternate),
                onPressed: getImageFromGallery),
            IconButton(
                icon: Icon(Icons.camera_alt), onPressed: getImageFromCamera),
          ],
        ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(5.0),
          // color: Colors.white,
          margin: EdgeInsets.symmetric(horizontal: 30.0),
          child: new Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 10.0,
                ),
                Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      //borderRadius: BorderRadius.circular(5.0),
                      ),
                  width: 340,
                  height:250,
                  child: sampleImage == null ? Text("Select an Image",textAlign: TextAlign.center) : Image.file(
                    sampleImage,
                    fit: BoxFit.fill,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    ButtonTheme(
                      minWidth: 30.0,
                      height: 30.0,
                      child: RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          ),
                          elevation: 8.0,
                          child: Text("Labels:",style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.0
                          ),),
                          textColor: Colors.white,
                          color: Colors.deepOrange,
                          onPressed: (){
                            //add labels
                            _getImageLabels();
                          }
                      ),
                    ),
                    Expanded(
                      child: (imageLables.length==0 || imageLables==null)?
                      Container():
                      Row(
                        children: <Widget>[
                          for(var i=0;i<displayImageLables.length;i++)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: new BoxDecoration(
                                  color: Colors.orange,
                                  borderRadius: new BorderRadius.all(Radius.circular(10.0)),),
                                padding: EdgeInsets.all(5),
                                child: Center(
                                  child: Text(
                                    displayImageLables[i],
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.0
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  decoration: new InputDecoration(labelText: 'Name of the item'),
                  validator: (value) {
                    return value.isEmpty ? 'Item Name is required' : null;
                  },
                  onSaved: (value) {
                    return _myValue = value;
                  },
                ),

                Row(children: [
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Price"),
                      validator: (price) {
                        return price.isEmpty ? 'Price is required' : null;
                      },
                      onSaved: (price) {
                        return _myPrice = price;
                      },
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: TextFormField(
                      decoration: InputDecoration(labelText: "Email"),
                      validator: (email) {
                        return email.isEmpty ? 'Email is required' : null;
                      },
                      onSaved: (email) {
                        return _myEmail = email;
                      },
                    ),
                  )
                ]),
                TextFormField(
                  decoration: new InputDecoration(labelText: 'Description'),
                  onSaved: (desc) {
                    return _myDesc = desc;
                  },
                ),
                Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 10.0, 10.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text('Share my location'),
                        Switch(
                          value: shareLocation,
                          activeColor: Colors.pink,
                          onChanged: (bool value) {
                            setState(() {
                              shareLocation = value;
                            });
                          },
                        ),
                      ],
                    )),
                RaisedButton(
                    elevation: 10.0,
                    child: Text("Post item"),
                    textColor: Colors.white,
                    color: Colors.pink,
                    onPressed: uploadStatusImage
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }




  /*
  Expanded(
                      child: RaisedButton (
                        shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.red)
                        ),
                        child: imageLables.length==0? Text('No labels'):
                        Row(
                          children: <Widget>[
                            Container(
                              child: Text(imageLables[0]),
                              color: Colors.orange,
                              width: 70,
                              height: 35,
                              alignment: Alignment.center,
                            ),
                            SizedBox(
                              width: 2.0,
                            ),
                            Container(
                              child: Text(imageLables[1]),
                              color: Colors.orange,
                              width: 70,
                              height: 35,
                              alignment: Alignment.center,
                            ),
                            SizedBox(
                              width: 2.0,
                            ),
                            Container(
                              child: Text(imageLables[2]),
                              color: Colors.orange,
                              width: 70,
                              height: 35,
                              alignment: Alignment.center,
                            ),
                          ],
                        ),
                      ),
                    ),
   */

}
