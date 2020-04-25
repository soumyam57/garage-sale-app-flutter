import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class PostsDetails extends StatefulWidget {
  PostsDetails({
    this.detail,
  });

  final detail;

  _PostsDetailsState createState() => _PostsDetailsState(detail: detail);

}

class _PostsDetailsState extends State<PostsDetails> {
  _PostsDetailsState({this.detail});
  final detail;
  String address;
  GoogleMapController mapController;
  LatLng _latlong;

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();
    if (detail.latitude != null && detail.longitude != null) {
      _getAddress();
    }
  }

  _getAddress() async {
    final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          detail.latitude, detail.longitude);
      Placemark place = p[0];
      setState(() {
        address = '${place.locality}, ${place.postalCode}, ${place.country}';
        _latlong = LatLng(detail.latitude, detail.longitude);
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        title: new Text("Item Detail"),
        centerTitle: true,
        backgroundColor: Colors.pink,
      ),
      body: _buildProductDetailsPage(context),
    );
  }

  _buildProductDetailsPage(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;

    return ListView(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(4.0),
          child: Card(
            elevation: 4.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildProductImagesWidgets(),
                _buildProductTitleWidget(),
                SizedBox(height: 12.0),
                _buildLabelsWidgets(),
                SizedBox(height: 6.0),
                _buildPriceWidgets(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 6.0),
                _buildEmailWidgets(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 6.0),
                _buildDateWidgets(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 8.0),
                _buildMoreInfoHeader(),
                SizedBox(height: 6.0),
                _buildDivider(screenSize),
                SizedBox(height: 10.0,),
                _buildProductMapsWidgets(),
                SizedBox(height: 12.0),
              ],
            ),
          ),
        ),
      ],
    );
  }

  _buildDivider(Size screenSize) {
    return Column(
      children: <Widget>[
        Container(
          color: Colors.grey[600],
          width: screenSize.width,
          height: 0.3,
        ),
      ],
    );
  }

  Widget textBox(String t) {
    return Center(
      child: Container(
        padding: EdgeInsets.only(top: 5.0, bottom: 5.0),
        child: Text(
          t,
          style: TextStyle(
            fontSize: 15.0,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  _buildProductMapsWidgets(){
    if (address == null) {
      return textBox('User not showing Location');
    } else {
      print("in lat long$_latlong");
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(left: 8.0, right: 8.0),
            height: 200.0,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: _latlong,
                //bearing: 90,
                zoom: 10.0,
              ),
              markers: {
                Marker(
                  markerId: MarkerId('1'),
                  position: _latlong,
                  infoWindow: InfoWindow(
                    title: 'My location',
                  ),
                ),
              },
            ),
          ),
          textBox('Location: $address'),
        ],
      );
    }
  }


  Widget _buildLabelsWidgets(){
    if (detail.labels == null) {
      return textBox('No Labels');
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        for(var i=0;i<detail.labels.length;i++)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: new BoxDecoration(
                color: Colors.orange,
                borderRadius: new BorderRadius.all(Radius.circular(10.0)),),
              padding: EdgeInsets.all(5),
              child: Center(
                child: Text(
                  detail.labels[i],
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.0
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }


  _buildProductImagesWidgets() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 200.0,
        child: Center(
          child: DefaultTabController(
            length: 3,
            child: Stack(
              children: <Widget>[
                new Image.network(detail.image),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _buildProductTitleWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Center(
        child: Text(
          detail.itemName,
          style: TextStyle(fontSize: 24.0, color: Colors.black87,fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  _buildPriceWidgets() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Text(
            'Price: '+detail.price,
            style: TextStyle(fontSize: 16.0, color: Colors.black),
          ),
        ],
      ),
    );
  }

  _buildEmailWidgets(){
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Row(
        children: <Widget>[
          Text(
            "Email to: "+detail.email,
            style: TextStyle(
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            "                                 ",
            style: TextStyle(
              color: Colors.grey[800],
            ),
            textAlign: TextAlign.center,
          ),
          GestureDetector(
            child: Icon(
              Icons.email,
              color: Colors.deepOrangeAccent,
            ),
            onTap:_sendEmailTo,
          )
        ],
      ),
    );
  }

  _sendEmailTo() async{
    var emailid=detail.email;
    if(await canLaunch("mailto:$emailid")){
      await launch("mailto:$emailid");
    }else{
      throw 'can not launch';
    }
  }

  _buildDateWidgets(){
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        "Posted On: "+detail.date,
        style: TextStyle(
          color: Colors.grey[800],
        ),
      ),
    );
  }

  _buildMoreInfoHeader() {
    return Padding(
      padding: const EdgeInsets.only(
        left: 12.0,
      ),
      child: Text(
        "Description: \n"+detail.description,
        style: TextStyle(
          color: Colors.grey[800],
        ),
      ),
    );
  }
}


