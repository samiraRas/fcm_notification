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
  print(message.data);
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
  String? token;
  List subscribed = [];
  List topics = ["Apple", "Lenovo", "Samsung", "Vivo", "Oppo", "Nokia"];
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  getTokenfromFirebase() async {
    token = await FirebaseMessaging.instance.getToken();
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

    // var initializationSettings;
    // flutterNotificationPlugin.initialize(initializationSettings);
    // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    //   RemoteNotification? notification = message.notification;
    //   AndroidNotification? android = message.notification?.android;
    //   if (notification != null && android != null) {
    //     flutterNotificationPlugin.show(
    //       notification.hashCode,
    //       notification.title,
    //       notification.body,
    //       const NotificationDetails(
    //         android: AndroidNotificationDetails("id", "name",
    //             channelDescription: "this channel is importance"),
    //       ),
    //     );
    //   }
    // });
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
                            .set({topics[index]: "subscribe"});

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

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({Key? key, required this.title}) : super(key: key);

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;


//   getTokenz() async {}
//   @override
//   void initState() {
    
//     // FirebaseMessaging.instance.getInitialMessage().then(
//     //   (message) {
//     //     print("FirebaseMessaging.instance.getInitialMessage");
//     //     if (message != null) {
//     //       print("New Notification");
//     //       // if (message.data['_id'] != null) {
//     //       //   Navigator.of(context).push(
//     //       //     MaterialPageRoute(
//     //       //       builder: (context) => DemoScreen(
//     //       //         id: message.data['_id'],
//     //       //       ),
//     //       //     ),
//     //       //   );
//     //       // }
//     //     }
//     //   },
//     // );

//     // // 2. This method only call when App in forground it mean app must be opened
//     // FirebaseMessaging.onMessage.listen(
//     //   (message) {
//     //     print("FirebaseMessaging.onMessage.listen");
//     //     if (message.notification != null) {
//     //       print(message.notification!.title);
//     //       print(message.notification!.body);
//     //       print("message.data11 ${message.data}");
//     //       // LocalNotificationService.display(message);

//     //     }
//     //   },
//     // );

//     // // 3. This method only call when App in background and not terminated(not closed)
//     // FirebaseMessaging.onMessageOpenedApp.listen(
//     //   (message) {
//     //     print("FirebaseMessaging.onMessageOpenedApp.listen");
//     //     if (message.notification != null) {
//     //       print(message.notification!.title);
//     //       print(message.notification!.body);
//     //       print("message.data22 ${message.data['_id']}");
//     //     }
//     //   },
//     // );
//   }

//   void _incrementCounter() {
//     setState(() {
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
// }
