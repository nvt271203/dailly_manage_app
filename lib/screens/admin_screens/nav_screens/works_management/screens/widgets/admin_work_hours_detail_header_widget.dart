import 'package:flutter/material.dart';

import '../../../../../../helpers/format_helper.dart';
import '../../../../../../helpers/tools_colors.dart';
import '../../../../../../models/work.dart';
class AdminWorkHoursDetailHeaderWidget extends StatefulWidget {
  const AdminWorkHoursDetailHeaderWidget({super.key, required this.work});
  final Work work;
  @override
  State<AdminWorkHoursDetailHeaderWidget> createState() => _AdminWorkHoursDetailHeaderWidgetState();
}

class _AdminWorkHoursDetailHeaderWidgetState extends State<AdminWorkHoursDetailHeaderWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            children: [
              // ClipRRect(
              //   borderRadius: BorderRadius.all(Radius.circular(100)),
              //   child: Image.network(
              //     // 'https://res.cloudinary.com/doiar6ybd/image/upload/v1753864338/users/rinoadsrlke9aoj5bfxj.jpg',
              //     widget.work.user?['image'] ?? 'https://res.cloudinary.com/doiar6ybd/image/upload/v1753864338/users/rinoadsrlke9aoj5bfxj.jpg',
              //
              //     width: 50,
              //     height: 50,
              //     fit: BoxFit.cover,
              //   ),
              // ),
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  // border: Border.all(color: Colors.white, width: 4),
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
                    image: widget.work.user?.image == null || widget.work.user!.image.isEmpty
                        ? AssetImage(
                      widget.work.user?.sex == 'Male'
                          ? 'assets/images/avatar_boy_default.jpg'
                          : widget.work.user?.sex == "Female"
                          ? 'assets/images/avatar_girl_default.jpg'
                          : 'assets/images/avt_default_2.jpg',
                    ) as ImageProvider
                        :NetworkImage(widget.work.user!.image), // Sử dụng NetworkImage cho URLs


                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
              ),

              SizedBox(width: 15),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            // widget.work.user?['fullName'] ?? 'Unknown User',
                            widget.work.user!.fullName == null || widget.work.user!.fullName == ''  ?  'User ${widget.work.userId}' : widget.work.user!.fullName,

                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          FormatHelper.formatDate_DD_MM_YYYY(
                            widget.work.checkInTime,
                          ),
                          style: TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                      ],
                    ),
                    SizedBox(height: 5),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Department: ',
                          style: TextStyle(fontSize: 13),
                        ),
                        Expanded(
                          child: Text(
                            widget.work.user!.department == null || widget.work.user!.department == '' ?
                            'Unset' : widget.work.user!.department!.name,
                            style: TextStyle(fontSize: 13),
                          
                          ),
                        ),
                        // Spacer(),
                        Text(
                          'Position: ',
                          style: TextStyle(fontSize: 13),
                        ),
                        Text(
                          widget.work.user!.position == null || widget.work.user!.position == ''?
                          'Unset' : widget.work.user!.position!.positionName,
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),




        ],
      ),
    );
  }
}
