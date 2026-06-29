import 'package:express_vet/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:get/get.dart';

class EvRedeemPointScreen extends StatefulWidget {
  const EvRedeemPointScreen({super.key});

  @override
  State<EvRedeemPointScreen> createState() => _EvRedeemPointScreenState();
}

class _EvRedeemPointScreenState extends State<EvRedeemPointScreen> {
  int? _selectedIndex;
  final TextEditingController _amountController = TextEditingController();

  final List<_RedeemOption> _options = const <_RedeemOption>[
    _RedeemOption(amountLabel: r'$5.00', pointsLabel: '500 Points'),
    _RedeemOption(amountLabel: r'$10.00', pointsLabel: '1,000 Points'),
    _RedeemOption(amountLabel: r'$50.00', pointsLabel: '5,000 Points'),
    _RedeemOption(amountLabel: r'$100.00', pointsLabel: '10,000 Points'),
    _RedeemOption(amountLabel: r'$200.00', pointsLabel: '20,000 Points'),
    _RedeemOption(amountLabel: r'$500.00', pointsLabel: '50,000 Points'),
  ];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Ionicons.chevron_back_outline, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Redeem Point',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'Total Points',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      'Choose amount',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _options.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemBuilder: (context, index) {
                        final opt = _options[index];
                        final selected = _selectedIndex == index;

                        return InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () {
                            setState(() => _selectedIndex = index);
                            _amountController.clear();
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color:
                                  selected
                                      ? AppColors.primaryColor
                                      : const Color(0xFFF2F4F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  opt.amountLabel,
                                  style: TextStyle(
                                    color:
                                        selected ? Colors.white : Colors.indigo,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  opt.pointsLabel,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        selected ? Colors.white : Colors.indigo,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Or enter your preferred amount',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (_) {
                        if (_selectedIndex != null) {
                          setState(() => _selectedIndex = null);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: 'Enter',
                        suffixText: r'$',
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 14,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      r'$1.00 = 100Points',
                      style: TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  icon: const Icon(Icons.auto_awesome, size: 22),
                  label: const Text(
                    'Redeem Now',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RedeemOption {
  final String amountLabel;
  final String pointsLabel;

  const _RedeemOption({required this.amountLabel, required this.pointsLabel});
}
