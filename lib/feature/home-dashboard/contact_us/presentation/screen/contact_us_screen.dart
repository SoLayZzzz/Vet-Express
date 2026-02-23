import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../utils/alert_dialog.dart';
import '../../../../../utils/app_bar.dart';
import '../../../../../utils/app_colors.dart';
import '../../../../../utils/contains.dart';
import 'package:express_vet/feature/home-dashboard/contact_us/presentation/controller/contact_us_controller.dart';
import '../../../../../base/web_view_screen.dart';

class ContactUsScreen extends GetView<ContactUsController> {
  const ContactUsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarVET().appBar(context, 'contact_us'.tr),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "hotline".tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                viewPhone(
                  'assets/icons/icon_call_VireakBus.png',
                  'vetBus'.tr,
                  '081 911 911',
                ),
                viewPhone(
                  'assets/icons/icon_call_VireakLogistic.png',
                  'vetLogistic'.tr,
                  '010 522 522',
                ),
                viewPhone(
                  'assets/icons/icon_call_buvaSea.png',
                  'vetBuva'.tr,
                  '015 888 850',
                ),
                viewPhone(
                  'assets/icons/Icon_call_ThaiLogistics.png',
                  'vetThai'.tr,
                  '012 722 848',
                ),
                viewPhone(
                  'assets/icons/icon_call_VietnamLogistics.png',
                  'vetVN'.tr,
                  '012 322 302',
                ),
                viewPhone(
                  'assets/icons/icon_call_vehicleRental.png',
                  'vetRental'.tr,
                  '098 717 717',
                ),

                //* chat
                Text(
                  "chat".tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                view(
                  'assets/icons/icon_messenger.png',
                  'vetService'.tr,
                  'fb'.tr,
                  () {
                    _open('https://m.me/vireakbunthambus/');
                  },
                ),
                view(
                  'assets/icons/icon_telegram.png',
                  'vetBus'.tr,
                  'rental_tele'.tr,
                  () async {
                    final url = Uri.parse("https://t.me/VETransportation");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
                view(
                  'assets/icons/icon_telegram.png',
                  'vetLogistic'.tr,
                  'rental_tele'.tr,
                  () async {
                    final url = Uri.parse("https://t.me/VETLogistics");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
                view(
                  'assets/icons/icon_telegram.png',
                  'vetRental'.tr,
                  'rental_tele'.tr,
                  () async {
                    final url = Uri.parse("https://t.me/vetairbusexpress");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),

                //* social media
                Text(
                  "social".tr,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                view(
                  'assets/icons/icon_facebook.png',
                  'vetService'.tr,
                  'fb'.tr,
                  () async {
                    final url = Uri.parse(
                      "https://www.facebook.com/vireakbunthambus",
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
                view(
                  'assets/icons/icon_instagram.png',
                  'vetService'.tr,
                  'ig'.tr,
                  () {
                    Get.to(
                      () => const WebViewScreen(type: 3, ticketId: ''),
                      duration: const Duration(
                        milliseconds: Constrains.duration,
                      ),
                      transition: Transition.rightToLeft,
                    );
                  },
                ),
                view(
                  'assets/icons/icon_telegram.png',
                  'vetService'.tr,
                  'tele'.tr,
                  () async {
                    final url = Uri.parse("https://t.me/virakbunthamexpress");
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
                view(
                  'assets/icons/icon_tiktok.png',
                  'vetService'.tr,
                  'tiktok'.tr,
                  () async {
                    final url = Uri.parse(
                      "https://www.tiktok.com/@virakbuntham?_t=8dthpgdhhsf&_r=1",
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
                view(
                  'assets/icons/icon_youtube.png',
                  'vetService'.tr,
                  'yt'.tr,
                  () async {
                    final url = Uri.parse(
                      "https://www.youtube.com/@virakbuntham668",
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding view(
    String img,
    String title,
    String subTitle,
    void Function() onTap,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.whiteColor,
            border: Border.all(width: 0.2, color: AppColors.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Image.asset(img, height: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(subTitle, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Ionicons.chevron_forward_outline,
                  size: 18,
                  color: AppColors.borderColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Padding viewPhone(String img, String title, String number) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: InkWell(
        onTap: () {
          final Uri launchUri = Uri(scheme: 'tel', path: number);
          launchUrl(launchUri);
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: AppColors.whiteColor,
            border: Border.all(width: 0.2, color: AppColors.borderColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Image.asset(img, height: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.titleColor,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(number, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(
                  Ionicons.chevron_forward_outline,
                  size: 18,
                  color: AppColors.borderColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(String url) async {
    Uri fbProtocolUrl = Uri.parse(url);
    try {
      bool launched = await launchUrl(
        fbProtocolUrl,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        alertDialogOneButton(
          title: 'info'.tr,
          description: 'install_messenger'.tr,
          buttonText: 'yes'.tr,
        );
      }
    } catch (e) {
      alertDialogOneButton(
        title: 'info'.tr,
        description: 'install_messenger'.tr,
        buttonText: 'yes'.tr,
      );
    }
  }
}
