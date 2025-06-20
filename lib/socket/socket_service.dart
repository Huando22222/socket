// lib/services/socket_service.dart
import 'dart:developer';

import 'package:socket/const/url.dart';
import 'package:socket/notification/local_notification_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() {
    return _instance;
  }
  SocketService._internal();
  bool _firstTimeInitialized = false;
  late IO.Socket _socket;
  String? _currentToken;

  ///[reConnectWithNewToken] must call [connect] before call this func
  void reConnectWithNewToken({required String token}) {
    if (_currentToken != token) {
      connect(token: token);
    }
  }

  void connect({String? token}) {
    _currentToken = token;
    disconnect();
    final optionBuilder = IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .setReconnectionAttempts(5);

    if (token != null && token.isNotEmpty) {
      optionBuilder.setExtraHeaders({'Authorization': 'Bearer $token'});
    }

    _socket = IO.io(
      Url.socketUrl, //ws
      optionBuilder.build(),
    );

    _socket.connect();
    _setupSocketListeners();
    _firstTimeInitialized = true;
  }

  void emit(String event, dynamic data) {
    _socket.emit(event, data);
  }

  void disconnect() {
    if (_firstTimeInitialized && _socket.connected) {
      _socket.disconnect();
    }
  }

  void _setupSocketListeners() {
    // _socket.onconnect(id, pid)
    _socket.onConnect((_) async {
      await LocalNotificationService().showNotification(
        id: 8,
        title: 'socket',
        body: 'ket noi socket thanh cong',
      );
      log('Socket connected');
      _socket.emit('join', {'room': 'flutter_room'});
    });

    _socket.on('your_event', (data) {
      log('Received data: $data');
    });

    _socket.onDisconnect((_) {
      log('Socket disconnected');
    });

    _socket.onConnectError((error) {
      log('Connection error: $error');
    });

    _socket.onError((error) {
      log('Socket error: $error');
    });
  }
}
