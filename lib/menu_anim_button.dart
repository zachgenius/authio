import 'package:flutter/material.dart';

class MenuAnimButton extends StatefulWidget {

  final VoidCallback cameraCallback;

  final VoidCallback settingsCallBack;

  const MenuAnimButton({
    Key key,
    @required this.cameraCallback,
    @required this.settingsCallBack,
  }):super(key: key);

  @override
  State<StatefulWidget> createState() {

    var menu = _MenuAnimButtonState();
    menu.cameraCallback = cameraCallback;
    menu.settingsCallBack = settingsCallBack;
    return menu;
  }

}

class _MenuAnimButtonState extends State<MenuAnimButton> with SingleTickerProviderStateMixin{

  VoidCallback cameraCallback;

  VoidCallback settingsCallBack;

  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Curve _curve = Curves.easeOut;

  Animation<double> _translateButton;
  double _fabHeight = 56.0;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300))
          ..addListener((){
            setState(() {

            });
        });

    _animateIcon = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);

    _buttonColor = ColorTween(begin: Colors.blue, end: Colors.red)
        .animate(CurvedAnimation(
            parent: _animationController,
            curve: Interval(0.0, 1.0, curve: _curve)));

    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0
    ).animate(CurvedAnimation(parent: _animationController, curve: Interval(0, 0.75, curve: _curve)));

    super.initState();
  }

  void animate(){
    if(!isOpened){
      _animationController.forward();
    }
    else{
      _animationController.reverse();
    }

    isOpened = !isOpened;
  }

  void onCamera(){
    animate();
    if (cameraCallback != null){
      cameraCallback();
    }
  }

  void onSettings(){
    animate();
    if (settingsCallBack != null){
      settingsCallBack();
    }
  }

  Widget toggle(){
    return FloatingActionButton(
      backgroundColor: _buttonColor.value,
      onPressed: animate,
      tooltip: 'Menu',
      child: AnimatedIcon(icon: AnimatedIcons.menu_close, progress: _animateIcon),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Transform(transform: Matrix4.translationValues(0.0, _translateButton.value * 2.0, 0.0), child: camera(),),
        Transform(transform: Matrix4.translationValues(0.0, _translateButton.value, 0.0), child: settings(),),
        toggle()
      ],
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Widget camera(){
    return new Container(
      child: FloatingActionButton(
        onPressed: onCamera,
        tooltip: "Scan QR Code",
        child: Icon(Icons.camera_alt),
      ),
    );
  }

  Widget settings(){
    return new Container(
      child: FloatingActionButton(
        onPressed: onSettings,
        tooltip: "Settings",
        child: Icon(Icons.settings),
      ),
    );
  }

}