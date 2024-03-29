import 'package:flutter/material.dart';
import 'package:qrcode_reader/qrcode_reader.dart';
import 'auth_item.dart';

class CameraInstructionScreen extends StatefulWidget{

  @override
  State<StatefulWidget> createState() {

    return _CameraInstructionScreenState();
  }
}

class _CameraInstructionScreenState extends State<CameraInstructionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Accounts"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(20),
              child: Text("You can add any account that uses google authenticator, such as Gmail, Facebook, Dropbox and etc., using Authio"),
          ),

          Image.asset("assets/qrinstr.png"),
          Padding(padding: EdgeInsets.only(top: 20)),
          Builder(builder: (ctx)=>MaterialButton(
            onPressed: ()=>scan(ctx),
            color: Colors.blue,
            padding: EdgeInsets.only(
                left: 50,
                top: 10,
                right: 50,
                bottom: 10
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                ),
                Padding(padding: EdgeInsets.only(left: 10)),
                Text("Scan QR Code", style: TextStyle(color: Colors.white, fontSize: 18),)
              ],
            ),
          ))
        ],
      ),
    );
  }

  void scan(BuildContext ctx){
    Future<String> futureString = new QRCodeReader()
        .setAutoFocusIntervalInMs(200) // default 5000
        .setForceAutoFocus(true) // default false
        .setTorchEnabled(true) // default false
        .setHandlePermissions(true) // default true
        .setExecuteAfterPermissionGranted(true) // default true
        .scan();
    futureString.then((String value){
      if (value != null && value != ''){
        AuthItem item = new AuthItem();
        item.init(value);

        if (item.authUrl == null){
          Scaffold.of(ctx).showSnackBar(SnackBar(content: Text("Sorry, the QR code is not supported!")));
        }
        else{
          Navigator.pop(context, value);
        }
      }
    }).catchError((_){});
  }

}