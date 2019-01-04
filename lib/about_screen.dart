import 'package:flutter/material.dart';

class AboutScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AboutScreen();
  }

}

class _AboutScreen extends State<AboutScreen>{
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("About"),
      ),
    );
  }

}