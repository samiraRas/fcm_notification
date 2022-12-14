import 'package:fcm_notification/local_notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

// import 'package:cloud_firestore_example/firebase_config.dart';

Future<void> backgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message ${message.messageId}");
  print("notification ${message.data}");
  print(message.data.toString());
  flutterNotificationPlugin.show(
      message.data.hashCode,
      message.data["title"],
      message.data["body"],
      const NotificationDetails(
          android: AndroidNotificationDetails("id", "name",
              channelDescription: "this is a important notification")));
  print(message.notification!.title);
}

//ch,
//  channel.name,
//  channelDescription: channel.descriptionm ,icon: android.smallIcon
AndroidNotificationChannel channel = const AndroidNotificationChannel(
    "id", "name",
    description: "this is a important notification");

final FlutterLocalNotificationsPlugin flutterNotificationPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  LocalNotificationService.initialize();
  FirebaseMessaging.onBackgroundMessage(backgroundHandler);
  await flutterNotificationPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'mRep7',
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? token;
  List subscribed = [];
  List topics = ["Apple", "Lenovo", "Samsung", "Vivo", "Oppo", "Nokia"];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  getTokenfromFirebase() async {
    token = await FirebaseMessaging.instance.getToken();
    print("token ashbei $token");
  }

  getTopics() async {
    await FirebaseFirestore.instance
        .collection('topics')
        .get()
        .then((value) => value.docs.forEach((element) {
              if (token == element.id) {
                subscribed = element.data().keys.toList();
              }
            }));
    setState(() {
      subscribed = subscribed;
    });
  }

  @override
  void initState() {
    super.initState();
    var token = _firebaseMessaging.getToken();
    print("token result${token}");
    var initializationSettingsAndroid =
        AndroidInitializationSettings("@mipmap/ic_launcher");
    var initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);
    flutterNotificationPlugin.initialize(initializationSettings);
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterNotificationPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails("id", "name",
                channelDescription: "this channel is importance"),
          ),
        );
      }
    });
    getTokenfromFirebase();
    getTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: topics.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(topics[index]),
              trailing: subscribed.contains(topics[index])
                  ? ElevatedButton(
                      onPressed: () async {
                        await FirebaseMessaging.instance
                            .unsubscribeFromTopic(topics[index]);

                        await FirebaseFirestore.instance
                            .collection("topics")
                            .doc(token)
                            .update({topics[index]: FieldValue.delete()});
                        setState(() {
                          subscribed.remove(topics[index]);
                        });
                      },
                      child: const Text("Unsubscribe"),
                    )
                  : ElevatedButton(
                      onPressed: () async {
                        await FirebaseMessaging.instance
                            .subscribeToTopic(topics[index]);

                        await FirebaseFirestore.instance
                            .collection("topics")
                            .doc(token)
                            .set({topics[index]: "subscribe"},
                                SetOptions(merge: true));

                        setState(() {
                          subscribed.add(topics[index]);
                        });
                      },
                      child: const Text("Subscribe"),
                    ),
            );
          }),
    );
  }
}
