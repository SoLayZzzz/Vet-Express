import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app_colors.dart';

class AlertDialogTwine extends StatefulWidget {
  const AlertDialogTwine({
    super.key,
    required this.title,
    required this.description,
    required this.confirmClick,
  });

  final String title, description;
  final Function confirmClick;

  @override
  State<AlertDialogTwine> createState() => _AlertDialogTwineState();
}

class _AlertDialogTwineState extends State<AlertDialogTwine> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      elevation: 0,
      backgroundColor: const Color(0xffffffff),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 15),
          Text(widget.title, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16),
            child: Text(widget.description, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.redColor,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 50,
                    child: Center(
                      child: Text('no'.tr, style: const TextStyle(color: AppColors.whiteColor)),
                    ),
                  ),
                ),
                const Spacer(),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    widget.confirmClick();
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.all(Radius.circular(6)),
                    ),
                    width: MediaQuery.of(context).size.width / 3.5,
                    height: 50,
                    child: Center(
                      child: Text('yes'.tr, style: const TextStyle(color: AppColors.whiteColor)),
                    ),
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
