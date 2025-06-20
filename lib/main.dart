import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:socket/background/background_service.dart';
import 'package:socket/notification/local_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundService().initializeService();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {},
              child: Text("chạy background && connect socket"),
            ),
            ElevatedButton(
              onPressed: () {
                FlutterBackgroundService().invoke('update', {
                  'event': 'chat_message',
                  'data': {'text': 'Xin chào từ UI'},
                });
              },
              child: Text("send background -> tao event -> socketIO"),
            ),

            ElevatedButton(
              onPressed: () async {
                // final res =
                await LocalNotificationService().requestPermissions();
                await LocalNotificationService().showNotification(
                  id: 4,
                  title: '2',
                  body: '55',
                );
                // await LocalNotificationService()
                //     .cancelAllNotifications();
              },
              child: Text("thong bao"),
            ),
          ],
        ),
      ),
    );
  }
}
