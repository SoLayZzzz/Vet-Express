import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:express_vet/activities/ticket/value_statics.dart';
import 'package:express_vet/utils/alert_dialog.dart';
import 'package:express_vet/utils/button.dart';
import '../../../../controller/slide_controller.dart';
import '../../../../utils/app_bar.dart';
import '../../../../utils/app_colors.dart';
import '../../../../activities/components/cache_image_widget.dart';
import '../../../../routes/app_routes.dart';
import '../controller/ticket_menu_page_controller.dart';
import '../controller/ticket_menu_form_controller.dart';

class TicketMenuScreen extends GetView<TicketMenuPageController> {
  const TicketMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SlideController slideController = Get.find<SlideController>();
    final TicketMenuFormController formController =
        Get.find<TicketMenuFormController>();

    return Scaffold(
      appBar: AppBarVET().appBar(context, controller.appBarTitle),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              // ✅ OPTIMIZED: Show cached data immediately, even while loading updates
              buildImage(context, slideController),

              /// menu ticket
              selectionView(context, formController),

              /// button search
              searchButton(context, formController),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildImage(BuildContext context, SlideController slideController) {
    return Obx(() {
      final images =
          controller.type == 2
              ? slideController.imgListBoat
              : slideController.imgListBus;

      // Show cached data if available, even if still loading updates
      if (images.isNotEmpty) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          width: double.infinity,
          child: CachedImage(
            imageUrl: images[0],
            fit: BoxFit.cover,
            height: MediaQuery.of(context).size.height * 0.2,
          ),
        );
      }

      // Show loading only if no cached data available
      if (slideController.isLoading.value) {
        return placeHolder(context);
      }

      // No data available
      return placeHolder(context);
    });
  }

  Widget searchButton(
    BuildContext context,
    TicketMenuFormController formController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: globalButton(
        context: context,
        buttonText: 'find_now'.tr,
        buttonColor:
            ValueStatic.ticketType == '3'
                ? AppColors.airBusColor
                : AppColors.primaryColor,
        onPressed: () {
          if (ValueStatic.desfromId == '' && ValueStatic.desToId == '') {
            alertDialogOneButton(
              title: 'information'.tr,
              description: 'please_select_destination'.tr,
              buttonText: 'yes'.tr,
            );
          } else if (ValueStatic.desToId == '') {
            alertDialogOneButton(
              title: 'information'.tr,
              description: 'please_select_destination_to'.tr,
              buttonText: 'yes'.tr,
            );
          } else {
            final flowId = DateTime.now().millisecondsSinceEpoch.toString();
            ValueStatic.goDate = formController.goDate.value;
            if (formController.backDate.value == 'return_date'.tr) {
              ValueStatic.journeyType = 1;

              Get.toNamed(
                AppRoutes.scheduleList,
                arguments: {'isBack': false, 'flowId': flowId},
              );
            } else {
              if (formController.backDate.value != 'return_date'.tr) {
                ValueStatic.journeyType = 2;
                ValueStatic.backDate = formController.backDate.value;

                Get.toNamed(
                  AppRoutes.scheduleList,
                  arguments: {'isBack': false, 'flowId': flowId},
                );
              } else {
                alertDialogOneButton(
                  title: 'information'.tr,
                  description: 'please_select_back_date'.tr,
                  buttonText: 'yes'.tr,
                );
              }
            }
          }
        },
      ),
    );
  }

  Widget selectionView(
    BuildContext context,
    TicketMenuFormController formController,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 15),
      child: Column(
        children: [
          GestureDetector(
            onTap: () async {
              await Get.toNamed(
                AppRoutes.selectTicket,
                arguments: {'selectType': 'Destination From'},
              );
              formController.syncFromStatics();
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.whiteColor,
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/icon_location.png',
                      width: 22,
                      color:
                          ValueStatic.ticketType == '3'
                              ? AppColors.airBusColor
                              : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Obx(() {
                      return formController.fromName.value.isEmpty
                          ? Text(
                            'departing_from'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyColor,
                            ),
                          )
                          : Text(
                            formController.fromName.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          GestureDetector(
            onTap: () async {
              if (ValueStatic.desfrom != '' && ValueStatic.desfromId != '') {
                await Get.toNamed(
                  AppRoutes.selectTicket,
                  arguments: {'selectType': 'Destination To'},
                );
                formController.syncFromStatics();
              } else {
                alertDialogOneButton(
                  title: 'information'.tr,
                  description: 'please_select_destination_from'.tr,
                  buttonText: 'yes'.tr,
                );
              }
            },
            child: Container(
              width: MediaQuery.sizeOf(context).width,
              height: 55,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: AppColors.whiteColor,
                border: Border.all(color: AppColors.borderColor, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Image.asset(
                      'assets/icons/icon_location.png',
                      width: 22,
                      color:
                          ValueStatic.ticketType == '3'
                              ? AppColors.airBusColor
                              : AppColors.primaryColor,
                    ),
                    const SizedBox(width: 10),
                    Obx(() {
                      return formController.toName.value.isEmpty
                          ? Text(
                            'going_to'.tr,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.greyColor,
                            ),
                          )
                          : Text(
                            formController.toName.value,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textColor,
                            ),
                          );
                    }),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: MediaQuery.sizeOf(context).width * 0.45,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.borderColor, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: InkWell(
                    onTap: () async {
                      formController.clearBackDate();

                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        locale:
                            Get.locale.toString() == "km_KH"
                                ? const Locale("km", "KH")
                                : Get.locale.toString() == "en_US"
                                ? const Locale("en", "US")
                                : const Locale("zh", "CN"),
                        initialDate: DateFormat(
                          'yyyy-MM-dd',
                        ).parse(formController.goDate.value),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary:
                                    ValueStatic.ticketType == '3'
                                        ? AppColors.airBusColor
                                        : AppColors.primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      ValueStatic.ticketType == '3'
                                          ? AppColors.airBusColor
                                          : AppColors.primaryColor,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        formController.setGoDate(pickedDate);
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/img_calendar.png',
                          width: 22,
                          color:
                              ValueStatic.ticketType == '3'
                                  ? AppColors.airBusColor
                                  : AppColors.primaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Obx(() {
                            return Text(
                              formController.goDate.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Container(
                width: MediaQuery.sizeOf(context).width * 0.45,
                height: 55,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.borderColor, width: 0.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: InkWell(
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        locale:
                            Get.locale.toString() == "km_KH"
                                ? const Locale("km", "KH")
                                : Get.locale.toString() == "en_US"
                                ? const Locale("en", "US")
                                : const Locale("zh", "CN"),
                        initialDate: DateFormat('yyyy-MM-dd')
                            .parse(formController.goDate.value)
                            .add(const Duration(days: 0)),
                        firstDate: DateFormat('yyyy-MM-dd')
                            .parse(formController.goDate.value)
                            .add(const Duration(days: 0)),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary:
                                    ValueStatic.ticketType == '3'
                                        ? AppColors.airBusColor
                                        : AppColors.primaryColor,
                                onPrimary: Colors.white,
                                onSurface: Colors.black,
                              ),
                              textButtonTheme: TextButtonThemeData(
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      ValueStatic.ticketType == '3'
                                          ? AppColors.airBusColor
                                          : AppColors.primaryColor,
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        formController.setBackDate(pickedDate);
                      }
                    },
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/img_calendar.png',
                          width: 22,
                          color:
                              ValueStatic.ticketType == '3'
                                  ? AppColors.airBusColor
                                  : AppColors.primaryColor,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Obx(() {
                            return Text(
                              formController.backDate.value,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                color: AppColors.textColor,
                              ),
                            );
                          }),
                        ),
                        const Spacer(),
                        Obx(() {
                          return formController.backDate.value !=
                                  'return_date'.tr
                              ? IconButton(
                                onPressed: () {
                                  formController.clearBackDate();
                                },
                                icon: const Icon(
                                  Icons.close,
                                  size: 20,
                                  color: AppColors.borderColor,
                                ),
                              )
                              : const SizedBox();
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  SizedBox placeHolder(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.2,
      width: double.infinity,
      child: Image(
        image: const AssetImage('assets/images/place_holder.png'),
        height: MediaQuery.of(context).size.height * 0.2,
        width: double.infinity,
        fit: BoxFit.cover,
      ),
    );
  }
}
