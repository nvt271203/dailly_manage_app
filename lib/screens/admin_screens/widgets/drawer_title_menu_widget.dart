import 'package:flutter/material.dart';

import '../../../helpers/tools_colors.dart';
import '../../../models/user.dart';
class DrawerTitleMenuWidget extends StatelessWidget {
  const DrawerTitleMenuWidget({super.key, required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 24.0,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [HelpersColors.itemCard, HelpersColors.itemCard],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              Container(
                // padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: user?.image == null || user!.image.isEmpty
                      ? Image.asset(
                    user?.sex == 'Male'
                        ? 'assets/images/avatar_boy_default.jpg'
                        : user?.sex == 'Male'
                        ? 'assets/images/avatar_girl_default.jpg'
                        : 'assets/images/avt_default_2.jpg',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  )
                      : Image.network(
                    user.image,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  (user?.fullName == null ||
                      user!.fullName.trim().isEmpty)
                      ? 'New User'
                      : user.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  maxLines: 2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    )
    ;
  }
}
