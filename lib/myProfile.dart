import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'myPosts.dart';

class MyProfilePage extends StatefulWidget {
  MyProfilePage({this.email});

  final String email;

  @override
  _MyProfilePageState createState() => _MyProfilePageState(email: email);
}

class _MyProfilePageState extends State<MyProfilePage> {
  _MyProfilePageState({this.email});
  final String email;

  final String _fullName = "Soumya M";
  final String _bio = "\"Hi Everyone, Welcome to my flutter app\"";

  Widget _buildCoverImage(Size screenSize) {
    return Container(
      height: screenSize.height / 2.5,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('images/bluePlain.jpg'),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildProfileImage() {
    return Center(
      child: Container(
        width: 170.0,
        height: 170.0,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/profile.jpg'),
            fit: BoxFit.cover,
          ),
          borderRadius: BorderRadius.circular(90.0),
          border: Border.all(
            color: Colors.white,
            width: 10.0,
          ),
        ),
      ),
    );
  }

  Widget _buildFullName() {
    TextStyle _nameTextStyle = TextStyle(
      fontFamily: 'Roboto',
      color: Colors.black,
      fontSize: 30.0,
      fontWeight: FontWeight.w700,
    );

    return Text(
      _fullName,
      style: _nameTextStyle,
    );
  }

  Widget _buildBio(BuildContext context) {
    TextStyle bioTextStyle = TextStyle(
      fontFamily: 'Spectral',
      fontWeight: FontWeight.w400,//try changing weight to w500 if not thin
      fontStyle: FontStyle.italic,
      color: Color(0xFF799497),
      fontSize: 16.0,
    );

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.all(8.0),
      child: Text(
        _bio,
        textAlign: TextAlign.center,
        style: bioTextStyle,
      ),
    );
  }

  Widget _buildSeparator(Size screenSize) {
    return Container(
      width: screenSize.width / 1.5,
      height: 2.0,
      color: Colors.black54,
      margin: EdgeInsets.only(top: 3.0),
    );
  }

  Widget _buildEmail(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Icon(Icons.person),
        SizedBox(
          width: 20.0,
        ),
        Text(
          email,
          style: GoogleFonts.sourceSansPro(
              fontSize: 20.0,
              color: Colors.black87,
              fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildPostsWidget(){
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Material(
          color: Colors.purple[300],
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          elevation: 10.0,
          child: MaterialButton(
            //onPressed: _logoutUser,
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return MyPostsPage(email:email);
                    }));
              },
              minWidth: 250.0,
              height: 30.0,
              child:
              Row(
                children: <Widget>[
                  Icon(Icons.library_books),
                  SizedBox(width: 20.0,),
                  Text(
                    'My Posts',
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              )
          ),
        ),
        SizedBox(height: 20,),
        Material(
          color: Colors.deepPurple[300],
          borderRadius: BorderRadius.all(Radius.circular(20.0)),
          elevation: 10.0,
          child: MaterialButton(
            //onPressed: _logoutUser,
              onPressed: () {
                Navigator.pop(context);
              },
              minWidth: 250.0,
              height: 30.0,
              child:
              Row(
                children: <Widget>[
                  Icon(Icons.home),
                  SizedBox(width: 20.0,),
                  Text(
                    'Home',
                    style: TextStyle(color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ],
                mainAxisSize: MainAxisSize.min,
              )
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          _buildCoverImage(screenSize),
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  SizedBox(height: screenSize.height / 4.6),
                  _buildProfileImage(),
                  _buildFullName(),
                  _buildBio(context),
                  _buildSeparator(screenSize),
                  SizedBox(height: 30.0,),
                  _buildEmail(),
                  SizedBox(height: 20.0,),
                  _buildPostsWidget(),
                  SizedBox(height: 20.0,),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}