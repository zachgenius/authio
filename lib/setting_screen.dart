import 'package:flutter/material.dart';

class SettingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView.separated(
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text('Export as a JSON file'),
            );
          },
          separatorBuilder: (BuildContext context, int index) => Divider(),
          itemCount: 1),
    );
  }

}