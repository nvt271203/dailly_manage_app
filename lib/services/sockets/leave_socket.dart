import 'dart:io' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:socket_io_client/socket_io_client.dart';
import 'package:daily_manage_user_app/services/sockets/socket_service.dart';

import '../../global_variables.dart';

class LeaveSocket {
  static final LeaveSocket _instance = LeaveSocket._internal();
  static IO.Socket? _socket;
  LeaveSocket._internal();
  factory LeaveSocket(){
    return _instance;
  }
  static void initSocketConnection(){
    _socket = IO.io(
      // 'http://192.168.1.3:3000',
        uri,
        IO.OptionBuilder().setTransports(['websocket']).build()
    );
    _socket!
      ..onConnect((_) => print('✅ Leave Socket connected'))
      ..onDisconnect((_) => print('🔌 Socket disconnected'))
      ..onConnectError((e) => print('❌ Socket connect error: $e'))
      ..onError((e) => print('❌ General socket error: $e'));
  }
  // static void listenUserUpdateLeave(Function onLeaveUpdated) {
  //   _socket?.on('leave_updated', (data) {
  //     print('👂 CheckIn updated event received');
  //     onLeaveUpdated();
  //   });
  // }

  // User sent emit
  static void listenNewLeaveRequest(Function(Map<String, dynamic>) callback) {
    _socket?.on('leave_request', (data) {
      print('👂 leave_request received: $data');
      if (data != null && data is Map) {
        callback(Map<String, dynamic>.from(data));
      } else {
        print('Invalid leave_request data: $data');
      }
    });
  }

  // Admin sent emit
  static void listenUpdatedLeaveRequest(Function(Map<String, dynamic>) callback) {
    _socket?.on('leave_request_status_update', (data) {
      print('👂 leave_request_status_update received: $data');
      if (data != null && data is Map) {
        callback(Map<String, dynamic>.from(data));
      } else {
        print('Invalid leave_request_status_update data: $data');
      }
    });
  }

  static void dispose() {
    _socket?.dispose();
  }
}