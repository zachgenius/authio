import 'dart:convert';
import 'package:base32/base32.dart';
import 'dart:math';
import 'package:crypto/crypto.dart';
class AuthItem {
  String authUrl;

  String label = "";
  String secret;
  String type = ''; //TOTP///HOTP
  String issuer = '';
  String algorithm = "SHA1"; //SHA1, SHA256
  int digits = 6; // 6, 8
  int period = 30; //seconds
  int counter = 0;

  int outputNumber = 0;

  void init(String url){
    var uri = Uri.parse(url);
    var host = uri.host.toUpperCase();
    var scheme = uri.scheme;
    if(scheme != "otpauth"){
      return;
    }
    if(host != "TOTP"
//        && host != "HOTP"
    ){
      return;
    }

    var pathMap = uri.queryParameters;
    if (!pathMap.containsKey("secret")){
      return;
    }

    if(pathMap.containsKey("algorithm")){
      var theAlg = pathMap["algorithm"].toUpperCase();
      if(theAlg == "SHA1"
//          || theAlg == "SHA224"
          || theAlg == "SHA256"
//          || theAlg == "SHA384"
//          || theAlg == "SHA512"
      ){
        algorithm = theAlg;
      }
    }

    authUrl = url;

    type = host;
    secret = pathMap["secret"];
    secret = secret.replaceAll(" ", "").replaceAll("%20", "").toUpperCase();

    if(pathMap.containsKey("period")){
      try{
        var p = int.parse(pathMap["period"]);
        if (p >= 15){
          period = p;
        }
      }catch(e){
      }
    }

    if(pathMap.containsKey("digits")){
      try{
        var p = int.parse(pathMap["digits"]);
        if (p >= 6){
          digits = p;
        }
      }catch(e){
      }
    }

    if(pathMap.containsKey("counter")){
      try{
        var p = int.parse(pathMap["counter"]);
        counter = p;
      }catch(e){
      }
    }

    var path = uri.path;
    if(path != null && path != ""){
      if(path.startsWith("/")){
        path = path.substring(1);
      }

      var list = path.split(":");
      if(list.length == 1){
        try{
          label = Uri.decodeFull(list[0]);
        }catch(e){}
      }
      else if(list.length > 1){
        issuer = list[0];
        try{
          label = Uri.decodeFull(list[1]);
        }catch(e){}
      }
    }

  }

  void generateOutputNumber(){
    if(secret == null || secret == ""){
      return;
    }
    if(type == "TOTP"){
      var time = DateTime.now().millisecondsSinceEpoch;
      time = (((time ~/ 1000).round()) ~/ period).floor();
      outputNumber = _generateCode(secret, time, digits);

    }
    else{
      outputNumber = _generateCode(secret, counter, digits);
    }

  }

  int _generateCode(String secret, int time, int length) {
    length = (length > 0) ? length : 6;

    var secretList = base32.decode(secret);
    var timebytes = _int2bytes(time);
    Hash theHashAlg = sha1;
    if (algorithm == "SHA256"){
      theHashAlg = sha256;
    }
    var hmac = Hmac(theHashAlg, secretList);
    var hash = hmac.convert(timebytes).bytes;

    int offset = hash[hash.length - 1] & 0xf;

    int binary = ((hash[offset] & 0x7f) << 24) |
    ((hash[offset + 1] & 0xff) << 16) |
    ((hash[offset + 2] & 0xff) << 8) |
    (hash[offset + 3] & 0xff);

    return binary % pow(10, length);
  }

  List _int2bytes(int long) {
    // we want to represent the input as a 8-bytes array
    var byteArray = [0, 0, 0, 0, 0, 0, 0, 0];
    for (var index = byteArray.length - 1; index >= 0; index--) {
      var byte = long & 0xff;
      byteArray[index] = byte;
      long = (long - byte) ~/ 256;
    }
    return byteArray;
  }
}