import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import '../../../../../base/base_url.dart';
import '../../../../../controller/user_controller.dart';
import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/contains.dart';
import '../../../../auth/presentation/controller/auth_controller.dart';
import 'profile_screen.dart';
import 'term_screen.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final UserController userController = Get.find<UserController>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Obx(() {
            if (userController.isLoading.value) {
              return skeletonLoading(context);
            }
            final user = userController.userMeResponse.value;
            return SliverAppBar(
              expandedHeight: 260.0,
              pinned: true,
              title: Text("account".tr),
              centerTitle: true,
              leading: IconButton(
                icon: const Icon(
                  Ionicons.chevron_back_outline,
                  color: AppColors.whiteColor,
                ),
                onPressed: () => Get.back(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.asset(
                      'assets/images/image_background_setting.png',
                      fit: BoxFit.cover,
                    ),
                    Container(color: Colors.black.withValues(alpha: 0.1)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 50),
                        user?.body?.filename?.isEmpty ?? true
                            ? CircleAvatar(
                              backgroundColor: const Color(0xFFC6C6C6),
                              radius: 63,
                              child: Image.asset(
                                "assets/images/img_user_profile.png",
                              ),
                            )
                            : ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: user!.body!.filename!,
                                placeholder: (context, url) => placeHolderImg(),
                                errorWidget:
                                    (context, url, error) => placeHolderImg(),
                                fit: BoxFit.cover,
                                width: 120,
                                height: 120,
                              ),
                            ),
                        const SizedBox(height: 10),
                        Text(
                          user?.body?.name ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          user?.body?.telephone ?? '',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 30),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                view(Ionicons.person_outline, "view_pf".tr, () async {
                  Get.to(
                    () => ProfileScreen(),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: Constrains.duration),
                  );
                }),
                view(Ionicons.receipt_outline, "condition-ticket".tr, () {
                  Get.to(
                    () => TermScreen(from: 1, title: 'condition-ticket'.tr),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: Constrains.duration),
                  );
                }),
                view(Ionicons.receipt_outline, "condition-logistic".tr, () {
                  Get.to(
                    () => TermScreen(from: 2, title: 'condition-logistic'.tr),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: Constrains.duration),
                  );
                }),
                view(Ionicons.receipt_outline, "condition-buvaSea".tr, () {
                  Get.to(
                    () => TermScreen(from: 3, title: 'condition-buvaSea'.tr),
                    transition: Transition.rightToLeft,
                    duration: const Duration(milliseconds: Constrains.duration),
                  );
                }),
                view(Ionicons.trash_outline, "delete_account".tr, () {
                  deleteAccount(context);
                }),
                view(
                  Ionicons.log_out_outline,
                  'logout'.tr,
                  color: AppColors.redColor,
                  () {
                    alertDialogTwoButton(
                      title: "info".tr,
                      description: "logout_que".tr,
                      buttonText1: 'no'.tr,
                      buttonText2: 'yes'.tr,
                      onButtonPressed1: () {
                        Navigator.pop(context);
                      },
                      onButtonPressed2: () {
                        Navigator.pop(context);
                        final authController = Get.find<AuthController>();
                        authController.logout(context);
                      },
                    );
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Text(
                    'version'.tr +
                        (Platform.isAndroid
                            ? BaseUrl.APP_VERSION_ANDROID
                            : BaseUrl.APP_VERSION_IOS),
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar skeletonLoading(context) => SliverAppBar(
    expandedHeight: 260.0,
    pinned: true,
    title: Text("account".tr),
    centerTitle: true,
    leading: IconButton(
      icon: const Icon(
        Ionicons.chevron_back_outline,
        color: AppColors.whiteColor,
      ),
      onPressed: () => Get.back(),
    ),
    flexibleSpace: FlexibleSpaceBar(
      background: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/image_background_setting.png',
            fit: BoxFit.cover,
          ),
          Container(color: Colors.black.withValues(alpha: 0.1)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),
              CircleAvatar(
                backgroundColor: AppColors.backgroundColor,
                radius: 63,
                child: Image.asset(
                  'assets/images/img_user_profile.png',
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: 120,
                height: 18,
                color: AppColors.backgroundColor,
              ),
              const SizedBox(height: 5),
              Container(
                width: 80,
                height: 14,
                color: AppColors.backgroundColor,
              ),
            ],
          ),
        ],
      ),
    ),
  );

  Padding view(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color = AppColors.titleColor,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          color: AppColors.whiteColor,
          border: Border.all(width: 0.2, color: AppColors.borderColor),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: Colors.black38),
              const SizedBox(width: 15),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
              const Spacer(),
              const Icon(
                Ionicons.chevron_forward_outline,
                color: AppColors.borderColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  ClipRRect placeHolderImg() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: const Image(
        image: AssetImage('assets/images/img_user_profile.png'),
        fit: BoxFit.cover,
      ),
    );
  }

  void deleteAccount(context) {
    alertDialogTwoButton(
      title: "delete_ques".tr,
      description: "delete_info".tr,
      buttonText1: 'no'.tr,
      buttonText2: 'yes'.tr,
      onButtonPressed1: () {
        Navigator.pop(context);
      },
      onButtonPressed2: () {
        Navigator.pop(context);
        final authController = Get.find<AuthController>();
        authController.deleteAccount(context);
      },
    );
  }
}
