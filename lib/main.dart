import 'package:flutter/material.dart';
import 'auth_item.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:async';
import 'dart:convert';
import 'menu_anim_button.dart';
import 'camera_instruction_screen.dart';
import 'setting_screen.dart';
import 'about_screen.dart';

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
      initialRoute: "/",
      debugShowCheckedModeBanner : false,
      routes: {
        "/" : (context) => MyHomePage(title: 'Authio'),
        "/settings" : (context) => SettingScreen(),
        '/camera' : (context) => CameraInstructionScreen(),
        '/about' : (context) => AboutScreen(),
      },
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

  var _currentProgress = 0.3;

  Timer _countdownTimer;

  var emptyView = Expanded(
    flex: 100,
    child:Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Padding(padding: EdgeInsets.only(left: 80)),
            Text("Updates every 30s👆", style: TextStyle(fontSize: 18),),
            Spacer(flex: 1,),
            Text("Menu👆", style: TextStyle(fontSize: 18)),
            Padding(padding: EdgeInsets.only(right: 15),)
          ],
        ),
        Spacer(flex: 1,),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(padding: EdgeInsets.only(bottom: 20, right: 80), child: Text("Add Accounts👉", style: TextStyle(fontSize: 18)),)
          ],
        )
      ],
    )
  );

  void refreshList(){
    setState(() {
      _2faItems.forEach((f) => f.generateOutputNumber());
    });
  }

  void refreshIndicator(){

    var current = DateTime.now().millisecondsSinceEpoch % 30000;
    var rate = current / 30000.0;

    setState((){
      _currentProgress = rate;
    });

    if (rate.floor() == 0){
      refreshList();
    }
  }

  void scanQRCode(){
    Navigator.pushNamed(context, "/camera")
        .then((value){
          this.saveNewItem(value);
    }).catchError((_){});
  }

  void jumpToSettings(){
    Navigator.pushNamed(context, "/settings");
  }

  @override
  void initState() {
    super.initState();
    loadData().then((_){
      refreshList();
      _countdownTimer = new Timer.periodic(new Duration(milliseconds: 50), (timer){
        refreshIndicator();
      });

    });
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
    List<dynamic> authUris = decodeData["authUris"];
    if(authUris != null && authUris.isNotEmpty){
      for(dynamic uriPath in authUris){
        var item = AuthItem();
        item.init(uriPath as String);
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

    List<dynamic> authUris = decodeData["authUris"];
    if (authUris == null){
      authUris = List<dynamic>();
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

  Future<Null> saveCurrentItems() async{
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

    List<String> authUris = new List();

    _2faItems.forEach((f){
      authUris.add(f.authUrl);
    });

    decodeData["authUris"] = authUris;
    data = json.encode(decodeData);
    file.writeAsString(data);
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
        actions: <Widget>[
          PopupMenuButton<PopupEnum>(
            offset: Offset(0, 80),
            icon: Icon(Icons.more_vert),
            itemBuilder: (BuildContext context) => <PopupMenuEntry<PopupEnum>>[
              const PopupMenuItem(
                    child: Text("About"),
                    value: PopupEnum.About,
                  )
            ],
            onSelected: (PopupEnum item){
              if (item == PopupEnum.About){
                Navigator.pushNamed(context, "/about");
              }
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          LinearProgressIndicator(
            value: _currentProgress,
          ),
          _2faItems.length == 0 ? emptyView : Container(),
          Expanded(
            flex: 1,
            child: ListView.separated(
                      itemCount: _2faItems.length, //_2faItems.length,
                      separatorBuilder: (BuildContext context, int index) => Divider(),
                      itemBuilder: (BuildContext context, int index) {
                        var item = _2faItems[index];
                        return Dismissible(
                            direction: DismissDirection.endToStart,
                            key: Key(item.secret),
                            onDismissed: (direction) {
                              // Remove the item from our data source.
                              removeItem(context,index);

                            },
                            // Show a red background as the item is swiped away
                            background: Container(
                              alignment: Alignment.centerRight,
                              color: Colors.red,
                              child: Icon(Icons.delete, color: Colors.white),
                              padding: EdgeInsets.only(right: 15),

                            ),
                            child: ListTile(
                              title: Text('${item.outputNumber}'),
                              subtitle: Text(item.label),
                              trailing: Text(item.issuer),
                            )
                        );
                      }
                  )
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scanQRCode,
        tooltip: "Scan QR Code",
        child: Icon(Icons.camera_alt),
      )

        //TODO 这里的问题就在于有多个按钮之后, 就无法跳转到下一页, 直接黑屏...
//      floatingActionButton: MenuAnimButton(cameraCallback: scanQRCode, settingsCallBack: jumpToSettings,),
    );
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
    super.dispose();
  }

  void removeItem(BuildContext ctx, int index){
    var removeItem = _2faItems[index];
    setState(() {
      _2faItems.removeAt(index);
    });

    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (BuildContext bCtx){
        return AlertDialog(
          title: Text("Delete this item?"),
          actions: <Widget>[
            FlatButton(
              child: Text("Cancel"),
              onPressed: (){
                setState(() {
                  _2faItems.insert(index, removeItem);
                });
                Navigator.pop(bCtx);
              },
            ),
            FlatButton(
              child: Text("Delete"),
              textColor: Colors.red,
              onPressed: (){
                // Then show a snackbar!
                Scaffold.of(ctx)
                    .showSnackBar(SnackBar(content: Text("Deleted")));

                saveCurrentItems();
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    ).then((value){

    });

  }
}

enum PopupEnum {About}