// lib/background/background_service.dart
import 'dart:developer';
import 'dart:ui';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

// Move the callback functions outside the class as top-level functions
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  log('onstart bg service');
  if (service is AndroidServiceInstance) {
    service.on('stopService').listen((event) {
      service.stopSelf();
    });
  }

  // Kết nối socket
  // SocketService().connect();

  service.invoke('update', {'message': 'Đây là dữ liệu từ background'});

  service.on('update').listen((event) {
    log('event Update');
    log('Service still running... ${event.toString()}');
  });
}

class BackgroundService {
  BackgroundService._internal();
  static BackgroundService _instance = BackgroundService._internal();

  factory BackgroundService() {
    return _instance;
  }

  Future<void> initializeService() async {
    log('message1');
    final service = FlutterBackgroundService();
    log('message2');
    await service.configure(
      androidConfiguration: AndroidConfiguration(
        autoStart: true,
        onStart: onStart,
        isForegroundMode: false,
        autoStartOnBoot: true,
        // notificationChannelId: 'my_foreground',
        // initialNotificationTitle: 'Flutter Background Service',
        // initialNotificationContent: 'Service is running',
      ),
      iosConfiguration: IosConfiguration(
        autoStart: true,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
    log('message3');
    service.startService();
    log('message4');
  }
}
