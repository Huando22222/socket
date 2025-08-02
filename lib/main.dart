// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
// import 'package:socket/background/background_service.dart';
// import 'package:socket/socket/socket_service.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   // await BackgroundService().initializeService();
//   await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//       ),
//       home: const MyHomePage(),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key});

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             ElevatedButton(
//               onPressed: () async {
//                 final BackgroundService backgroundService = BackgroundService();
//                 await backgroundService.initializeService();
//               },
//               child: Text("chạy background && connect socket"),
//             ),
//             ElevatedButton(onPressed: () {}, child: Text("send event")),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'dart:developer';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'dart:io';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'SignalR Test', home: SignalRTest());
  }
}

class SignalRTest extends StatefulWidget {
  @override
  _SignalRTestState createState() => _SignalRTestState();
}

class _SignalRTestState extends State<SignalRTest> {
  HubConnection? hubConnection;
  List<String> messages = [];
  TextEditingController messageController = TextEditingController();
  bool isConnected = false;
  bool isConnecting = false;

  @override
  void initState() {
    super.initState();

    addMessage("App started. Click Connect to connect to server.");
  }

  void addMessage(String message) {
    log(message);
    setState(() {
      messages.add("${DateTime.now().toString().substring(11, 19)} - $message");
    });
  }

  void connectToHub() async {
    if (isConnecting || isConnected) return;

    setState(() {
      isConnecting = true;
    });

    addMessage("Connecting to server...");

    try {
      // Configure HttpClient to ignore SSL certificate errors
      HttpOverrides.global = MyHttpOverrides();

      hubConnection =
          HubConnectionBuilder()
              // .withUrl(
              //   "https://api.ltc365.com/hub/notify",
              //   options: HttpConnectionOptions(
              //     transport: HttpTransportType.LongPolling,
              //   ),
              // )
              // .withUrl(
              //   "https://api.ltc365.com/hub/notify?userId=b9b3718c-4d01-47c7-bbb1-501c6e47317e",
              //   options: HttpConnectionOptions(
              //     transport: HttpTransportType.WebSockets,
              //   ),
              // )
              .withUrl("https://10.0.2.2:5001/hub/notify")
              // .withUrl("http://10.0.2.2:5000/hub/notify")
              .build();

      hubConnection!.on("Connected", (arguments) {
        addMessage("Server says: ${arguments![0]}");
      });

      hubConnection!.on("ReceiveMessage", (arguments) {
        addMessage("${arguments![0]}: ${arguments[1]}");
      });

      hubConnection!.on("BroadcastReceived", (arguments) {
        addMessage("Broadcast: ${arguments![0]}");
      });

      await hubConnection!.start();

      // hubConnection!.onclose(({error}) {
      //   log("$error");
      // });

      // hubConnection!.onreconnecting(({error}) {
      //   log("$error");
      // });

      // hubConnection!.onreconnected(({connectionId}) {
      //   log("$connectionId");
      // });

      setState(() {
        isConnected = true;
        isConnecting = false;
      });
      addMessage("✅ Connected to server successfully!");
    } catch (e) {
      log("$e");
      setState(() {
        isConnected = false;
        isConnecting = false;
      });
      addMessage("❌ Connection error: $e");
      addMessage("💡 Try using HTTP instead of HTTPS or check server");
    }
  }

  void disconnectFromHub() async {
    if (hubConnection != null) {
      await hubConnection!.stop();
      setState(() {
        isConnected = false;
        hubConnection = null;
      });
      addMessage("Disconnected from server");
    }
  }

  void sendMessage() {
    if (messageController.text.isNotEmpty &&
        isConnected &&
        hubConnection != null) {
      hubConnection!.invoke("SendMessage", args: [messageController.text]);
      addMessage("📤 Sent: ${messageController.text}");
      messageController.clear();
    } else if (!isConnected) {
      addMessage("❌ Not connected to server");
    }
  }

  void pingServer() {
    if (isConnected && hubConnection != null) {
      addMessage("📍 Sending ping...");
      hubConnection!.invoke("BroadcastMessage", args: ["Ping from Flutter!"]);
    } else {
      addMessage("❌ Not connected to server");
    }
  }

  void clearMessages() {
    setState(() {
      messages.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SignalR Test'),
        backgroundColor: isConnected ? Colors.green : Colors.red,
      ),
      body: Column(
        children: [
          // Connection Status
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16),
            color: isConnected ? Colors.green.shade100 : Colors.red.shade100,
            child: Text(
              isConnecting
                  ? "Connecting..."
                  : isConnected
                  ? "✅ Connected"
                  : "❌ Disconnected",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color:
                    isConnected ? Colors.green.shade800 : Colors.red.shade800,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Connection Buttons
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed:
                        isConnecting
                            ? null
                            : (isConnected ? disconnectFromHub : connectToHub),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isConnected ? Colors.red : Colors.green,
                    ),
                    child: Text(
                      isConnecting
                          ? "Connecting..."
                          : isConnected
                          ? "Disconnect"
                          : "Connect",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(onPressed: pingServer, child: Text('Ping')),
                SizedBox(width: 8),
                ElevatedButton(onPressed: clearMessages, child: Text('Clear')),
              ],
            ),
          ),

          // Messages List
          Expanded(
            child: Container(
              margin: EdgeInsets.all(8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              child:
                  messages.isEmpty
                      ? Center(child: Text("No messages"))
                      : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Text(
                              messages[index],
                              style: TextStyle(fontSize: 12),
                            ),
                          );
                        },
                      ),
            ),
          ),

          // Message Input
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: messageController,
                    decoration: InputDecoration(
                      hintText: 'Enter message',
                      border: OutlineInputBorder(),
                    ),
                    enabled: isConnected,
                    onSubmitted: (_) => sendMessage(),
                  ),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (hubConnection!.state ==
                        HubConnectionState.Disconnected) {
                      log("❌ Disconnected");
                    } else {
                      log("connected");
                    }
                  },
                  child: Text('check'),
                ),
                ElevatedButton(
                  onPressed: isConnected ? sendMessage : null,
                  child: Text('Send'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    hubConnection?.stop();
    super.dispose();
  }
}

// Class để ignore SSL certificate errors trong development
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}
