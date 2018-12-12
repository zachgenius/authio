import 'package:flutter/material.dart';
import 'auth_item.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'package:qrcode_reader/qrcode_reader.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Authio',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Authio'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  var _2faItems = new List<AuthItem>();

  void showAddMenu(){
    scanQRCode();
  }

  void refreshList(){
    setState(() {
      _2faItems.forEach((f) => f.generateOutputNumber());
    });
  }

  void scanQRCode(){
    Future<String> futureString = new QRCodeReader()
        .setAutoFocusIntervalInMs(200) // default 5000
        .setForceAutoFocus(true) // default false
        .setTorchEnabled(true) // default false
        .setHandlePermissions(true) // default true
        .setExecuteAfterPermissionGranted(true) // default true
        .scan();
    futureString.then((String value){
      this.saveNewItem(value);
    }).catchError((_){});
  }


  @override
  void initState() {
    super.initState();
    var path = "otpauth://totp/Apple:myaccount?secret=syjrir3jeccxlhixfddt5hwhlvuk73qi2yxoiwqoqf4lpig3bnbzf35u&algorithm=SHA256&digits=6&period=30&counter=0";
    loadData().then((_){});
  }

  Future<Null> loadData() async{
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/data.dat");
    if(!(await file.exists())){
      await file.create();
      return;
    }
    final data = await file.readAsString();
    Map<String, dynamic> decodeData;
    try{
      decodeData = json.decode(data);
    }catch(_){
    }

    if(decodeData == null){
      decodeData = Map<String, dynamic>();
    }
    List<String> authUris = decodeData["authUris"];
    if(authUris != null && authUris.isNotEmpty){
      for(String uriPath in authUris){
        var item = AuthItem();
        item.init(uriPath);
        item.generateOutputNumber();
        _2faItems.add(item);
      }
    }
  }

  void saveNewItem(String uri){

    doSaveNewItem(uri)
        .then((item) {
      if(item != null){
        item.generateOutputNumber();
        _2faItems.add(item);
        refreshList();
      }

    }).catchError((_){

    });

  }

  Future<AuthItem> doSaveNewItem(String uri) async{
    final directory = await getApplicationDocumentsDirectory();
    final file = File("${directory.path}/data.dat");

    if(!(await file.exists())){
      await file.create();
    }

    var data = await file.readAsString();

    Map<String, dynamic> decodeData;
    try{
      decodeData = json.decode(data);
    }catch(_){
    }

    if(decodeData == null){
      decodeData = Map<String, dynamic>();
    }

    List<String> authUris = decodeData["authUris"];
    if (authUris == null){
      authUris = List<String>();
    }

    var item = AuthItem();
    item.init(uri);

    if(item.secret == null || item.secret.isEmpty){
      return null;
    }

    item.generateOutputNumber();

    authUris.add(uri);
    decodeData["authUris"] = authUris;
    data = json.encode(decodeData);
    file.writeAsString(data);

    return item;

  }

  @override
  Widget build(BuildContext context) {

    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.separated(
        itemCount: _2faItems.length, //_2faItems.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),
        itemBuilder: (BuildContext context, int index) {
          var item = _2faItems[index];
          return ListTile(
            title: Text('output:  ${item.outputNumber}'),
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddMenu,
        tooltip: 'ShowAddMenu',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
