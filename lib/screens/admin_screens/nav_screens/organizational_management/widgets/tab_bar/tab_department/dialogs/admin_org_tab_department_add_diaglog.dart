import 'package:daily_manage_user_app/controller/admin/admin_department_controller.dart';
import 'package:daily_manage_user_app/models/department.dart';
import 'package:daily_manage_user_app/screens/admin_screens/nav_screens/organizational_management/widgets/tab_bar/widgets/admin_org_title_center_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/loading_circle_white_default_widget.dart';
import 'package:daily_manage_user_app/screens/common_screens/widgets/top_notification_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../../../../../helpers/tools_colors.dart';
import '../../../../../../../../models/user.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../../../../providers/admin/admin_department_provider.dart';

class AdminOrgTabDepartmentAddDialog extends ConsumerStatefulWidget {
  const AdminOrgTabDepartmentAddDialog({super.key, this.departmentItem});
  final Department? departmentItem;
  @override
  _AdminOrgTabDepartmentAddDialogState createState() =>
      _AdminOrgTabDepartmentAddDialogState();
}

class _AdminOrgTabDepartmentAddDialogState
    extends ConsumerState<AdminOrgTabDepartmentAddDialog> {
  final Department department = Department.newDepartment();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _departmentNameController =
      TextEditingController(); // 👈 controller
  final TextEditingController _departmentAddressController =
      TextEditingController(); // 👈 controller
  bool _isLoading = false;

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
  }) {
    return TextFormField(
      controller: controller,
      validator: validator, // 👈 dùng validator được truyền vào
      style: TextStyle(color: HelpersColors.itemCard, fontSize: 13),
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
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState != null && _formKey.currentState!.validate()) {
      print(_departmentNameController.text);
      print(_departmentAddressController.text);
      setState(() {
        _isLoading = true;
      });
      if(widget.departmentItem == null){
        final result = await AdminDepartmentController().requestNewDepartment(
          nameDepartment: _departmentNameController.text,
          addressDepartment: _departmentAddressController.text,
        );
        if (result != null) {
          ref.read(adminDepartmentProvider.notifier).addDepartment(result);
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
            message: '${_departmentNameController.text} department added failed.',
            type: NotificationType.error,
          );
        }
      }else{
        final result = await AdminDepartmentController().requestUpdateDepartment(
         idDepartment: widget.departmentItem!.id,
          nameUpdate: _departmentNameController.text,
          addressUpdate: _departmentAddressController.text,
        );
        if (result != null) {
          ref.read(adminDepartmentProvider.notifier).updateDepartment(result);
          showTopNotification(
            context: context,
            message:
            '${_departmentNameController.text} department updated successfully.',
            type: NotificationType.success,
          );
          Navigator.of(context).pop();
        } else {
          showTopNotification(
            context: context,
            message: '${_departmentNameController.text} department updated failed.',
            type: NotificationType.error,
          );
        }
      }

      setState(() {
        _departmentNameController.clear();
        _isLoading = false;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Nếu có dữ liệu department truyền vào thì gán cho form
    if (widget.departmentItem != null) {
      print('_departmentNameController.text${_departmentNameController.text}');
      print('_departmentAddressController.text${_departmentAddressController.text}');
      _departmentNameController.text = widget.departmentItem!.name;
      _departmentAddressController.text = widget.departmentItem!.address ?? "";
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
              widget.departmentItem == null ?
              'Add New Department' : 'Update Department'),
              SizedBox(height: 20),

              _buildTextFile('Department Name'),
              _buildTextFormField(
                controller: _departmentNameController,
                iconPrefix: FontAwesomeIcons.buildingUser,
                textHint: 'Enter department name',
                validator: department.departmentNameValidate,
              ),
              _buildTextFile('Department Address'),
              _buildTextFormField(
                controller: _departmentAddressController,
                iconPrefix: FontAwesomeIcons.map,
                textHint: 'Enter department address',
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
                            ? LoadingCircleWhiteDefaultWidget()
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
