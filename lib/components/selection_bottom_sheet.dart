import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SelectionSheetItem<T> {
  final T value;
  final String label;

  const SelectionSheetItem({required this.value, required this.label});
}

Future<T?> showSelectionBottomSheet<T>({
  required BuildContext context,
  required String title,
  required List<SelectionSheetItem<T>> items,
  bool isDismissible = true,
  bool enableDrag = false,
  required bool Function(T value) isSelected,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: false,
    backgroundColor: Colors.transparent,
    isDismissible: isDismissible,
    enableDrag: enableDrag,
    builder: (_) {
      return _SelectionBottomSheet<T>(
        title: title,
        items: items,
        isSelected: isSelected,
      );
    },
  );
}

class _SelectionBottomSheet<T> extends StatelessWidget {
  const _SelectionBottomSheet({
    required this.title,
    required this.items,
    required this.isSelected,
  });

  final String title;
  final List<SelectionSheetItem<T>> items;
  final bool Function(T value) isSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 3,
                  width: 42,
                  decoration: BoxDecoration(
                    color: AppColors.lineGray,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 5, 8, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(
                        Icons.close,
                        color: Colors.grey,
                        size: 28,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  children: [
                    for (var i = 0; i < items.length; i++) ...[
                      _SelectionTile<T>(
                        item: items[i],
                        selected: isSelected(items[i].value),
                        isLast: i == items.length - 1,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectionTile<T> extends StatelessWidget {
  const _SelectionTile({
    required this.item,
    required this.selected,
    required this.isLast,
  });

  final SelectionSheetItem<T> item;
  final bool selected;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? AppColors.seatNumberColor : AppColors.lineGray;
    final fillColor = selected ? AppColors.seatNumberColor : AppColors.borderColor;

    return InkWell(
      onTap: () => Get.back(result: item.value),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item.label,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: borderColor, width: 1),
                  ),
                  child: Center(
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: fillColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, color: AppColors.lineGray),
        ],
      ),
    );
  }
}
