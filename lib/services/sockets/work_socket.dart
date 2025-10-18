import 'dart:io' as IO;
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'package:socket_io_client/socket_io_client.dart';

import '../../global_variables.dart';

class WorkSocket {
  static final WorkSocket _instance = WorkSocket._internal();
  static IO.Socket? _socket;
  WorkSocket._internal();
  factory WorkSocket(){
    return _instance;
  }
  static void initSocketConnection(){
    if (_socket != null && _socket!.connected) return; // Tránh reconnect nếu đã connect
    _socket = IO.io(
      // 'http://192.168.1.3:3000',
        uri,
        IO.OptionBuilder().setTransports(['websocket']).build()
    );
    _socket!
      ..onConnect((_) => print('✅Work Socket connected'))
      ..onDisconnect((_) => print('🔌 Socket disconnected'))
      ..onConnectError((e) => print('❌ Socket connect error: $e'))
      ..onError((e) => print('❌ General socket error: $e'));
  }
  // static void listenUserUpdateWork(Function onWorkUpdated) {
  //   _socket?.on('work_checkIn', (data) {
  //     print('👂 work_checkIn updated event received');
  //     onWorkUpdated();
  //   });
  // }
  static void listenUserUpdateCheckInWork(Function(Map<String, dynamic>) callback) {
    _socket?.on('work_checkIn', (data) {
      print('👂 work_checkIn received: $data');
      if (data != null && data is Map) {
        callback(Map<String, dynamic>.from(data));
      } else {
        print('Invalid work_checkIn data: $data');
      }
    });
  }
  static void listenUserUpdateCheckOutWork(Function(Map<String, dynamic>) callback) {
    _socket?.on('work_checkOut', (data) {
      print('👂 work_checkOut received: $data');
      if (data != null && data is Map) {
        callback(Map<String, dynamic>.from(data));
      } else {
        print('Invalid work_checkOut data: $data');
      }
    });
  }
  static void dispose() {
    _socket?.dispose();
  }
}