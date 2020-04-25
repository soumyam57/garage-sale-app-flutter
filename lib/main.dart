import 'package:flutter/material.dart';
import 'Mapping.dart';
import 'Authentication.dart';

void main() => runApp(SalesApp());

class SalesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: "Garage Sale App",
      theme: new ThemeData(
        primarySwatch: Colors.pink,
      ),
      //home: HomePage(),
      home: MappingPage(auth:Auth(),),
    );
  }

}
