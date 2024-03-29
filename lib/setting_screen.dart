import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            switch (index){
              case 0:
                return ListTile(
                  title: Text('Export as a JSON file'),
                  leading: Icon(Icons.insert_drive_file),
                  trailing: Icon(Icons.share),
                  onTap: null,
                );
              case 1:
                return ListTile(
                  title: Text('Import from a JSON file'),
                  leading: Icon(Icons.insert_drive_file),
                  trailing: Icon(Icons.import_export),
                  onTap: null,
                );

              case 2:
                return ListTile(
                  title: Text('Sync with Dropbox'),
                  leading: Icon(Icons.insert_drive_file),
                  trailing: Switch(value: true, onChanged: linkDropbox),
                  onTap: null,
                );

              case 3:
                return ListTile(
                  title: Text('Sync with Google Drive'),
                  leading: Icon(Icons.insert_drive_file),
                  trailing: CupertinoSwitch(value: false, onChanged: linkGoogleDrive, activeColor: Colors.blue,),
                  onTap: null,
                );
            }
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: 4),
    );
  }

  void share(){

  }

  void linkDropbox(bool on){

  }

  void linkGoogleDrive(bool on){

  }

}