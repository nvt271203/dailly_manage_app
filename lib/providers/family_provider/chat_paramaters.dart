// Bạn có thể đặt class này ở cùng file provider hoặc một file riêng
import 'package:equatable/equatable.dart';

// Dùng Equatable để Riverpod biết khi nào tham số giống hệt nhau
class ChatParameters extends Equatable {
  final String roomId;
  final String senderId;

  const ChatParameters({required this.roomId, required this.senderId});

  @override
  List<Object?> get props => [roomId, senderId];
}