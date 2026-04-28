import 'package:express_vet/utils/app_colors.dart';
import 'package:express_vet/value_statics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';

class PaymentOptionCard extends StatelessWidget {
  final String asset;
  final Widget title;
  final Widget subtitleWidget;
  final int value;
  final bool isSelected;
  final VoidCallback onTap;

  const PaymentOptionCard({
    super.key,
    required this.asset,
    required this.title,
    required this.subtitleWidget,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(
            color:
                isSelected
                    ? (ValueStatic.ticketType == '3'
                        ? AppColors.airBusColor
                        : AppColors.primaryColor)
                    : Colors.grey,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(
            children: [
              Image.asset(asset, height: 44),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: subtitleWidget,
                      ),
                    ],
                  ),
                ),
              ),

              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? (ValueStatic.ticketType == '3'
                            ? AppColors.airBusColor
                            : AppColors.primaryColor)
                        : AppColors.deepGrey,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: CircleAvatar(
                    backgroundColor: isSelected
                        ? (ValueStatic.ticketType == '3'
                            ? AppColors.airBusColor
                            : AppColors.primaryColor)
                        : AppColors.deepGrey,
                  ),
                ),
                
              ),

            ],
          ),
        ),
      ),
    );
  }
  
}
