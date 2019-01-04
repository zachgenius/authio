import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _AboutScreen();
  }

}

class _AboutScreen extends State<AboutScreen>{

  PackageInfo _packageInfo = new PackageInfo(
    appName: 'Unknown',
    packageName: 'Unknown',
    version: 'Unknown',
    buildNumber: 'Unknown',
  );

  Future<Null> _initPackageInfo() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    setState(() {
      _packageInfo = info;
    });
  }

  @override
  void initState() {
    super.initState();
    _initPackageInfo();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar:  AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text("About"),
      ),
      body: new Center(
        child:  Column(
          children: <Widget>[
            new Container(child: Image.asset("assets/logo.png", width: 100, height: 100), padding: EdgeInsets.only(top: 50),),
            Text("Authio", style: TextStyle(fontWeight: FontWeight.bold),),
            Text(_packageInfo.version),
            Padding(padding: EdgeInsets.all(30)),
            ListTile(
              title: Text("Privacy Policy"),
              onTap: (){
                const url = 'https://www.freeprivacypolicy.com/privacy/view/8ace9d5f5a1f86bc57770a81296b877e';
                openUrl(url);
              },
              trailing: Icon(Icons.arrow_right),
            ),
            Divider(),
            ListTile(
              title: Text("Contact Us"),
              onTap: (){
                const url = 'mailto:authio@wildfox.pro';
                openUrl(url);
              },
              trailing: Icon(Icons.arrow_right),
            ),
          ],
        ),
      ),
    );
  }

  void openUrl(String url) async{
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

}