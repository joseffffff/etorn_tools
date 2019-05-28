import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() async {

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  _firebaseMessaging.requestNotificationPermissions();
  _firebaseMessaging.configure(
    // {notification: {title: Aloha, body: Testing flutter notifications}, data: {}}
      onMessage: (Map<String, dynamic> message) async {
        _showNotification(message);
      },
      onResume: (Map<String, dynamic> message) async {
        _showNotification(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        _showNotification(message);
      }
  );

  String token = await _firebaseMessaging.getToken();
  print("fcm token is: $token");

  runApp(MyApp(token));
}

Future _showNotification(Map<String, dynamic> message) async {
  var androidPlatformChannelSpecifics = new AndroidNotificationDetails(
      'your channel id',
      'your channel name',
      'your channel description',
      playSound: true,
      importance: Importance.Max,
      priority: Priority.High
  );

  var iOSPlatformChannelSpecifics = new IOSNotificationDetails(
      presentSound: true);

  var platformChannelSpecifics = new NotificationDetails(
      androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
// // {notification: {title: Aloha, body: Testing flutter notifications}, data: {}}

  var noti = message['notification'];

  var settingsAndroid = new AndroidInitializationSettings('@mipmap/logo');
  var settingsIOS = new IOSInitializationSettings();

  var settings = new InitializationSettings(settingsAndroid, settingsIOS);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();

  flutterLocalNotificationsPlugin.initialize(
      settings,
      onSelectNotification: onSelectNotification
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    noti['title'],
    noti['body'],
    platformChannelSpecifics,
    payload: 'No_Sound',
  );
}

Future onSelectNotification(String payload) async {
  showDialog(
      context: null,
      builder: (_) => new AlertDialog(
          title: const Text('Your payload'),
          content: new Text('Payload: ' + payload)
      )
  );
}

class MyApp extends StatelessWidget {

  String token;

  MyApp(String token) {
      this.token = token;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'eTorn App!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'eTorn App!', token: token),
    );
  }
}

class MyHomePage extends StatefulWidget {

  MyHomePage({Key key, this.title, String token}) : this.token = token, super(key: key);

  final String title;
  String token;

  @override
  _MyHomePageState createState() => _MyHomePageState(token);
}

class _MyHomePageState extends State<MyHomePage> {

  final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  String token;

  WebView webview;

  _MyHomePageState(String token): this.token = token;

  @override
  void initState() {
    super.initState();
    webview = WebView();
    firebaseCloudMessaging_Listeners();
  }



  Future firebaseCloudMessaging_Listeners() async {
    if (Platform.isIOS) iOS_Permission();

    webview = WebView(
        key: UniqueKey(),
        javascriptMode: JavascriptMode.unrestricted,
        initialUrl: ('http://51.77.230.192:8080/#/?token=' + token)
    );

  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings(sound: true, badge: true, alert: true)
    );
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
          print("Settings registered: $settings");
        });
  }



  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: webview
          )
        ]
      )
    );
  }
}
