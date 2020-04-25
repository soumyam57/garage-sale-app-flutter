import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Posts.dart';
import 'PostsDetails.dart';

class MyPostsPage extends StatefulWidget
{
  MyPostsPage({
    this.email,
  });

  final String email;

  @override
  _MyPostsPageState createState() => _MyPostsPageState(email: email);
}

class _MyPostsPageState extends State<MyPostsPage>{

  _MyPostsPageState({this.email});
  final String email;
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  List<Posts> postsList = [];
  FirebaseUser loggedInUser;


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
        if(DATA[individualKey]['email'] == email){
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
      }
      setState(() {
        print(postsList.length);
      });
    });
  }

  void getCurrentUser() async {
    try {
      final user = await _firebaseAuth.currentUser();
      if (user != null) {
        loggedInUser = user;
        print('logged in user in myposts $email');
      }
    } catch (e) {
      print('error in getCurrentUser on listpage');
    }
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Center(child: new Text(
          'My Posts',
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
                      elevation: 5.0,
                      margin: EdgeInsets.all(15.0),
                      child: Container(
                        padding: new EdgeInsets.all(10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Text(
                                  postsList[index].itemName,
                                  style: TextStyle(fontSize: 20.0, color: Colors.black87,fontWeight: FontWeight.bold,),
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
                            SizedBox(height: 5.0,),
                            new Image.network(postsList[index].image,alignment:Alignment.centerRight,height: 280,),
                            SizedBox(height:5.0),
                            new Text(
                              postsList[index].date,
                              style: Theme.of(context).textTheme.subtitle,
                              textAlign: TextAlign.center,
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
    );
  }

}