// import 'dart:developer';

// import 'package:signalr_core/signalr_core.dart';
// import 'package:socket/notification/local_notification_service.dart';

// class SocketService {
//   late HubConnection _connection;

//   SocketService();

//   Future<void> connect() async {
//     _connection =
//         HubConnectionBuilder()
//             .withUrl(
//               'https://api.ltc365.com/hub/notify',
//               HttpConnectionOptions(
//                 transport: HttpTransportType.webSockets,
//                 // serverTimeout: Duration(
//                 //   seconds: 120,
//                 // ), // ⬅️ Thời gian chờ tổng trước khi tự ngắt
//                 // pollTimeout: Duration(seconds: 60),
//                 logging: (level, message) => log('[SignalR] $message'),
//               ),
//             )
//             .build();

//     _registerListeners();

//     try {
//       await _connection.start();
//       log('✅ Connected to SignalR hub');
//     } catch (e, stackTrace) {
//       log('❌ Connection failed: ${e.runtimeType} - $e');
//       log('StackTrace: $stackTrace');
//     }
//   }

//   void _registerListeners() {
//     _connection.on('ReceiveMessage', (arguments) {
//       log('📩 Dữ liệu : $arguments');
//       LocalNotificationService().showNotification(
//         id: 52352,
//         title: "$arguments",
//         body: "$arguments",
//       );
//     });
//   }

//   Future<void> disconnect() async {
//     await _connection.stop();
//     log('🔌 Disconnected');
//   }
// }

// // // lib/services/socket_service.dart
// // import 'dart:developer';

// // // import 'package:socket/const/url.dart';
// // import 'package:socket_io_client/socket_io_client.dart' as IO;

// // class SocketService {
// //   static final SocketService _instance = SocketService._internal();
// //   factory SocketService() {
// //     return _instance;
// //   }
// //   SocketService._internal();
// //   bool _firstTimeInitialized = false;
// //   late IO.Socket _socket;
// //   String? _currentToken;

// //   ///[reConnectWithNewToken] must call [connect] before call this func
// //   void reConnectWithNewToken({required String token}) {
// //     if (_currentToken != token) {
// //       connect(token: token);
// //     }
// //   }

// //   void connect({String? token}) {
// //     _currentToken = token;
// //     disconnect();
// //     final optionBuilder = IO.OptionBuilder()
// //         .setTransports(['websocket'])
// //         .disableAutoConnect()
// //         .setReconnectionAttempts(5);

// //     if (token != null && token.isNotEmpty) {
// //       optionBuilder.setExtraHeaders({'Authorization': 'Bearer $token'});
// //     }

// //     _socket = IO.io(
// //       // Url.socketUrl, //ws
// //       "ws://api.ltc365.com/hub/notify",
// //       optionBuilder.build(),
// //     );

// //     _socket.connect();
// //     _setupSocketListeners();
// //     _firstTimeInitialized = true;
// //   }

// //   void emit(String event, dynamic data) {
// //     _socket.emit(event, data);
// //   }

// //   void disconnect() {
// //     if (_firstTimeInitialized && _socket.connected) {
// //       _socket.disconnect();
// //     }
// //   }

// //   void _setupSocketListeners() {
// //     _socket.onConnect((_) {
// //       log('Socket connected');
// //       _socket.emit('join', {'room': 'flutter_room'});
// //     });

// //     _socket.on('your_event', (data) {
// //       log('Received data: $data');
// //     });

// //     _socket.onDisconnect((_) {
// //       log('Socket disconnected');
// //     });

// //     _socket.onConnectError((error) {
// //       log('Connection error: $error');
// //     });

// //     _socket.onError((error) {
// //       log('Socket error: $error');
// //     });
// //   }
// // }
