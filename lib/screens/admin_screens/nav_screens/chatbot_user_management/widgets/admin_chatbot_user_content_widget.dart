import 'package:daily_manage_user_app/controller/admin/admin_chatbot_controller.dart';
import 'package:daily_manage_user_app/helpers/tools_colors.dart';
import 'package:daily_manage_user_app/providers/admin/admin_document_provider.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/chatbot_user_management/widgets/admin_chatbot_user_documents_widget.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/chatbot_user_management/widgets/admin_chatbot_user_statistical_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/button_icon_text_widget.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../models/document.dart';
// Giả sử bạn có file này từ quy trình trước (để gọi API upload)
// import 'package:daily_manage_user_app/services/file_uploader_service.dart';

class AdminChatbotUserContentWidget extends ConsumerStatefulWidget {
  const AdminChatbotUserContentWidget({super.key});

  @override
  _AdminChatbotUserContentWidgetState createState() =>
      _AdminChatbotUserContentWidgetState();
}

class _AdminChatbotUserContentWidgetState
    extends ConsumerState<AdminChatbotUserContentWidget> {
  // Biến giả lập, bạn sẽ lấy thông tin này từ API
  int _chunkCount = 165;
  int _fileCount = 2;
  bool _isLoading = false;
  AdminChatbotController adminChatbotController = AdminChatbotController();
  // Hàm này sẽ gọi service `FileUploader` mà chúng ta đã thảo luận
  void _onUploadPDF() async {
    // 1. Gọi FileUploader.pickAndUploadFiles(context);
    // 2. setState(() { _isLoading = true; });
    // 3. Sau khi upload xong:
    //    - Cập nhật lại _chunkCount và _fileCount từ response
    //    - setState(() { _isLoading = false; });
    //    - Hiển thị SnackBar/Dialog thông báo thành công
    print("Bắt đầu quá trình upload...");
    // (Hiện tại chỉ là giả lập)
  }

  // Hàm này sẽ gọi endpoint /clear_database
  void _onClearAllKnowledge() async {
    // 1. Hiển thị Dialog xác nhận (RẤT QUAN TRỌNG)
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận Xóa?"),
        content: Text(
          "Bạn có chắc muốn xóa toàn bộ kiến thức của chatbot? Hành động này không thể hoàn tác.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text("Hủy"),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: Text("Xóa"),
          ),
        ],
      ),
    );

    // 2. Nếu người dùng xác nhận
    if (confirm == true) {
      // 3. setState(() { _isLoading = true; });
      // 4. Gọi API (Dio) đến endpoint "/clear_database"
      // 5. Sau khi xong:
      //    - setState(() { _chunkCount = 0; _fileCount = 0; _isLoading = false; });
      //    - Hiển thị thông báo "Đã xóa thành công"
      print("Đã xóa toàn bộ kiến thức...");
    }
  }

  // (Đây là hàm giả lập, vì backend của chúng ta chưa hỗ trợ xóa file riêng lẻ)
  void _onDeleteSingleFile(String fileName) {
    // Khi bạn nâng cấp backend, đây là nơi gọi API xóa 1 file
    print("Xóa file: $fileName");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // 2. BODY
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- BỐ CỤC PHẦN 1: THẺ TRẠNG THÁI ---
          AdminChatbotUserStatisticalWidget(),
          const SizedBox(height: 16),

          // --- BỐ CỤC PHẦN 2: CÁC NÚT HÀNH ĐỘNG ---
          _buildActionButtons(context),
          const SizedBox(height: 24),

          // --- BỐ CỤC PHẦN 3: DANH SÁCH FILE ĐÃ TẢI LÊN ---
          Text(
            "Cơ sở kiến thức (Tài liệu đã tải lên)",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 10),
          // _buildKnowledgeList(context),
          Expanded(child: AdminChatbotUserDocumentsWidget())
        ],
      ),
    );
  }


  // Widget con cho 2 Nút Hành động
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Nút Tải lên
        // Expanded(
        //   child: FilledButton.icon(
        //     onPressed: _isLoading ? null : _onUploadPDF,
        //     icon: Icon(Icons.upload_file),
        //     label: Text("Tải lên PDF"),
        //     style: FilledButton.styleFrom(
        //       padding: const EdgeInsets.symmetric(vertical: 16),
        //       shape: RoundedRectangleBorder(
        //           borderRadius: BorderRadius.circular(10)),
        //     ),
        //   ),
        // ),
        Expanded(
          child: ButtonIconTextWidget(
            icon: Icons.upload_file_rounded,
            text: 'Upload PDF',
            color: Colors.white,
            background: HelpersColors.itemCard,
            onTap: () async{
              // 1. Gọi hàm upload, kết quả có thể là null
              final List<Document>? dataPdf = await adminChatbotController.pickAndUploadPdfMulti();

              // 2. PHẢI kiểm tra null (và rỗng)
              if (dataPdf != null && dataPdf.isNotEmpty) {

                // 3. Dùng vòng lặp for...in (rõ ràng nhất)
                for (final document in dataPdf) {
                  ref.read(adminDocumentProvider.notifier).addDocumentToTop(document);
                }

                /* // HOẶC CÓ THỂ DÙNG forEach (sửa từ .map)
    dataPdf.forEach((document) {
      ref.read(adminDocumentProvider.notifier).addDocumentToTop(document);
    });
    */

              } else {
                // Người dùng đã hủy hoặc upload thất bại
                print("Không có file nào được upload.");
              }
            },
          ),
        ),
        const SizedBox(width: 10),
        // Nút Xóa tất cả
        Expanded(
          child: ButtonIconTextWidget(
            icon: Icons.delete_sweep,
            text: 'Delete all PDF',
            color: Colors.white,
            background: HelpersColors.itemSelected,
            onTap: () async{
              // await adminChatbotController.pickAndUploadFiles();
              // await adminChatbotController.pickAndUploadPdfSingle();
            },
          ),
        ),
      ],
    );
  }

  // Widget con cho Danh sách file
  // (Lưu ý: Backend hiện tại của chúng ta chưa hỗ trợ lấy danh sách file,
  // đây là bố cục giả lập cho đến khi bạn nâng cấp backend)
  Widget _buildKnowledgeList(BuildContext context) {
    if (_fileCount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text("Chưa có tài liệu nào. Hãy tải lên file PDF đầu tiên."),
        ),
      );
    }

    // Đây là danh sách giả lập
    final List<Map<String, dynamic>> fakeFiles = [
      {"name": "noi-quy-lao-dong-v1.pdf", "chunks": _chunkCount > 0 ? 120 : 0},
      {"name": "phu-luc-hop-dong-2025.pdf", "chunks": _chunkCount > 0 ? 45 : 0},
    ];

    return ListView.builder(
      itemCount: _fileCount,
      shrinkWrap: true, // Cho phép ListView nằm trong SingleChildScrollView
      physics: NeverScrollableScrollPhysics(), // Để ScrollView cha cuộn
      itemBuilder: (context, index) {
        final file = fakeFiles[index];
        return Card(
          elevation: 1,
          margin: const EdgeInsets.only(bottom: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          child: ListTile(
            leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade700),
            title: Text(file["name"]),
            subtitle: Text("${file["chunks"]} đoạn (chunks)"),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.grey.shade600),
              onPressed: () => _onDeleteSingleFile(file["name"]),
            ),
          ),
        );
      },
    );
  }
}
