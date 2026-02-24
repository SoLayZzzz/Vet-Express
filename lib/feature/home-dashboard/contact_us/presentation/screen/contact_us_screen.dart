import 'package:express_vet/asset_image.dart';
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
                  AssetImages.ic_call_vireak_bus,
                  'vetBus'.tr,
                  '081 911 911',
                ),
                viewPhone(
                  AssetImages.ic_call_vireak_logistics,
                  'vetLogistic'.tr,
                  '010 522 522',
                ),
                viewPhone(
                  AssetImages.ic_call_vireak_buva_sea,
                  'vetBuva'.tr,
                  '015 888 850',
                ),
                viewPhone(
                  AssetImages.ic_call_thai_logistics,
                  'vetThai'.tr,
                  '012 722 848',
                ),
                viewPhone(
                  AssetImages.ic_call_vietnam_logistic,
                  'vetVN'.tr,
                  '012 322 302',
                ),
                viewPhone(
                  AssetImages.ic_call_vehicle_rental,
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
                view(AssetImages.ic_messenger, 'vetService'.tr, 'fb'.tr, () {
                  _open('https://m.me/vireakbunthambus/');
                }),
                view(
                  AssetImages.ic_telegram,
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
                  AssetImages.ic_telegram,
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
                  AssetImages.ic_telegram,
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
                  AssetImages.ic_facebook,
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
                view(AssetImages.ic_instagram, 'vetService'.tr, 'ig'.tr, () {
                  Get.to(
                    () => const WebViewScreen(type: 3, ticketId: ''),
                    duration: const Duration(milliseconds: Constrains.duration),
                    transition: Transition.rightToLeft,
                  );
                }),
                view(
                  AssetImages.ic_telegram,
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
                  AssetImages.ic_tiktok,
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
                  AssetImages.ic_youtube,
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
