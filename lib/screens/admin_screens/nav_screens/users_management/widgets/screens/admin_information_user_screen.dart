import 'package:daily_manage_user_app/controller/admin/admin_position_controller.dart';
import 'package:daily_manage_user_app/controller/admin/admin_user_controller.dart';
import 'package:daily_manage_user_app/helpers/format_helper.dart';
import 'package:daily_manage_user_app/models/position.dart';
import 'package:daily_manage_user_app/providers/admin/admin_user_provider.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:drop_down_list/drop_down_list.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../controller/admin/admin_department_controller.dart';
import '../../../../../../helpers/tools_colors.dart';
import '../../../../../../models/department.dart';
import '../../../../../../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
class AdminInformationUserScreen extends ConsumerStatefulWidget {
  AdminInformationUserScreen({super.key, required this.user});

  User user;

  @override
  _AdminInformationUserScreenState createState() =>
      _AdminInformationUserScreenState();
}

class _AdminInformationUserScreenState
    extends ConsumerState<AdminInformationUserScreen> {
  bool _openBottomDialogDepartment = false;
  bool _openButtonSaveDepartment = false;
  bool _openButtonSavePosition = false;
  String? _selectedDepartmentId;
  String? _selectedDepartmentIdNotSave;
  String? _selectedPositionIdNotSave;
  // String? _departmentNameSelected;
  String _departmentNameSelected = '';
  String _departmentPositionSelected = '';
  String? _positionNameSelected;

  Widget _buildTextFile(String title) {
    return Container(
      margin: EdgeInsets.only(bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          color: HelpersColors.itemCard,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDevider(Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Container(height: 1, color: color.withOpacity(0.3)),
    );
  }

  Widget _buildBoxContent(IconData icon, String content, {bool valid = true}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: HelpersColors.bgFillTextField,
      ),
      child: Row(
        children: [
          Row(
            children: [
              Container(
                height: 48,
                width: 50,
                decoration: BoxDecoration(
                  color: HelpersColors.itemCard.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Icon(icon, size: 22, color: HelpersColors.itemCard),
              ),
              SizedBox(width: 15),
              Text(
                content.toString(),
                style: TextStyle(
                  color: valid ? Colors.black : HelpersColors.itemSelected,
                  fontSize: 13,
                ),
              ),
              SizedBox(width: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBoxContentDepartment(
    IconData icon,
    String content, {
    bool valid = true,
    required VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: HelpersColors.bgFillTextField,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 50,
                  decoration: BoxDecoration(
                    color: HelpersColors.itemCard.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 22, color: HelpersColors.itemCard),
                ),
                SizedBox(width: 15),
                Text(
                  content.toString(),
                  style: TextStyle(
                    color: valid ? Colors.black : HelpersColors.itemSelected,
                    fontSize: 13,
                  ),
                ),
                Spacer(),
                if (_openButtonSaveDepartment)
                  InkWell(
                    onTap: () async {
                      print('Before update: _selectedDepartmentId - $_selectedDepartmentIdNotSave');

                      final resultUpdate = await AdminUserController()
                          .requestUpdateUser(
                            id: widget.user.id,
                            departmentId: _selectedDepartmentIdNotSave!,
                          );

                      if (resultUpdate != null) {
                        ref
                            .read(adminUserProvider.notifier)
                            .updateUserDepartment(userId: widget.user.id, departmentId: _selectedDepartmentIdNotSave!);

                          print('After update: resultUpdate.departmentId - ${resultUpdate.departmentId}');

                        showTopNotification(
                          context: context,
                          message:
                              'Successfully updated "${_departmentNameSelected}" department',
                          type: NotificationType.success,
                        );
                        setState(() {
                          _openButtonSaveDepartment = false;
                          widget.user.positionId = null;
                          _selectedDepartmentId = resultUpdate.departmentId;
                        });
                      } else {
                        showTopNotification(
                          context: context,
                          message:
                              'Successfully failed "${_departmentNameSelected}" department',
                          type: NotificationType.error,
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: HelpersColors.itemCard,
                      ),
                      child: Icon(Icons.save, size: 18, color: Colors.white),
                    ),
                  ),
                SizedBox(width: 10),
                InkWell(
                  onTap: onEdit,
                  child: Container(
                    width: 30,
                    height: 30,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.all(Radius.circular(5)),
                    //   color: HelpersColors.itemCard
                    // ),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: HelpersColors.itemCard,
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoxContentPosition(
    IconData icon,
    String content, {
    bool valid = true,
    required VoidCallback onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        // color: HelpersColors.bgFillTextField,
      ),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  height: 48,
                  width: 50,
                  decoration: BoxDecoration(
                    color: HelpersColors.itemCard.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Icon(icon, size: 22, color: HelpersColors.itemCard),
                ),
                SizedBox(width: 15),
                Text(
                  content.toString(),
                  style: TextStyle(
                    color: valid ? Colors.black : HelpersColors.itemSelected,
                    fontSize: 13,
                  ),
                ),
                Spacer(),
                if (_openButtonSavePosition)
                  InkWell(
                    onTap: () async {
                      setState(() {
                        _openButtonSavePosition = true;
                      });
                      print('_selectedDepartmentId - ${_selectedDepartmentId}');
                      print('_selectedPositionIdNotSave - ${_selectedPositionIdNotSave}');
                      final resultUpdate = await AdminUserController()
                          .requestUpdateUser(
                            id: widget.user.id,
                            departmentId: _selectedDepartmentId!,
                        positionId: _selectedPositionIdNotSave

                          );
                      if (resultUpdate != null) {
                        ref
                            .read(adminUserProvider.notifier)
                            .updateUserPosition(userId: widget.user.id, departmentId: _selectedDepartmentId!, positionId: _selectedPositionIdNotSave!);
                        setState(() {
                          _openButtonSavePosition = false;
                        });
                        showTopNotification(
                          context: context,
                          message:
                              'Successfully updated "${_positionNameSelected}" position',
                          type: NotificationType.success,
                        );
                        setState(() {
                          _openButtonSavePosition = false;
                        });
                      } else {
                        showTopNotification(
                          context: context,
                          message:
                              'Successfully failed "${_positionNameSelected}" position',
                          type: NotificationType.error,
                        );
                      }
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        color: HelpersColors.itemCard,
                      ),
                      child: Icon(Icons.save, size: 18, color: Colors.white),
                    ),
                  ),
                SizedBox(width: 10),
                InkWell(
                  onTap: onEdit,
                  child: Container(
                    width: 30,
                    height: 30,
                    // decoration: BoxDecoration(
                    //   borderRadius: BorderRadius.all(Radius.circular(5)),
                    //   color: HelpersColors.itemCard
                    // ),
                    child: Icon(
                      Icons.expand_more_rounded,
                      color: HelpersColors.itemCard,
                    ),
                  ),
                ),
                SizedBox(width: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Định nghĩa hàm xử lý chức năng
  void handleEditDepartment() async {
    setState(() {
      _openBottomDialogDepartment = true;
    });
    // Lấy dữ liệu department từ API
    final result = await AdminDepartmentController().fetchAllDepartments();
    final List<Department> departments = result['departments'];

    if (departments.isEmpty) {
      showTopNotification(
        context: context,
        message: "No departments found",
        type: NotificationType.error,
      );
      return;
    }

    // Convert Department -> SelectedListItem<Department>
    final items = departments
        .map((dep) => SelectedListItem<Department>(data: dep))
        .toList();

    DropDownState<Department>(
      dropDown: DropDown<Department>(
        bottomSheetTitle: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select Department",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        submitButtonText: "Save",
        clearButtonText: "Clear",
        data: items,
        // custom hiển thị
        listItemBuilder: (index, item) {
          return Row(
            children: [
              SizedBox(width: 10),

              Icon(FontAwesomeIcons.buildingUser, size: 18),
              SizedBox(width: 20),
              Text(item.data.name, style: TextStyle(fontSize: 14)),
            ],
          ); // item.data chính là Department
        },
        onSelected: (selectedItems) {
          // xử lý chọn
          final dep = selectedItems.first.data; // lấy Department gốc
          setState(() {
            _departmentNameSelected = dep.name;
            // widget.user.department = _departmentNameSelected; - bỏ
            // Sau mỗi lần chọn vào item mới cần trỏ tới đây, vì mặc định vào app ta check này trc.
            widget.user.departmentId = dep.id; // 👈 lưu id
            // _selectedDepartmentId = dep.id;
            _selectedDepartmentIdNotSave = dep.id;
            // mở nút lưu
            _openButtonSaveDepartment = true;
          });
        },

        // 👇 Đây là phần search
        searchDelegate: (query, dataItems) {
          return dataItems
              .where(
                (item) =>
                    item.data.name.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    (item.data.address?.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
        },
      ),
    ).showModal(context);

    setState(() {
      _openBottomDialogDepartment = false;
    });
    // Thêm logic chỉnh sửa department ở đây
  }

  void handleEditPosition(String departmentId) async {
    setState(() {
      // _openBottomDialog = true;
    });
    // Lấy dữ liệu department từ API
    final result = await AdminPositionController()
        .fetchAllPositionsByDepartment(departmentId: departmentId);
    final List<Position> positions = result['positions'];

    if (positions.isEmpty) {
      showTopNotification(
        context: context,
        message: "No positions added for \"${_departmentNameSelected}\" department yet.",
        type: NotificationType.success,
      );
      return;
    }

    // Convert Department -> SelectedListItem<Department>
    final items = positions
        .map((dep) => SelectedListItem<Position>(data: dep))
        .toList();

    DropDownState<Position>(
      dropDown: DropDown<Position>(
        bottomSheetTitle: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Select Position",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ),
        ),
        submitButtonText: "Save",
        clearButtonText: "Clear",
        data: items,
        // custom hiển thị
        listItemBuilder: (index, item) {
          return Row(
            children: [
              SizedBox(width: 10),

              Icon(FontAwesomeIcons.userTie, size: 18),
              SizedBox(width: 20),
              Text(item.data.positionName, style: TextStyle(fontSize: 14)),
            ],
          ); // item.data chính là Department
        },
        onSelected: (selectedItems) {
          // xử lý chọn
          final dep = selectedItems.first.data; // lấy Department gốc
          setState(() {
            widget.user.positionId = dep.id;
            _positionNameSelected = dep.positionName;
            // widget.user.position = _positionNameSelected;
            _selectedPositionIdNotSave = dep.id; // 👈 lưu id
            // mở nút lưu
            _openButtonSavePosition = true;
          });
        },

        // 👇 Đây là phần search
        searchDelegate: (query, dataItems) {
          return dataItems
              .where(
                (item) =>
                    item.data.positionName.toLowerCase().contains(
                      query.toLowerCase(),
                    ) ||
                    (item.data.positionName?.toLowerCase().contains(
                          query.toLowerCase(),
                        ) ??
                        false),
              )
              .toList();
        },
      ),
    ).showModal(context);

    setState(() {
      // _openBottomDialog = false;
    });
    // Thêm logic chỉnh sửa department ở đây
  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    if(widget.user.departmentId != null && widget.user.department != null){
      existDepartment();
    }
    if(widget.user.positionId != null && widget.user.position != null){
      existPosition();
    }
  }

  Future<void> existDepartment()async{
    // final resultExistDepartment = await AdminDepartmentController().fetchOneDepartment(id: widget.user.departmentId!);
    // if(resultExistDepartment != null){
    //   setState(() {
    //     _departmentNameSelected = resultExistDepartment.name;
    //     _selectedDepartmentId = resultExistDepartment.id;
    //   });
    // }
    _departmentNameSelected = widget.user.department!.name;
    _selectedDepartmentId = widget.user.departmentId;
  }
  Future<void> existPosition()async{
    // if (widget.user.positionId == null || widget.user.position == null) {
    //   return; // Thoát hàm nếu positionId là null hoặc rỗng
    // }
    _positionNameSelected = widget.user.position!.positionName;
    // final resultExistPosition = await AdminPositionController().fetchOnePosition(id: widget.user.positionId!);
    // if(resultExistPosition != null){
    //   setState(() {
    //     widget.user.positionId = resultExistPosition.id;
    //     _positionNameSelected = resultExistPosition.positionName;
    //   });
    // }
  }
  @override
  Widget build(BuildContext context) {
    final EdgeInsets padding = MediaQuery.of(context).padding;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: HelpersColors.itemCard,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'Information',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.only(
          bottom: padding.bottom,
          // top: 16,
          // left: 16,
          // right: 16,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                      ),
                      child: ClipOval(
                        child: Image(
                          // image: user?.image == null || user!.image.isEmpty
                          //     ? AssetImage(
                          //   user?.sex == 'Male'
                          //       ? 'assets/images/avatar_boy_default.jpg'
                          //       : user?.sex == "Female"
                          //   ? 'assets/images/avatar_girl_default.jpg'
                          //   : 'assets/images/avt_default_2.jpg',
                          // ) as ImageProvider
                          //     : NetworkImage(user.image),
                          image:
                              widget.user?.image == null ||
                                  widget.user!.image.isEmpty
                              ? AssetImage(
                                      widget.user?.sex == 'Male'
                                          ? 'assets/images/avatar_boy_default.jpg'
                                          : widget.user?.sex == "Female"
                                          ? 'assets/images/avatar_girl_default.jpg'
                                          : 'assets/images/avt_default_2.jpg',
                                    )
                                    as ImageProvider
                              : NetworkImage(widget.user.image),

                          // Sử dụng NetworkImage cho URLs
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.fullName == null ||
                                    widget.user.fullName.isEmpty
                                ? 'User ${widget.user.id}'
                                : widget.user.fullName,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 10),
                          Text(
                            widget.user.email,
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (!widget.user.status!)
                      // Spacer(),
                      if (!widget.user.status!)
                      Transform.rotate(
                        angle: -0.3,
                        child: Container(
                          padding:EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          margin: EdgeInsets.only(right: 5),
                          color: HelpersColors.itemSelected.withOpacity(0.1),
                          child: Text(
                            'resigned',
                            style: TextStyle(
                              fontSize: 12,
                              color: HelpersColors.itemSelected,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Text(
              //     'Created Account: ${widget.user.createdAt != null
              //         ? FormatHelper.formatDate_DD_MM_YYYY(widget.user.createdAt!)
              //         : 'Chưa có dữ liệu'}'
              // ),
              // Text('Total Full-Time: 15 days worked'),
              // Text('Total Part-Time: 120 hours worked'),
              // Text('Total leave days : 4 days'),
              _buildDevider(HelpersColors.itemCard),
              _buildTextFile('Department'),
              _buildBoxContentDepartment(
                FontAwesomeIcons.buildingUser,
                widget.user.departmentId == null || widget.user.departmentId == ''
                    ? 'Admin Unset !'
                    : _departmentNameSelected.toString(),
                valid:
                    widget.user.departmentId != null &&
                    widget.user.departmentId != '',
                onEdit: _openButtonSaveDepartment ? ()=>null : handleEditDepartment,
              ),
              _buildDevider(HelpersColors.itemCard),
              _buildTextFile('Position'),
              _buildBoxContentPosition(
                FontAwesomeIcons.userTie,
                widget.user.positionId == null || widget.user.positionId == '' || widget.user.position == null
                    ? 'Admin Unset !'
                    : _positionNameSelected.toString(),
                valid:
                    widget.user.positionId != null && widget.user.positionId != '' && widget.user.position != null,

                onEdit: () {
                  if (_selectedDepartmentId != null || _departmentNameSelected != null) {
                    handleEditPosition(_selectedDepartmentId!);
                  } else {
                    showTopNotification(
                      context: context,
                      message: "Please select a department first",
                      type: NotificationType.error,
                    );
                  }
                },
              ),
              _buildDevider(HelpersColors.itemCard),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFile('Sex'),
                        _buildBoxContent(
                          Icons.transgender,
                          widget.user.sex == null || widget.user.sex == ''
                              ? 'User unset !'
                              : widget.user.sex.toString(),
                          valid:
                              widget.user.sex != null && widget.user.sex != '',
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextFile('Birthday'),
                        _buildBoxContent(
                          Icons.date_range,
                          widget.user.birthDay == null ||
                                  widget.user.birthDay == ''
                              ? 'User unset !'
                              : FormatHelper.formatDate_DD_MM_YYYY(
                                  widget.user.birthDay!,
                                ),
                          valid:
                              widget.user.birthDay != null &&
                              widget.user.birthDay != '',
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              _buildDevider(HelpersColors.itemCard),
              _buildTextFile('Phone Number'),
              _buildBoxContent(
                Icons.phone,
                widget.user.phoneNumber == null || widget.user.phoneNumber == ''
                    ? 'User unset !'
                    : widget.user.phoneNumber.toString(),
                valid:
                    widget.user.phoneNumber != null &&
                    widget.user.phoneNumber != '',
              ),
              _buildDevider(HelpersColors.itemCard),
            ],
          ),
        ),
      ),
    );
  }
}
