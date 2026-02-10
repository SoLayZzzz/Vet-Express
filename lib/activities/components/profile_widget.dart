import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/user_controller.dart';
import '../../utils/app_colors.dart';
import '../screen/setting_screen.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Obx(() {
      if (userController.isLoading.value) {
        return skeleton();
      } else if (userController.hasError.value) {
        return skeleton();
      } else if (userController.userMeResponse.value != null) {
        final user = userController.userMeResponse.value!;
        return InkWell(
          onTap: () {
            Get.to(
              () => const SettingScreen(),
              transition: Transition.rightToLeft,
              duration: const Duration(milliseconds: 350),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
                  height: 48,
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFC6C6C6),
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.whiteColor,
                      child: ClipOval(
                        child:
                            (user.body?.filename?.isNotEmpty ?? false
                                ? CachedNetworkImage(
                                  imageUrl: user.body?.filename ?? '',
                                  placeholder: (context, url) => placeHolder(),
                                  errorWidget: (context, url, error) => placeHolder(),
                                  fit: BoxFit.cover,
                                  width: 126,
                                  height: 126,
                                )
                                : placeHolder()),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${'hello'.tr}, ${capitalizeFirstLetter(user.body?.name ?? '')}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text("view_acc".tr, style: const TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        );
      }
      return skeleton();
    });
  }

  ClipRRect placeHolder() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: const Image(
        image: AssetImage('assets/images/img_user_profile.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  String capitalizeFirstLetter(String input) {
    if (input.isEmpty) {
      return input;
    }
    return input[0].toUpperCase() + input.substring(1);
  }

  Widget skeleton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircleAvatar(
              backgroundColor: const Color(0xFFC6C6C6),
              child: CircleAvatar(
                radius: 40,
                backgroundColor: AppColors.whiteColor,
                child: Image.asset('assets/images/img_user_profile.png', fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: 150, height: 15, color: Colors.grey[200]),
              const SizedBox(height: 4),
              Container(width: 100, height: 10, color: Colors.grey[200]),
            ],
          ),
        ],
      ),
    );
  }
}
