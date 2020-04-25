import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'MyProfile.dart';
import 'LoginRegistrationPage.dart';
import 'Authentication.dart';
import 'Posts.dart';
import 'PostsDetails.dart';
import 'post_page.dart';

class HomePage extends StatefulWidget
{
  HomePage({
    this.auth,
    this.onSignedOut,
  });

  final AuthImplementation auth;
  final VoidCallback onSignedOut;

  @override
  State<StatefulWidget> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage>{
  FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;
  List<Posts> postsList = [];

  void getCurrentUser() async {
    try {
      final user = await _firebaseAuth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print('logged in user in myposts $loggedInUser)');
      }
    } catch (e) {
      print('error in getCurrentUser on listpage');
    }
  }

  void _logoutUser() async
  {
    try{
      final user = await _firebaseAuth.currentUser();
      await _firebaseAuth.signOut();
      await widget.auth.signOut();
      widget.onSignedOut();
    }
    catch(e){
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    DatabaseReference postsRef = FirebaseDatabase.instance.reference().child("SRPosts");
    postsRef.once().then((DataSnapshot snap)
    {
      var KEYS = snap.value.keys;
      var DATA = snap.value;
      postsList.clear();

      for(var individualKey in KEYS){
        Posts posts = new Posts(
          DATA[individualKey]['itemName'],
          DATA[individualKey]['price'],
          DATA[individualKey]['email'],
          DATA[individualKey]['description'],
          DATA[individualKey]['image'],
          DATA[individualKey]['date'],
          DATA[individualKey]['labels'],
          DATA[individualKey]['latitude'],
          DATA[individualKey]['longitude'],
        );
        postsList.add(posts);
        postsList.sort((a,b)=>(b.date.compareTo((a.date))));
      }
      setState(() {
        print(postsList.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: Builder(builder: (BuildContext context) {
          return IconButton(
            icon: Icon(Icons.home),
            color: Colors.white,
          );
        }),
        title: new Center(child: new Text(
          'SR Garage Sale',
        )),
        backgroundColor: Colors.pink,
      ),

      body: StreamBuilder(
          stream: FirebaseDatabase.instance.reference().child("SRPosts").onValue,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(
                  backgroundColor: Colors.lightBlueAccent,
                ),
              );
            }
            return new Container(
                child: postsList.length == 0? new Text("No items available"):
                new ListView.builder(
                  itemCount: postsList.length,
                  itemBuilder: (_,index){
                    return new Card(
                      elevation: 10.0,
                      margin: EdgeInsets.all(10.0),
                      child: Container(
                        padding: new EdgeInsets.only(left:14,right: 14,top:5,bottom: 5),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Padding(
                                  padding: EdgeInsets.only(left: 10),
                                  child: Text(
                                    postsList[index].itemName,
                                    style: TextStyle(fontSize: 18.0, color: Colors.black87,fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(left: 190),
                                  child: Text(
                                    postsList[index].price,
                                    style: TextStyle(fontSize: 18.0, color: Colors.black87,fontWeight: FontWeight.bold,),
                                  ),
                                ),
                                new IconButton(
                                  icon: new Icon(Icons.arrow_forward_ios),
                                  color: Colors.black,
                                  onPressed: ()
                                  {
                                    Navigator.push(context,
                                        new MaterialPageRoute(builder: (context)
                                        {
                                          return PostsDetails(detail:postsList[index]);
                                        }
                                        ));
                                  },
                                  alignment: Alignment.bottomRight,
                                ),
                              ],
                            ),
                            SizedBox(height: 2.0,),
                            Padding(
                              padding: EdgeInsets.only(right: 10.0,left: 10.0),
                              child: new Image.network(postsList[index].image,alignment:Alignment.centerLeft,height: 250,width: 350,),
                            ),
                            //new Image.network(postsList[index].image,alignment:Alignment.centerLeft,height: 250,),
                            SizedBox(height:5.0),
                            Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: new Text(
                                postsList[index].date,
                                style: Theme.of(context).textTheme.subtitle,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  //reverse: true,
                )
            );
          }
      ),

      bottomNavigationBar: new BottomAppBar(
        color: Colors.pink,
        child: new Container(
          margin: const EdgeInsets.only(left:35.0,right:35.0),
          child: new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              new IconButton(
                icon: new Icon(Icons.person),
                iconSize: 28,
                color: Colors.white,
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)
                      {
                        return new MyProfilePage(email: loggedInUser.email);
                      })
                  );
                },
              ),

              new IconButton(
                icon: new Icon(Icons.add_box),
                iconSize: 28,
                color: Colors.white,
                onPressed: (){
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context)
                      {
                        return new PostPage();
                      })
                  );
                },
              ),
              new IconButton(
                icon: new Icon(Icons.exit_to_app),
                iconSize: 28,
                color: Colors.white,
                onPressed: _logoutUser,
              ),
            ],
          ),
        ),
      ),
    );
  }

}