import 'dart:convert';
import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/models/message.dart';
import 'package:daily_manage_user_app/providers/admin/admin_messages_provider.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:http/http.dart' as http;
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import '../../../../models/user.dart';
import '../../../../providers/family_provider/chat_paramaters.dart';
import '../../../common_screens/widgets/typing_effect_widget.dart';
import '../chatbot_overlay_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  ChatbotScreen({super.key, required this.roomId, required this.senderId});

  final String roomId;
  final String senderId;

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final TextEditingController _controller = TextEditingController();
  final AdminChatbotController adminChatbotController =
      AdminChatbotController();

  // final List<Message> _messages = []; // Danh sách messages
  bool _isBotTyping = false;

  // TẠO THAM SỐ MỘT LẦN DUY NHẤT KHI STATE ĐƯỢC KHỞI TẠO
  late final ChatParameters chatParams;

  // final RefreshController _refreshController = RefreshController();
  // File: ChatbotScreen.dart

  // <<< THÊM MỚI >>>
  // scrool tin nhắn.
  final ScrollController _scrollController = ScrollController();
  bool _isInitialLoad = true; // Biến cờ để chỉ cuộn xuống dưới 1 lần đầu
  bool _isLoadingMore = false; // Cờ cho việc tải tin nhắn cũ hơn

  // <<< BƯỚC 1: THÊM BIẾN CỜ NÀY animate cho text >>>
  bool _shouldAnimateNextBotMessage = false;
  @override
  void initState() {
    super.initState();

    // _loadCurrentUser();

    // Tạo đối tượng tham số từ các thuộc tính của widget
    chatParams = ChatParameters(
      roomId: widget.roomId,
      senderId: widget
          .senderId, // Lấy ID người dùng từ UserProvider hoặc SharedPreferences
    );
    // <<< THÊM MỚI: Lắng nghe sự kiện scroll >>>
    _scrollController.addListener(_scrollListener);
  }

  // Nó sẽ được tự động gọi mỗi khi người dùng cuộn.
  void _scrollListener() async {
    // Kiểm tra xem người dùng có cuộn lên trên cùng của danh sách không
    if (_scrollController.position.pixels ==
        _scrollController.position.minScrollExtent) {
      final messageNotifier = ref.read(
        adminMessagesProvider(chatParams).notifier,
      );

      // Chỉ tải thêm khi không đang trong quá trình tải và khi vẫn còn tin nhắn để tải
      if (!_isLoadingMore && messageNotifier.hasMore) {
        // Bắt đầu quá trình tải, cập nhật UI để hiển thị vòng xoay loading
        setState(() {
          _isLoadingMore = true;
        });

        // Lưu lại chiều cao của danh sách cũ để "ghim" vị trí
        final oldMaxScrollExtent = _scrollController.position.maxScrollExtent;

        // Gọi hàm tải thêm tin nhắn
        await messageNotifier.loadMoreMessages();

        // Sau khi tải xong và UI build lại, nhảy đến vị trí mới để giữ màn hình đứng yên
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            final newMaxScrollExtent =
                _scrollController.position.maxScrollExtent;
            final addedContentHeight = newMaxScrollExtent - oldMaxScrollExtent;
            _scrollController.jumpTo(addedContentHeight);
          }
        });

        // Kết thúc quá trình tải
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
        }
      }
    }
  }

  Future<List<Message>> sendMessageToRasa(String message) async {
    final url = Uri.parse("http://192.168.1.237:5005/webhooks/rest/webhook");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"sender": "user123", "message": message}),
    );

    if (response.statusCode == 200) {
      print('Full response data: ${response.body}');
      final data = jsonDecode(response.body) as List;

      if (data.isNotEmpty) {
        // ⭐⭐⭐ LOGIC XỬ LÝ LINH HOẠT BẮT ĐẦU TỪ ĐÂY ⭐⭐⭐

        final List<Message> finalMessages = [];
        int i = 0;

        // Dùng vòng lặp while để kiểm soát index một cách linh hoạt
        while (i < data.length) {
          final currentItem = data[i] as Map<String, dynamic>;

          // Kiểm tra xem đây có phải là một cặp dữ liệu bị lỗi hay không
          // Điều kiện: item hiện tại có 'text', item tiếp theo tồn tại và có 'custom'
          if (i + 1 < data.length &&
              currentItem.containsKey('text') &&
              !currentItem.containsKey('custom')) {
            final nextItem = data[i + 1] as Map<String, dynamic>;
            if (nextItem.containsKey('custom') &&
                !nextItem.containsKey('text')) {
              // ---- TRƯỜNG HỢP 1: XỬ LÝ DỮ LIỆU BỊ CẶP ----
              print("Phát hiện cặp dữ liệu rời rạc, đang tiến hành ghép...");
              final text = currentItem['text'] as String? ?? '';
              final customData =
                  nextItem['custom'] as Map<String, dynamic>? ?? {};

              Message messageRes = Message(
                id:
                    customData['id'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                roomId:
                    customData['roomId'] ??
                    DateTime.now().millisecondsSinceEpoch.toString(),
                text: text,
                date: customData['date'] != null
                    ? DateTime.parse(customData['date'])
                    : DateTime.now(),
                senderId: customData['senderId'] ?? 'bot',
                router: customData['router'],
                textRouter: customData['textRouter'],
              );
              finalMessages.add(messageRes);

              Message? dataUpload = await adminChatbotController.askChatbot(
                roomId: widget.roomId,
                text: text,
                router: messageRes.router,
                textRouter: messageRes.textRouter,
              );
              await ref
                  .read(adminMessagesProvider(chatParams).notifier)
                  .addMessage(
                    Message(
                      id: '',
                      roomId: widget.roomId,
                      text: text,
                      senderId: '68ec68f8c7246d5addf76245',
                      router: messageRes.router,
                      textRouter: messageRes.textRouter,
                    ),
                  );
              _scrollToBottom();
              if (dataUpload != null) {
                showTopNotification(
                  context: context,
                  message: 'upload message success',
                  type: NotificationType.success,
                );
              } else {
                showTopNotification(
                  context: context,
                  message: 'upload message error',
                  type: NotificationType.error,
                );
              }

              // Đã xử lý 2 item, nhảy index qua 2
              i += 2;
              continue; // Bỏ qua phần còn lại và bắt đầu vòng lặp tiếp theo
            }
          }

          // ---- TRƯỜNG HỢP 2: XỬ LÝ TIN NHẮN MẶC ĐỊNH / ĐÚNG ----
          // Nếu không rơi vào trường hợp trên, xử lý item như một tin nhắn bình thường
          print("Đang xử lý tin nhắn đơn lẻ...");
          final customData =
              currentItem['custom'] as Map<String, dynamic>? ?? {};
          Message messageRes = Message(
            id:
                customData['id'] ??
                DateTime.now().millisecondsSinceEpoch.toString(),
            roomId: widget.roomId,
            text: currentItem['text'] ?? '',
            date: customData['date'] != null
                ? DateTime.parse(customData['date'])
                : DateTime.now(),
            senderId: customData['senderId'] ?? 'bot',
            router: customData['router'],
            textRouter: customData['textRouter'],
          );
          finalMessages.add(messageRes);
          await ref
              .read(adminMessagesProvider(chatParams).notifier)
              .addMessage(
                Message(
                  id: '',
                  roomId: widget.roomId,
                  text: currentItem['text'] ?? '',
                  senderId: '68ec68f8c7246d5addf76245',
                ),
              );

          Message? dataUpload = await adminChatbotController.askChatbot(
            roomId: widget.roomId,
            text: messageRes.text,
            router: messageRes.router,
            textRouter: messageRes.textRouter,
          );

          if (dataUpload != null) {
            showTopNotification(
              context: context,
              message: 'upload message success',
              type: NotificationType.success,
            );
          } else {
            showTopNotification(
              context: context,
              message: 'upload message error',
              type: NotificationType.error,
            );
          }
          // Chỉ xử lý 1 item, nhảy index qua 1
          i += 1;
        }

        // Log để debug
        for (var msg in finalMessages) {
          print(
            'Message-response (final): ${msg.text} | Router: ${msg.router ?? 'None'}  | Text Router: ${msg.textRouter ?? 'None'}',
          );
        }
        print('length messages (final): ${finalMessages.length}');

        return finalMessages;

        // ⭐⭐⭐ LOGIC XỬ LÝ KẾT THÚC ⭐⭐⭐
      } else {
        return [
          // Message(
          //   id: '',
          //   roomId: widget.roomId,
          //   text: "Bot không hiểu bạn nói gì.",
          //   date: DateTime.now(),
          //   senderId: 'bot',
          // ),
        ];
      }
    } else {
      return [
        // Message(
        //   id: '',
        //   roomId: widget.roomId,
        //   text: "Không thể kết nối đến chatbot.",
        //   date: DateTime.now(),
        //   senderId: 'bot',
        // ),
      ];
    }
  }

  // <<< THÊM MỚI: Hàm chuyên để cuộn xuống dưới cùng >>>
  void _scrollToBottom() {
    // Sử dụng một độ trễ nhỏ (50ms) để đảm bảo ListView đã được build xong
    // với tin nhắn mới trước khi chúng ta thực hiện lệnh cuộn.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Chỉ thực hiện khi controller đã được gắn vào một ListView
      if (_scrollController.hasClients) {
        // Lấy giá trị padding dưới của ListView
        final bottomPadding = 100.0; // Tương ứng với EdgeInsets.all(12)
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + bottomPadding, // Bây giờ, giá trị này đã được cập nhật chính xác
          duration: const Duration(milliseconds: 300), // Tốc độ cuộn
          curve: Curves.easeOut, // Hiệu ứng cuộn mượt mà
        );
      }
    });
  }

  // Thêm message của user vào list
  void _addUserMessage(String text) async {
    await ref
        .read(adminMessagesProvider(chatParams).notifier)
        .addMessage(
          Message(
            id: '',
            roomId: widget.roomId,
            text: text,
            senderId: widget.senderId,
          ),
        );

    final result = await adminChatbotController.requestMessage(
      roomId: widget.roomId,
      text: text,
    );
    if (result != null) {
      setState(() {});
    } else {
      showTopNotification(
        context: context,
        message: 'Gửi tin nhắn thất bại',
        type: NotificationType.error,
      );
    }
  }

  // Gửi message và thêm response bot
  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty) return;

    final userMessage = _controller.text;
    _controller.clear();

    // 2. GỌI HÀM CUỘN XUỐNG NGAY LẬP TỨC
    _scrollToBottom();

    _addUserMessage(userMessage); // Thêm message user

    // chúng ta lại gọi hàm cuộn xuống một lần nữa để xem câu trả lời của bot.
    _scrollToBottom();

    // Hiển thị "Bot đang trả lời..."
    setState(() {
      _isBotTyping = true;
      // <<< BƯỚC 2: KÍCH HOẠT CỜ HIỆU ỨNG >>>
      _shouldAnimateNextBotMessage = true;

    });

    // Gọi Rasa
    final botMessages = await sendMessageToRasa(userMessage);
    setState(() {
      // _messages.addAll(botMessages); // Thêm tất cả messages từ bot
    });

    // Tắt "Bot đang trả lời..." và thêm tin nhắn của bot
    setState(() {
      _isBotTyping = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 2. Watch provider bằng cách truyền tham số vào
    final messagesState = ref.watch(adminMessagesProvider(chatParams));

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
      child: Column(
        children: [
          // --- APP BAR ---
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16),
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ), // <-- Thêm dòng này
              color: HelpersColors.itemCard,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // SizedBox(width: 10),
                Container(
                  padding: EdgeInsets.all(10),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(width: 2, color: HelpersColors.itemCard),
                  ),
                  child: Lottie.asset(
                    'assets/lotties/chatbot.json',
                    repeat: true,
                  ),
                ),
                SizedBox(width: 20),
                Text(
                  "Daily Chatbot AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: messagesState.when(
              // TRẠNG THÁI 1: ĐANG TẢI DỮ LIỆU
              loading: () => const Center(child: CircularProgressIndicator()),

              // TRẠNG THÁI 2: CÓ LỖI XẢY RA
              error: (error, stackTrace) =>
                  Center(child: Text("Lỗi tải tin nhắn: $error")),
              data: (messages) {
                // <<< THÊM LOGIC ĐỂ CUỘN XUỐNG DƯỚI KHI VÀO MÀN HÌNH >>>
                if (_isInitialLoad) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {

                    if (_scrollController.hasClients) {
                      // Lấy giá trị padding dưới tương tự
                      final bottomPadding = 100.0;

                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent + bottomPadding,
                      );
                      // Sau khi đã jump (hoặc không), cập nhật lại UI để hiện list
                      if (mounted) {
                        setState(() {
                          _isInitialLoad = false; // Tắt cờ đi để hiện list
                        });
                      }
                    }
                  });
                }
                return Opacity(
                  opacity: _isInitialLoad ? 0.0 : 1.0,
                  child: ListView.builder(
                    controller: _scrollController,
                    // reverse: true,
                    padding: EdgeInsets.all(12),
                    itemCount: messages.length + (_isBotTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (_isBotTyping && index == messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Lottie.asset(
                                  'assets/lotties/loadingg.json',
                                  width: 70,
                                  repeat: true,
                                ),
                                SizedBox(width: 10),
                                Text("🤖 Bot đang trả lời..."),
                              ],
                            ),
                          ),
                        );
                      }
                      final message = messages[index];
                      final isUser = message.senderId == widget.senderId;
                      // <<< THÊM MỚI: Biến để xác định tin nhắn cuối cùng >>>
                      final isNewestMessage = index == messages.length - 1;
                      return Align(
                        alignment: isUser
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.all(12),
                          margin: EdgeInsetsGeometry.only(
                            bottom: 4,
                            top: 4,
                            left: isUser ? 30 : 4,
                            right: isUser ? 4 : 30,
                          ),

                          decoration: BoxDecoration(
                            color: isUser
                                ? Colors.blueAccent
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Wrap(
                            children: [
                              // <<< THAY ĐỔI LOGIC HIỂN THỊ TEXT >>>
                              // Nếu là tin nhắn của bot và là tin nhắn mới nhất, dùng hiệu ứng gõ chữ
                              // if (!isUser && isNewestMessage)
                              //   TypingEffectWidget(
                              //     fullText: message.text,
                              //     textStyle: TextStyle(color: Colors.black87),
                              //   )
                              if (!isUser && isNewestMessage && _shouldAnimateNextBotMessage)
                                AnimatedTextKit(
                                  animatedTexts: [
                                    TypewriterAnimatedText(
                                      message.text,
                                      textStyle: const TextStyle(
                                        color: Colors.black87,
                                        fontSize: 15.0,
                                      ),
                                      speed: const Duration(milliseconds: 50), // <-- Điều chỉnh tốc độ ở đây
                                      cursor: '▋', // <-- Tùy chỉnh con trỏ (hoặc để null nếu không muốn)
                                    ),
                                  ],
                                  totalRepeatCount: 1, // <-- Chỉ chạy 1 lần
                                  // pause: const Duration(milliseconds: 1000), // <-- Thời gian nghỉ trước khi lặp (không quan trọng vì chỉ chạy 1 lần)
                                  displayFullTextOnTap: true, // <-- Nhấn vào để hiện toàn bộ văn bản ngay lập tức
                                  stopPauseOnTap: true, // <-- Dừng animation khi người dùng nhấn vào
                                  // Quan trọng: Tắt cờ đi khi hiệu ứng đã chạy xong
                                  onFinished: () {
                                    if (mounted) {
                                      setState(() {
                                        _shouldAnimateNextBotMessage = false;
                                      });
                                    }
                                  },
                                )

                              // Ngược lại (tin nhắn của user hoặc tin nhắn cũ của bot), hiển thị bình thường
                              else
                                Text(
                                  message.text,
                                  style: TextStyle(
                                    color: isUser
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              if (!isUser &&
                                  message.textRouter != null &&
                                  message.router != null)
                                InkWell(
                                  child: Align(
                                    alignment: AlignmentDirectional.topEnd,
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(10),
                                        ),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            message.textRouter!,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: HelpersColors.itemCard,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Icon(
                                            CupertinoIcons.right_chevron,
                                            color: HelpersColors.itemCard,
                                            size: 17,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      message.router!,
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Nhập tin nhắn...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                IconButton(
                  icon: Icon(Icons.send, color: Colors.blueAccent),
                  onPressed: _isBotTyping ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
