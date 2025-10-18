import 'package:daily_manage_user_app/controller/admin/admin_department_controller.dart';
import 'package:daily_manage_user_app/controller/admin/admin_position_controller.dart';
import 'package:daily_manage_user_app/models/department.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/widgets/admin_org_title_center_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/loading_circle_white_default_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:drop_down_list/drop_down_list.dart';
import '../../../../../../../../helpers/tools_colors.dart';
import '../../../../../../../../models/position.dart';
import '../../../../../../../../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drop_down_list/model/selected_list_item.dart';
import '../../../../../../../../providers/admin/admin_department_provider.dart';
import '../../../../../../../../providers/admin/admin_position_provider.dart';

class AdminOrgTabPositionAddDialog extends ConsumerStatefulWidget {
  const AdminOrgTabPositionAddDialog({super.key, this.position});
  final Position? position;
  @override
  _AdminOrgTabPositionAddDialogState createState() =>
      _AdminOrgTabPositionAddDialogState();
}

class _AdminOrgTabPositionAddDialogState
    extends ConsumerState<AdminOrgTabPositionAddDialog> {
  final Department department = Department.newDepartment();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _departmentNameController =
  TextEditingController(); // 👈 controller
  final TextEditingController _positionNameController =
  TextEditingController(); // 👈 controller
  bool _isLoading = false;
  bool _openBottomDialog = false;
  String? _selectedDepartmentId;
  Widget _buildTextFile(String title) {
    return Container(
      margin: EdgeInsets.only(top: 10, bottom: 5),
      child: Text(
        title,
        style: TextStyle(
          color: HelpersColors.itemCard,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required IconData iconPrefix,
    required String textHint,
    required String? Function(String?) validator, // 👈 thêm tham số validator
    IconData? suffixIcon = null,
    bool readOnly = false,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator, // 👈 dùng validator được truyền vào
      style: TextStyle(color: HelpersColors.itemCard, fontSize: 13),
      readOnly: readOnly,
      decoration: InputDecoration(

        // fillColor: HelpersColors.bgFillTextField,
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: HelpersColors.itemCard),
        ),
        contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        // 👈 chỉnh padding trong
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: HelpersColors.itemCard.withOpacity(0.5), width: 1.0),
        ),
        hintText: textHint,
        hintStyle: TextStyle(
          fontSize: 13,
          color: HelpersColors.itemCard.withOpacity(0.5),
        ),
        prefixIcon: Icon(iconPrefix, color: HelpersColors.itemCard, size: 17),
        suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: HelpersColors.itemCard,size: 25,) : null
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      print(_departmentNameController.text);
      print(_positionNameController.text);
      setState(() {
        _isLoading = true;
      });
      if(widget.position == null){
        final result = await AdminPositionController().requestNewPosition(
          departmentId: _selectedDepartmentId!,
          departmentName: _departmentNameController.text,
          positionName: _positionNameController.text,
        );
        if (result != null) {
          // ref.read(adminDepartmentProvider.notifier).addDepartment(result);
          ref.read(adminPositionProvider(_selectedDepartmentId!).notifier).addPosition(result);
          showTopNotification(
            context: context,
            message:
            '${_departmentNameController.text} department added successfully.',
            type: NotificationType.success,
          );
          Navigator.of(context).pop();
        } else {
          showTopNotification(
            context: context,
            message: '${_departmentNameController.text} position added failed.',
            type: NotificationType.error,
          );
        }
      }else{
        final result = await AdminPositionController().requestUpdatePosition(
          id: widget.position!.id,
          departmentName: _departmentNameController.text,
          positionName: _positionNameController.text,
        );
        if (result != null) {
          ref.read(adminPositionProvider(widget.position!.departmentId).notifier).updatePosition(result);
          showTopNotification(
            context: context,
            message:
            '${_departmentNameController.text} position updated successfully.',
            type: NotificationType.success,
          );
          Navigator.of(context).pop();
        } else {
          showTopNotification(
            context: context,
            message: '${_departmentNameController.text} position updated failed.',
            type: NotificationType.error,
          );
        }
      }

      setState(() {
        // _departmentNameController.clear();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Nếu có dữ liệu department truyền vào thì gán cho form
    if (widget.position != null) {
      print('_departmentNameController.text${_departmentNameController.text}');
      print('_departmentAddressController.text${_positionNameController.text}');
      _departmentNameController.text = widget.position!.departmentName;
      _positionNameController.text = widget.position!.positionName ?? "";
    }
  }
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            // 👈 quan trọng để dialog vừa nội dung
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AdminOrgTitleCenterWidget(title:
              widget.position == null ?
              'Add New Position' : 'Update Position'),
              SizedBox(height: 20),

              _buildTextFile('Department Name'),
              GestureDetector(
                onTap: _openBottomDialog ? null : () async{
                  setState(() {
                    _openBottomDialog = true;
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
                          child: Text("Select Department",
                          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 16),),
                        ),
                      ),
                      submitButtonText: "Save",
                      clearButtonText: "Clear",
                      data: items,
                      // custom hiển thị
                      listItemBuilder: (index, item) {
                        return Row(
                          children: [
                            SizedBox(width: 10,),

                            Icon(FontAwesomeIcons.buildingUser,size: 18,),
                            SizedBox(width: 20,),
                            Text(item.data.name,style: TextStyle(fontSize: 14),),
                          ],
                        ); // item.data chính là Department
                      },
                      onSelected: (selectedItems) {
                        // xử lý chọn
                        final dep = selectedItems.first.data; // lấy Department gốc
                        setState(() {
                          _departmentNameController.text = dep.name;
                          _selectedDepartmentId = dep.id;  // 👈 lưu id
                        });
                      },

                      // 👇 Đây là phần search
                      searchDelegate: (query, dataItems) {
                        return dataItems
                            .where((item) =>
                        item.data.name.toLowerCase().contains(query.toLowerCase()) ||
                            (item.data.address?.toLowerCase().contains(query.toLowerCase()) ?? false))
                            .toList();
                      },

                    ),
                  ).showModal(context);

                  setState(() {
                    _openBottomDialog = false;
                  });

                },
                child: AbsorbPointer(
                  child: _buildTextFormField(
                    controller: _departmentNameController,
                    iconPrefix: FontAwesomeIcons.buildingUser,
                    textHint: 'Select department name',
                    validator: department.departmentNameValidate,
                    readOnly: true,
                    suffixIcon: Icons.keyboard_arrow_down
                  ),
                ),
              ),
              _buildTextFile('Position Name'),
              _buildTextFormField(
                controller: _positionNameController,
                iconPrefix: FontAwesomeIcons.userTie,
                textHint: 'Enter position name',
                validator: department.departmentAddressValidate,
              ),

              SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: HelpersColors.itemSelected,
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        // showTopNotification(context: context, message: 'This is success', type: NotificationType.success);
                        // showTopNotification(context: context, message: 'This is fail', type: NotificationType.error);

                        _save();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                          color: HelpersColors.itemCard,
                        ),
                        child: _isLoading
                            ? SizedBox(
                            width: 30,
                            height: 30,
                            child: LoadingCircleWhiteDefaultWidget())
                            : Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
